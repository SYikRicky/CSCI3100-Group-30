require "rails_helper"

RSpec.describe "Chatrooms and messages", type: :request do
  include Devise::Test::IntegrationHelpers
  include ActionCable::TestHelper

  let(:alice) { FactoryBot.create(:user, email: "alice@cuhk.edu.hk") }
  let(:bob)   { FactoryBot.create(:user, email: "bob@cuhk.edu.hk") }

  before do
    FactoryBot.create(:friendship, user: alice, friend: bob, status: :accepted)
    sign_in alice
  end

  describe "GET /chatrooms" do
    it "returns a successful response" do
      get chatrooms_path
      expect(response).to be_successful
    end

    it "lists the friend in the sidebar" do
      get chatrooms_path
      expect(response.body).to include(bob.email)
    end

    it "shows empty state when no friend is selected" do
      get chatrooms_path
      expect(response.body).to include("Select a friend from the list")
    end

    context "with friend_id" do
      it "shows the composer and thread for that friend" do
        get chatrooms_path(friend_id: bob.id)
        expect(response.body).to include("Chatting with")
        expect(response.body).to include(bob.display_name)
        expect(response.body).to include('data-testid="chat-message-form"')
      end

      it "ignores friend_id that is not an accepted friend" do
        stranger = FactoryBot.create(:user)
        get chatrooms_path(friend_id: stranger.id)
        expect(response.body).to include("Select a friend from the list")
        expect(response.body).not_to include("Chatting with")
      end
    end
  end

  describe "POST /chatrooms/:chatroom_id/messages" do
    it "creates a message" do
      expect {
        post chatroom_messages_path(chatroom_id: bob.id), params: { message: { content: "Hi Bob" } }
      }.to change(Message, :count).by(1)

      expect(Message.last).to have_attributes(
        sender: alice,
        receiver: bob,
        content: "Hi Bob"
      )
    end

    it "redirects back to the chat thread" do
      post chatroom_messages_path(chatroom_id: bob.id), params: { message: { content: "Hi" } }
      expect(response).to redirect_to(chatrooms_path(friend_id: bob.id))
    end

    it "shows the new message after redirect" do
      post chatroom_messages_path(chatroom_id: bob.id), params: { message: { content: "Line two" } }
      follow_redirect!
      expect(response.body).to include("Line two")
    end

    it "broadcasts a turbo stream append to the DM channel" do
      expect {
        post chatroom_messages_path(chatroom_id: bob.id), params: { message: { content: "Realtime" } }
      }.to have_broadcasted_to(Message.dm_stream_name(alice, bob)).from_channel(Turbo::StreamsChannel)
    end

    it "rejects empty content" do
      expect {
        post chatroom_messages_path(chatroom_id: bob.id), params: { message: { content: "" } }
      }.not_to change(Message, :count)
      expect(response).to redirect_to(chatrooms_path(friend_id: bob.id))
      follow_redirect!
      expect(response.body).to match(/can't be blank|blank/i)
    end

    context "when chatroom_id is not a friend" do
      let(:stranger) { FactoryBot.create(:user) }

      it "does not create a message" do
        expect {
          post chatroom_messages_path(chatroom_id: stranger.id), params: { message: { content: "nope" } }
        }.not_to change(Message, :count)
      end

      it "redirects to chatrooms index with an alert" do
        post chatroom_messages_path(chatroom_id: stranger.id), params: { message: { content: "nope" } }
        expect(response).to redirect_to(chatrooms_path)
        follow_redirect!
        expect(response.body).to include("Friend not found")
      end
    end
  end

  describe "authentication" do
    before { sign_out alice }

    it "redirects unauthenticated users from chatrooms" do
      get chatrooms_path
      expect(response).to redirect_to(new_user_session_url)
    end

    it "redirects unauthenticated users from creating messages" do
      post chatroom_messages_path(chatroom_id: bob.id), params: { message: { content: "x" } }
      expect(response).to redirect_to(new_user_session_url)
    end
  end
end
