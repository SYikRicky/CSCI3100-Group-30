require "rails_helper"

RSpec.describe IdeaComment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:idea) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:parent).class_name("IdeaComment").optional }
    it { is_expected.to have_many(:replies).class_name("IdeaComment").dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end
end
