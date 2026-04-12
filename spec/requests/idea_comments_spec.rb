require "rails_helper"

RSpec.describe "/ideas/:idea_id/idea_comments", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:alice) { create(:user) }
  let(:idea)  { create(:idea, published_at: 1.hour.ago) }

  before { sign_in alice }

  describe "POST /ideas/:idea_id/idea_comments" do
    context "with valid parameters" do
      it "creates a comment" do
        expect {
          post idea_idea_comments_url(idea), params: { idea_comment: { body: "Great analysis!" } }
        }.to change(IdeaComment, :count).by(1)
      end

      it "assigns the current user as the commenter" do
        post idea_idea_comments_url(idea), params: { idea_comment: { body: "Great analysis!" } }
        expect(IdeaComment.last.user).to eq(alice)
      end

      it "redirects back to the idea" do
        post idea_idea_comments_url(idea), params: { idea_comment: { body: "Great analysis!" } }
        expect(response).to redirect_to(idea_url(idea))
      end
    end

    context "with invalid parameters" do
      it "does not create a comment" do
        expect {
          post idea_idea_comments_url(idea), params: { idea_comment: { body: "" } }
        }.not_to change(IdeaComment, :count)
      end
    end
  end
end
