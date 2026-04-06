require 'rails_helper'

RSpec.describe TradingService, type: :service do
  let(:portfolio) { create(:portfolio, cash_balance: 1000) }
  let(:stock) { create(:stock, last_price: 100) }
  let(:executed_at) { Time.current }

  describe "#call" do
    context "buy order" do
      it "creates a trade and updates portfolio cash/holdings" do
        trade = described_class.new(
          portfolio: portfolio,
          stock: stock,
          action: "buy",
          quantity: 5,
          price: 100,
          executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(trade).to be_persisted
        expect(trade.action).to eq("buy")
        expect(portfolio.cash_balance).to eq(BigDecimal("500.0"))
        expect(holding.quantity).to eq(BigDecimal("5.0"))
        expect(holding.average_cost).to eq(BigDecimal("100.0"))
        expect(portfolio.portfolio_valuations.count).to eq(1)
      end

      it "raises when cash is insufficient" do
        service = described_class.new(
          portfolio: portfolio,
          stock: stock,
          action: "buy",
          quantity: 20,
          price: 100,
          executed_at: executed_at
        )

        expect { service.call }.to raise_error(TradingService::Error, /insufficient cash/i)
      end
    end

    context "sell order" do
      before do
        create(:holding, portfolio: portfolio, stock: stock, quantity: 8, average_cost: 95)
      end

      it "creates a trade and credits cash while reducing holdings" do
        trade = described_class.new(
          portfolio: portfolio,
          stock: stock,
          action: "sell",
          quantity: 3,
          price: 120,
          executed_at: executed_at
        ).call

        portfolio.reload
        holding = portfolio.holdings.find_by(stock: stock)

        expect(trade.action).to eq("sell")
        expect(portfolio.cash_balance).to eq(BigDecimal("1360.0"))
        expect(holding.quantity).to eq(BigDecimal("5.0"))
        expect(portfolio.portfolio_valuations.count).to eq(1)
      end

      it "deletes holding when all shares are sold" do
        described_class.new(
          portfolio: portfolio,
          stock: stock,
          action: "sell",
          quantity: 8,
          price: 120,
          executed_at: executed_at
        ).call

        expect(portfolio.holdings.find_by(stock: stock)).to be_nil
      end

      it "raises when shares are insufficient" do
        service = described_class.new(
          portfolio: portfolio,
          stock: stock,
          action: "sell",
          quantity: 10,
          price: 120,
          executed_at: executed_at
        )

        expect { service.call }.to raise_error(TradingService::Error, /insufficient shares/)
      end
    end
  end
end
