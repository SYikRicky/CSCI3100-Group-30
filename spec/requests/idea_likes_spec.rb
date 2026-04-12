require "rails_helper"

RSpec.describe "/ideas/:idea_id/likes", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:alice) { create(:user) }
  let(:idea)  { create(:idea, published_at: 1.hour.ago) }

  before { sign_in alice }

  describe "POST /ideas/:idea_id/likes" do
    it "creates a like" do
      expect {
        post idea_likes_url(idea)
      }.to change(IdeaLike, :count).by(1)
    end

    it "does not create a duplicate like" do
      create(:idea_like, idea: idea, user: alice)
      expect {
        post idea_likes_url(idea)
      }.not_to change(IdeaLike, :count)
    end
  end

  describe "DELETE /ideas/:idea_id/likes" do
    it "destroys the like" do
      create(:idea_like, idea: idea, user: alice)
      expect {
        delete idea_likes_url(idea)
      }.to change(IdeaLike, :count).by(-1)
    end
  end
end
