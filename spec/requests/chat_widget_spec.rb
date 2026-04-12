require "rails_helper"

RSpec.describe "ChatWidget", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:alice) { create(:user) }
  let(:bob)   { create(:user) }

  before { sign_in alice }

  # Helper to create an accepted friendship between two users
  def befriend(user_a, user_b)
    create(:friendship, user: user_a, friend: user_b, status: :accepted)
  end

  # Helper to create a message (bypass friendship validation by using the factory directly)
  def send_message(sender:, receiver:, content: "Hi", read_at: nil)
    befriend(sender, receiver) unless Friendship.accepted_between?(sender, receiver)
    Message.create!(sender: sender, receiver: receiver, content: content, read_at: read_at)
  end

  describe "GET /chat_widget/friends" do
    it "returns JSON list of accepted friends with unread counts" do
      befriend(alice, bob)
      send_message(sender: bob, receiver: alice, content: "Unread 1")
      send_message(sender: bob, receiver: alice, content: "Unread 2")

      get chat_widget_friends_path, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["id"]).to eq(bob.id)
      expect(json.first["unread_count"]).to eq(2)
    end

    it "returns empty array when no friends" do
      get chat_widget_friends_path, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  describe "GET /chat_widget/conversation" do
    it "returns messages with a friend" do
      befriend(alice, bob)
      send_message(sender: alice, receiver: bob, content: "Hello Bob")
      send_message(sender: bob, receiver: alice, content: "Hello Alice")

      get chat_widget_conversation_path, params: { friend_id: bob.id },
          headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["messages"].length).to eq(2)
      expect(json["signed_stream_name"]).to be_present
    end

    it "returns 404 if friend not found" do
      get chat_widget_conversation_path, params: { friend_id: 99999 },
          headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /chat_widget/mark_read" do
    it "marks unread messages from friend as read" do
      befriend(alice, bob)
      msg = send_message(sender: bob, receiver: alice, content: "Read me")

      patch chat_widget_mark_read_path, params: { friend_id: bob.id },
            headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:no_content)
      expect(msg.reload.read_at).to be_present
    end

    it "returns 404 if friend not found" do
      patch chat_widget_mark_read_path, params: { friend_id: 99999 },
            headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
