require "rails_helper"

RSpec.describe "/friendships", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:alice) { FactoryBot.create(:user) }
  let(:bob)   { FactoryBot.create(:user) }

  before { sign_in alice }

  describe "GET /friendships" do
    it "renders a successful response" do
      get friendships_url
      expect(response).to be_successful
    end

    it "shows accepted friends" do
      FactoryBot.create(:friendship, user: alice, friend: bob, status: :accepted)
      get friendships_url
      expect(response.body).to include(bob.email)
    end

    it "shows pending incoming requests" do
      FactoryBot.create(:friendship, user: bob, friend: alice, status: :pending)
      get friendships_url
      expect(response.body).to include(bob.email)
    end
  end

  describe "POST /friendships" do
    context "with a valid email" do
      it "creates a pending friendship" do
        expect {
          post friendships_url, params: { identifier: bob.email }
        }.to change(Friendship, :count).by(1)
        expect(Friendship.last.status).to eq("pending")
        expect(Friendship.last.friend).to eq(bob)
      end

      it "redirects with a success notice" do
        post friendships_url, params: { identifier: bob.email }
        expect(response).to redirect_to(friendships_url)
        follow_redirect!
        expect(response.body).to include("Friend request sent")
      end
    end

    context "with a valid display name" do
      it "creates a pending friendship" do
        expect {
          post friendships_url, params: { identifier: bob.display_name }
        }.to change(Friendship, :count).by(1)
      end
    end

    context "with an unknown identifier" do
      it "does not create a friendship" do
        expect {
          post friendships_url, params: { identifier: "nobody@example.com" }
        }.not_to change(Friendship, :count)
      end

      it "redirects with an alert" do
        post friendships_url, params: { identifier: "nobody@example.com" }
        expect(response).to redirect_to(friendships_url)
        follow_redirect!
        expect(response.body).to include("User not found")
      end
    end
  end

  describe "PATCH /friendships/:id" do
    let!(:friendship) { FactoryBot.create(:friendship, user: bob, friend: alice, status: :pending) }

    it "accepts the friendship" do
      patch friendship_url(friendship)
      expect(friendship.reload.status).to eq("accepted")
    end

    it "redirects with a success notice" do
      patch friendship_url(friendship)
      expect(response).to redirect_to(friendships_url)
      follow_redirect!
      expect(response.body).to include("Friend request accepted")
    end
  end

  describe "DELETE /friendships/:id" do
    let!(:friendship) { FactoryBot.create(:friendship, user: alice, friend: bob, status: :accepted) }

    it "removes the friendship" do
      expect {
        delete friendship_url(friendship)
      }.to change(Friendship, :count).by(-1)
    end

    it "redirects to friendships" do
      delete friendship_url(friendship)
      expect(response).to redirect_to(friendships_url)
    end
  end

  describe "authentication" do
    before { sign_out alice }

    it "redirects unauthenticated users to sign in" do
      get friendships_url
      expect(response).to redirect_to(new_user_session_url)
    end
  end
end
