require "rails_helper"

RSpec.describe Message, type: :model do
  subject(:message) { FactoryBot.build(:message, :between_friends) }

  describe "associations" do
    it { is_expected.to belong_to(:sender).class_name("User") }
    it { is_expected.to belong_to(:receiver).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:receiver) }

    it "is valid with accepted friends" do
      expect(message).to be_valid
    end

    it "is invalid when sender messages themselves" do
      user = FactoryBot.create(:user)
      msg = FactoryBot.build(:message, sender: user, receiver: user)
      expect(msg).not_to be_valid
      expect(msg.errors[:receiver]).to be_present
    end

    it "is invalid when users are not accepted friends" do
      alice = FactoryBot.create(:user)
      bob   = FactoryBot.create(:user)
      msg = FactoryBot.build(:message, sender: alice, receiver: bob)
      expect(msg).not_to be_valid
      expect(msg.errors[:base]).to include("You can only message accepted friends")
    end

    it "is invalid when content exceeds maximum length" do
      message.content = "x" * (described_class::MAX_CONTENT_LENGTH + 1)
      expect(message).not_to be_valid
    end

    it "allows content at maximum length" do
      message.content = "x" * described_class::MAX_CONTENT_LENGTH
      expect(message).to be_valid
    end
  end

  describe ".conversation_between" do
    let(:alice) { FactoryBot.create(:user) }
    let(:bob)   { FactoryBot.create(:user) }
    let(:carol) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:friendship, user: alice, friend: bob, status: :accepted)
      FactoryBot.create(:friendship, user: alice, friend: carol, status: :accepted)
      FactoryBot.create(:message, :between_friends, sender: alice, receiver: bob, content: "a→b")
      FactoryBot.create(:message, :between_friends, sender: bob, receiver: alice, content: "b→a")
      FactoryBot.create(:message, :between_friends, sender: alice, receiver: carol, content: "a→c")
    end

    it "returns only messages between the two users" do
      msgs = described_class.conversation_between(alice, bob).order(:created_at)
      expect(msgs.map(&:content)).to eq([ "a→b", "b→a" ])
    end

    it "is symmetric in argument order" do
      expect(described_class.conversation_between(bob, alice).count).to eq(2)
    end
  end

  describe ".dm_stream_name" do
    let(:u1) { instance_double(User, id: 5) }
    let(:u2) { instance_double(User, id: 12) }

    it "is stable regardless of argument order" do
      a = described_class.dm_stream_name(u1, u2)
      b = described_class.dm_stream_name(u2, u1)
      expect(a).to eq(b)
      expect(a).to eq("dm_5_12")
    end
  end
end
