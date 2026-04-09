require 'rails_helper'

RSpec.describe CheckTpSlService, type: :service do
  let(:portfolio) { create(:portfolio, cash_balance: 10_000) }
  let(:stock) { create(:stock, last_price: 100) }

  describe "#call" do
    context "long position" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 10, average_cost: 100, direction: "long")
        create(:trade, portfolio: portfolio, stock: stock,
               action: "buy", quantity: 10, price_at_trade: 100,
               status: "filled", take_profit: 120, stop_loss: 90)
      end

      it "closes position when price hits take profit" do
        stock.update!(last_price: 120)
        result = described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("11200.0")) # 10000 + 10*120
        expect(result.size).to eq(1)
      end

      it "closes position when price exceeds take profit" do
        stock.update!(last_price: 125)
        described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("11250.0"))
      end

      it "closes position when price hits stop loss" do
        stock.update!(last_price: 90)
        result = described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("10900.0")) # 10000 + 10*90
        expect(result.size).to eq(1)
      end

      it "closes position when price drops below stop loss" do
        stock.update!(last_price: 85)
        described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("10850.0"))
      end

      it "does nothing when price is between TP and SL" do
        stock.update!(last_price: 105)
        result = described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_present
        expect(result).to be_empty
      end
    end

    context "short position" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 10, average_cost: 100, direction: "short")
        create(:trade, portfolio: portfolio, stock: stock,
               action: "sell", quantity: 10, price_at_trade: 100,
               status: "filled", take_profit: 80, stop_loss: 110)
      end

      it "covers short when price drops to take profit" do
        stock.update!(last_price: 80)
        result = described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        # Cover at 80: cash = 10000 - 10*80 = 9200
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("9200.0"))
        expect(result.size).to eq(1)
      end

      it "covers short when price rises to stop loss" do
        stock.update!(last_price: 110)
        result = described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
        # Cover at 110: cash = 10000 - 10*110 = 8900
        expect(portfolio.cash_balance.to_d).to eq(BigDecimal("8900.0"))
        expect(result.size).to eq(1)
      end

      it "does nothing when price is between SL and TP" do
        stock.update!(last_price: 95)
        result = described_class.new(stock: stock).call

        portfolio.reload
        expect(portfolio.holdings.find_by(stock: stock)).to be_present
        expect(result).to be_empty
      end
    end

    context "no TP/SL on trade" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 10, average_cost: 100, direction: "long")
        create(:trade, portfolio: portfolio, stock: stock,
               action: "buy", quantity: 10, price_at_trade: 100,
               status: "filled", take_profit: nil, stop_loss: nil)
      end

      it "does nothing" do
        stock.update!(last_price: 200)
        result = described_class.new(stock: stock).call
        expect(result).to be_empty
        expect(portfolio.holdings.find_by(stock: stock)).to be_present
      end
    end

    context "with custom current_price override" do
      before do
        create(:holding, portfolio: portfolio, stock: stock,
               quantity: 10, average_cost: 100, direction: "long")
        create(:trade, portfolio: portfolio, stock: stock,
               action: "buy", quantity: 10, price_at_trade: 100,
               status: "filled", take_profit: 120, stop_loss: 90)
      end

      it "uses the provided price instead of stock.last_price" do
        # stock.last_price is 100 (no trigger), but we pass 120
        result = described_class.new(stock: stock, current_price: 120).call
        expect(result.size).to eq(1)
        expect(portfolio.reload.holdings.find_by(stock: stock)).to be_nil
      end
    end
  end
end
