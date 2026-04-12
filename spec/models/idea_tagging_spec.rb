require "rails_helper"

RSpec.describe IdeaTagging, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:idea) }
    it { is_expected.to belong_to(:idea_tag) }
  end
end
