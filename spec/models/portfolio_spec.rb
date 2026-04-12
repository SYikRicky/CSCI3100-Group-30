require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:league) }
    it { should have_many(:trades).dependent(:destroy) }
    it { should have_many(:holdings).dependent(:destroy) }
    it { should have_many(:portfolio_valuations).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:cash_balance) }
    it { should validate_numericality_of(:cash_balance).is_greater_than_or_equal_to(0) }
  end

  describe "#total_value" do
    it "returns cash plus current holdings market value" do
      portfolio = create(:portfolio, cash_balance: 1000)
      stock = create(:stock, last_price: 150)
      create(:holding, portfolio: portfolio, stock: stock, quantity: 2, average_cost: 120)

      expect(portfolio.total_value).to eq(BigDecimal("1300.0"))
    end
  end
end
