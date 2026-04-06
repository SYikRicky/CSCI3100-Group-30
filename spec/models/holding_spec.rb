require 'rails_helper'

RSpec.describe Holding, type: :model do
  describe "associations" do
    it { should belong_to(:portfolio) }
    it { should belong_to(:stock) }
  end

  describe "validations" do
    subject(:holding) { build(:holding) }

    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:average_cost).is_greater_than(0) }
    it { should validate_uniqueness_of(:stock_id).scoped_to(:portfolio_id) }
  end

  describe "#market_value" do
    it "uses stock last_price when available" do
      stock = create(:stock, last_price: 150)
      holding = create(:holding, stock: stock, quantity: 2, average_cost: 100)

      expect(holding.market_value).to eq(BigDecimal("300.0"))
    end

    it "falls back to average_cost when stock has no last_price" do
      stock = create(:stock, last_price: nil)
      holding = create(:holding, stock: stock, quantity: 2, average_cost: 100)

      expect(holding.market_value).to eq(BigDecimal("200.0"))
    end
  end
end
