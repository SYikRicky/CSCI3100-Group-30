require "rails_helper"

RSpec.describe Friendship, type: :model do
  subject(:friendship) { FactoryBot.build(:friendship) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:friend).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:friend) }

    it "is valid with a sender and a different recipient" do
      expect(friendship).to be_valid
    end

    it "is invalid when user tries to friend themselves" do
      friendship.friend = friendship.user
      expect(friendship).not_to be_valid
      expect(friendship.errors[:friend]).to be_present
    end

    it "is invalid when a friendship to the same person already exists" do
      friendship.save!
      duplicate = FactoryBot.build(:friendship, user: friendship.user, friend: friendship.friend)
      expect(duplicate).not_to be_valid
    end

    it "is invalid when a reverse friendship already exists" do
      friendship.save!
      reverse = FactoryBot.build(:friendship, user: friendship.friend, friend: friendship.user)
      expect(reverse).not_to be_valid
      expect(reverse.errors[:base]).to be_present
    end
  end

  describe "enum status" do
    it "defaults to pending" do
      expect(friendship.status).to eq("pending")
    end

    it "can be accepted" do
      friendship.save!
      friendship.accepted!
      expect(friendship.reload.status).to eq("accepted")
    end

    it "can be rejected" do
      friendship.save!
      friendship.rejected!
      expect(friendship.reload.status).to eq("rejected")
    end
  end

  describe "scopes" do
    let(:user)    { FactoryBot.create(:user) }
    let(:friend1) { FactoryBot.create(:user) }
    let(:friend2) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:friendship, user: user, friend: friend1, status: :accepted)
      FactoryBot.create(:friendship, user: user, friend: friend2, status: :pending)
    end

    it "Friendship.accepted returns only accepted friendships" do
      expect(Friendship.accepted.count).to eq(1)
    end

    it "Friendship.pending returns only pending friendships" do
      expect(Friendship.pending.count).to eq(1)
    end
  end
end
