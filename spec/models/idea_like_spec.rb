require "rails_helper"

RSpec.describe IdeaLike, type: :model do
  subject(:like) { build(:idea_like) }

  describe "associations" do
    it { is_expected.to belong_to(:idea) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it "enforces one like per user per idea" do
      like.save!
      duplicate = build(:idea_like, idea: like.idea, user: like.user)
      expect(duplicate).not_to be_valid
    end
  end
end
