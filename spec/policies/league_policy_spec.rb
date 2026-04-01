require 'rails_helper'

RSpec.describe LeaguePolicy, type: :policy do
    subject { described_class }

  permissions :index? do
    it "allows access if user is logged in" do
      expect(subject).to permit(User.new, League.new)
    end
  end

  permissions :show? do
    it "allows the owner" do
      user = FactoryBot.create(:user)
      league = FactoryBot.create(:league, owner: user)
      expect(subject).to permit(user, league)
    end

    it "allows a member" do
      owner = FactoryBot.create(:user)
      member = FactoryBot.create(:user)
      league = FactoryBot.create(:league, owner: owner)
      FactoryBot.create(:league_membership, user: member, league: league)
      expect(subject).to permit(member, league)
    end

    it "denies a non-member" do
      owner = FactoryBot.create(:user)
      other = FactoryBot.create(:user)
      league = FactoryBot.create(:league, owner: owner)
      expect(subject).not_to permit(other, league)
    end
  end

  permissions :destroy? do
    it "allows the owner" do
      user = FactoryBot.create(:user)
      league = FactoryBot.create(:league, owner: user)
      expect(subject).to permit(user, league)
    end

    it "denies a non-owner" do
      owner = FactoryBot.create(:user)
      other = FactoryBot.create(:user)
      league = FactoryBot.create(:league, owner: owner)
      expect(subject).not_to permit(other, league)
    end
  end
end
