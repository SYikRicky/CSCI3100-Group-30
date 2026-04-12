require "rails_helper"

RSpec.describe IdeaTag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:idea_taggings).dependent(:destroy) }
    it { is_expected.to have_many(:ideas).through(:idea_taggings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates uniqueness of name" do
      create(:idea_tag, name: "Technical Analysis")
      duplicate = build(:idea_tag, name: "Technical Analysis")
      expect(duplicate).not_to be_valid
    end
  end
end
