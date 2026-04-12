require "rails_helper"

RSpec.describe PortfolioValuationService, type: :service do
  describe "#call" do
    it "creates a valuation snapshot from current portfolio values" do
      portfolio = create(:portfolio, cash_balance: 1000)
      stock = create(:stock, last_price: 150)
      create(:holding, portfolio: portfolio, stock: stock, quantity: 2, average_cost: 100)

      valuation = described_class.new(portfolio: portfolio).call

      expect(valuation).to be_persisted
      expect(valuation.portfolio).to eq(portfolio)
      expect(valuation.cash_value).to eq(BigDecimal("1000.0"))
      expect(valuation.holdings_value).to eq(BigDecimal("300.0"))
      expect(valuation.total_value).to eq(BigDecimal("1300.0"))
    end
  end
end
