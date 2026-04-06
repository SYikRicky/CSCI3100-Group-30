require 'rails_helper'

RSpec.describe PortfolioValuation, type: :model do
  describe "associations" do
    it { should belong_to(:portfolio) }
  end

  describe "validations" do
    it { should validate_presence_of(:valued_at) }
    it { should validate_numericality_of(:cash_value).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:holdings_value).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_value).is_greater_than_or_equal_to(0) }
  end

  describe ".record!" do
    it "stores snapshot values for a portfolio" do
      portfolio = create(:portfolio, cash_balance: 1000)
      stock = create(:stock, last_price: 150)
      create(:holding, portfolio: portfolio, stock: stock, quantity: 2, average_cost: 100)

      valuation = described_class.record!(portfolio: portfolio, valued_at: Time.current)

      expect(valuation.cash_value).to eq(BigDecimal("1000.0"))
      expect(valuation.holdings_value).to eq(BigDecimal("300.0"))
      expect(valuation.total_value).to eq(BigDecimal("1300.0"))
    end
  end
end
