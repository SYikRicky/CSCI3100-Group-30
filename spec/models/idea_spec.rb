require "rails_helper"

RSpec.describe Idea, type: :model do
  subject(:idea) { build(:idea) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:stock).optional }
    it { is_expected.to have_many(:idea_comments).dependent(:destroy) }
    it { is_expected.to have_many(:idea_likes).dependent(:destroy) }
    it { is_expected.to have_many(:idea_taggings).dependent(:destroy) }
    it { is_expected.to have_many(:idea_tags).through(:idea_taggings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:direction) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:direction).with_values(long: 0, short: 1, neutral: 2) }
  end

  describe "scopes" do
    describe ".published" do
      it "returns only ideas with a published_at date" do
        published   = create(:idea, published_at: 1.hour.ago)
        _unpublished = create(:idea, published_at: nil)
        expect(Idea.published).to contain_exactly(published)
      end
    end

    describe ".recent" do
      it "orders by published_at descending" do
        older = create(:idea, published_at: 2.days.ago)
        newer = create(:idea, published_at: 1.hour.ago)
        expect(Idea.recent).to eq([ newer, older ])
      end
    end
  end

  describe "#liked_by?" do
    let(:idea) { create(:idea) }
    let(:user) { create(:user) }

    it "returns true when the user has liked the idea" do
      create(:idea_like, idea: idea, user: user)
      expect(idea.liked_by?(user)).to be true
    end

    it "returns false when the user has not liked the idea" do
      expect(idea.liked_by?(user)).to be false
    end

    it "returns false for nil user" do
      expect(idea.liked_by?(nil)).to be false
    end
  end

  describe "#likes_count" do
    let(:idea) { create(:idea) }

    it "returns the number of likes" do
      create_list(:idea_like, 3, idea: idea)
      expect(idea.likes_count).to eq(3)
    end
  end

  describe "#comments_count" do
    let(:idea) { create(:idea) }

    it "returns the number of comments" do
      create_list(:idea_comment, 2, idea: idea)
      expect(idea.comments_count).to eq(2)
    end
  end
end
