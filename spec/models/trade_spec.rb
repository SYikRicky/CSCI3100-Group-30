require 'rails_helper'

RSpec.describe Trade, type: :model do
  describe "associations" do
    it { should belong_to(:portfolio) }
    it { should belong_to(:stock) }
  end

  describe "validations" do
    subject(:trade) { build(:trade) }

    it { should define_enum_for(:action).with_values(buy: "buy", sell: "sell").backed_by_column_of_type(:string) }
    it { should validate_presence_of(:executed_at) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:price_at_trade).is_greater_than(0) }
  end
end
