require 'rails_helper'

RSpec.describe TradingService, type: :service do
  let(:portfolio) { create(:portfolio, cash_balance: 10_000) }
  let(:stock) { create(:stock, last_price: 100) }
  let(:executed_at) { Time.current }

  describe "#call" do
    context "buy order (long)" do
      it "creates a trade and updates portfolio cash/holdings" do
        trade = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 5, executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(trade).to be_persisted
        expect(trade.action).to eq("buy")
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("9500.0"))
        expect(holding.quantity.to_d).to eq(BigDecimal("5.0"))
        expect(holding.average_cost.to_d).to eq(BigDecimal("100.0"))
        expect(holding.direction).to eq("long")
      end

      it "raises when cash is insufficient" do
        service = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 200, executed_at: executed_at
        )
        expect { service.call }.to raise_error(TradingService::Error, /insufficient cash/i)
      end

      it "averages cost when adding to existing long position" do
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 5, executed_at: executed_at
        ).call

        stock.update!(last_price: 120)
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 5, executed_at: executed_at
        ).call

        holding = portfolio.holdings.find_by(stock: stock)
        expect(holding.quantity.to_d).to eq(10)
        expect(holding.average_cost.to_d).to eq(110) # (500+600)/10
      end
    end

    context "sell order (close long)" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 8, average_cost: 95, direction: "long")
      end

      it "credits cash while reducing long holdings" do
        trade = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 3, executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(trade.action).to eq("sell")
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("10300.0"))
        expect(holding.quantity.to_d).to eq(BigDecimal("5.0"))
        expect(holding.direction).to eq("long")
      end

      it "deletes holding when all shares are sold" do
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 8, executed_at: executed_at
        ).call

        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
      end
    end

    context "short selling (no long holdings)" do
      it "opens a short position and credits proceeds" do
        trade = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 10, executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(trade.action).to eq("sell")
        expect(trade.status).to eq("filled")
        expect(holding).to be_present
        expect(holding.direction).to eq("short")
        expect(holding.quantity.to_d).to eq(10)
        expect(holding.average_cost.to_d).to eq(100)
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("11000.0")) # +1000
      end

      it "increases short position when selling more" do
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 5, executed_at: executed_at
        ).call

        stock.update!(last_price: 90)
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 5, executed_at: executed_at
        ).call

        holding = portfolio.holdings.find_by(stock: stock)
        expect(holding.direction).to eq("short")
        expect(holding.quantity.to_d).to eq(10)
        expect(holding.average_cost.to_d).to eq(95) # (500+450)/10
      end
    end

    context "sell more than long holding (flip to short)" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 5, average_cost: 90, direction: "long")
      end

      it "closes long and opens short for the remainder" do
        trade = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 8, executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(holding.direction).to eq("short")
        expect(holding.quantity.to_d).to eq(3)
        expect(holding.average_cost.to_d).to eq(100)
        # Cash: 10000 + 5*100 (close long) + 3*100 (short proceeds) = 10800
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("10800.0"))
      end
    end

    context "buy to cover short" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 10, average_cost: 100, direction: "short")
      end

      it "covers partial short position" do
        stock.update!(last_price: 90)
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 4, executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(holding.direction).to eq("short")
        expect(holding.quantity.to_d).to eq(6)
        # Cash: 10000 - 4*90 (cost to cover) = 9640
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("9640.0"))
      end

      it "destroys holding when fully covered" do
        stock.update!(last_price: 95)
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 10, executed_at: executed_at
        ).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        # Cash: 10000 - 10*95 = 9050
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("9050.0"))
      end

      it "flips to long when buying more than short quantity" do
        stock.update!(last_price: 90)
        described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 15, executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(holding.direction).to eq("long")
        expect(holding.quantity.to_d).to eq(5)
        expect(holding.average_cost.to_d).to eq(90)
        # Cash: 10000 - 10*90 (cover short) - 5*90 (new long) = 8650
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("8650.0"))
      end
    end

    context "with take_profit and stop_loss" do
      it "saves TP and SL on market buy" do
        trade = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "buy", quantity: 5,
          take_profit: 120, stop_loss: 90,
          executed_at: executed_at
        ).call

        expect(trade.take_profit.to_f).to eq(120.0)
        expect(trade.stop_loss.to_f).to eq(90.0)
      end

      it "saves TP and SL on short sell" do
        trade = described_class.new(
          portfolio: portfolio, stock: stock,
          action: "sell", quantity: 5,
          take_profit: 80, stop_loss: 110,
          executed_at: executed_at
        ).call

        expect(trade.take_profit.to_f).to eq(80.0)
        expect(trade.stop_loss.to_f).to eq(110.0)
      end
    end
  end
end
