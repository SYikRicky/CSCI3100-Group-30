require "rails_helper"

RSpec.describe IdeaPolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    it "allows any logged-in user" do
      expect(subject).to permit(User.new, Idea.new)
    end
  end

  permissions :show? do
    it "allows any logged-in user" do
      expect(subject).to permit(User.new, Idea.new)
    end
  end

  permissions :create? do
    it "allows any logged-in user" do
      expect(subject).to permit(User.new, Idea.new)
    end
  end

  permissions :update? do
    it "allows the author" do
      user = FactoryBot.create(:user)
      idea = FactoryBot.create(:idea, user: user)
      expect(subject).to permit(user, idea)
    end

    it "denies a non-author" do
      author = FactoryBot.create(:user)
      other  = FactoryBot.create(:user)
      idea   = FactoryBot.create(:idea, user: author)
      expect(subject).not_to permit(other, idea)
    end
  end

  permissions :destroy? do
    it "allows the author" do
      user = FactoryBot.create(:user)
      idea = FactoryBot.create(:idea, user: user)
      expect(subject).to permit(user, idea)
    end

    it "denies a non-author" do
      author = FactoryBot.create(:user)
      other  = FactoryBot.create(:user)
      idea   = FactoryBot.create(:idea, user: author)
      expect(subject).not_to permit(other, idea)
    end
  end
end
