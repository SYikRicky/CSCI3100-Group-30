require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:kind) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:kind)
        .with_values(system: 0, invitation: 1, portfolio_summary: 2)
    }
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".recent" do
      it "returns at most 10 notifications, most recent first" do
        older = create(:notification, user: user, created_at: 2.hours.ago)
        newer = create(:notification, user: user, created_at: 1.hour.ago)
        # create extras to exceed the limit
        create_list(:notification, 10, user: user)

        result = user.notifications.recent
        expect(result.count).to eq(10)
        expect(result).not_to include(older)
      end
    end

    describe ".unread" do
      it "returns only notifications where read_at is nil" do
        unread = create(:notification, user: user, read_at: nil)
        _read  = create(:notification, user: user, read_at: 1.hour.ago)
        expect(Notification.unread).to contain_exactly(unread)
      end
    end
  end

  describe "kind helpers" do
    it "creates a system notification" do
      n = build(:notification, kind: :system)
      expect(n).to be_system
    end

    it "creates an invitation notification" do
      n = build(:notification, kind: :invitation)
      expect(n).to be_invitation
    end

    it "creates a portfolio_summary notification" do
      n = build(:notification, kind: :portfolio_summary)
      expect(n).to be_portfolio_summary
    end
  end
end
