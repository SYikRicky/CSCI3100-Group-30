require 'rails_helper'

RSpec.describe League, type: :model do
  describe "#invite_code" do
    it "returns 'invite code' for the league" do
      league = FactoryBot.build(:league, invite_code: "ABC123")
      expect(league.invite_code).to eq("ABC123")
    end
  end

  describe "validation" do
    it "is invalid without a owner" do
      league_without_owner = FactoryBot.build(:league, owner: nil)
      expect(league_without_owner).not_to be_valid
      expect(league_without_owner.errors[:owner]).to be_present
    end

    it "is invalid if the end date is earlier than start date" do
      league = FactoryBot.build(
        :league,
        starts_at: Time.new(2026, 3, 26, 0, 0, 0),
        ends_at: Time.new(2026, 3, 25, 0, 0, 0)
        )
      expect(league).not_to be_valid
      expect(league.errors[:starts_at]).to be_present
    end

    it "is invalid without the starting capital" do
      league_without_capital = FactoryBot.build(:league, starting_capital: nil)
      expect(league_without_capital).not_to be_valid
      expect(league_without_capital.errors[:starting_capital]).to be_present
    end

    it "is invalid without invite code" do
      league_without_code = FactoryBot.build(:league, invite_code: nil)
      expect(league_without_code).not_to be_valid
      expect(league_without_code.errors[:invite_code]).to be_present
    end
  end
end
