require 'rails_helper'

RSpec.describe League, type: :model do
  describe "#status" do
    it "is 'active' when now is between starts_at and ends_at" do
      league = FactoryBot.build(:league, starts_at: 1.day.ago, ends_at: 1.day.from_now)
      expect(league.status).to eq("active")
    end

    it "is 'passed' when now is after ends_at" do
      league = FactoryBot.build(:league, starts_at: 2.days.ago, ends_at: 1.day.ago)
      expect(league.status).to eq("passed")
    end

    it "is 'upcoming' when now is before starts_at" do
      league = FactoryBot.build(:league, starts_at: 1.day.from_now, ends_at: 2.days.from_now)
      expect(league.status).to eq("upcoming")
    end
  end

  describe "#invite_code" do
    it "returns 'invite code' for the league" do
      league = FactoryBot.build(:league, invite_code: "ABC123")
      expect(league.invite_code).to eq("ABC123")
    end
  end

  describe "dependent destroy" do
    it "destroys associated portfolios when destroyed" do
      league = FactoryBot.create(:league)
      user = FactoryBot.create(:user)
      FactoryBot.create(:portfolio, league: league, user: user)
      expect { league.destroy! }.not_to raise_error
      expect(Portfolio.where(league_id: league.id)).to be_empty
    end
  end

  describe "validation" do
    it "is invalid without a owner" do
      league_without_owner = FactoryBot.build(:league, owner: nil)
      expect(league_without_owner).not_to be_valid
      expect(league_without_owner.errors[:owner]).to be_present
    end

    it "is invalid if the end date < start date" do
      league = FactoryBot.build(
        :league,
        starts_at: Time.new(2026, 3, 26, 0, 0, 0),
        ends_at: Time.new(2026, 3, 25, 0, 0, 0)
        )
      expect(league).not_to be_valid
      expect(league.errors[:ends_at]).to be_present
    end

    it "is invalid without the starting capital" do
      league_without_capital = FactoryBot.build(:league, starting_capital: nil)
      expect(league_without_capital).not_to be_valid
      expect(league_without_capital.errors[:starting_capital]).to be_present
    end

    it "is invalid with <= 0 starting capital" do
      league = FactoryBot.build(:league, starting_capital: 0)
      expect(league).not_to be_valid
      expect(league.errors[:starting_capital]).to be_present
    end

    it "auto-generates an invite code before saving" do
      league = FactoryBot.create(:league, invite_code: nil)
      expect(league.invite_code).to be_present
    end

    it "is invalid if the end date equals start date" do
      time = Time.new(2026, 3, 26, 0, 0, 0)
      league = FactoryBot.build(:league, starts_at: time, ends_at: time)
      expect(league).not_to be_valid
      expect(league.errors[:ends_at]).to be_present
    end

    it "is invalid with a duplicate invite code" do
      FactoryBot.create(:league, invite_code: "ABC123")
      league = FactoryBot.build(:league, invite_code: "ABC123")
      expect(league).not_to be_valid
      expect(league.errors[:invite_code]).to be_present
    end

    it "is invalid with negative starting capital" do
      league = FactoryBot.build(:league, starting_capital: -1)
      expect(league).not_to be_valid
      expect(league.errors[:starting_capital]).to be_present
    end

    it "is invalid with a name longer than 100 characters" do
      league = FactoryBot.build(:league, name: "a" * 101)
      expect(league).not_to be_valid
      expect(league.errors[:name]).to be_present
    end
  end
end
