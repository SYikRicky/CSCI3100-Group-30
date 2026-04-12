require "rails_helper"

RSpec.describe "Notifications", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  describe "PATCH /notifications/mark_read" do
    before { sign_in user }

    it "marks all unread notifications as read" do
      n1 = create(:notification, user: user, read_at: nil)
      n2 = create(:notification, user: user, read_at: nil)
      _read = create(:notification, user: user, read_at: 1.hour.ago)

      patch mark_read_notifications_path

      expect(response).to have_http_status(:no_content)
      expect(n1.reload.read_at).to be_present
      expect(n2.reload.read_at).to be_present
    end

    it "succeeds even when there are no unread notifications" do
      patch mark_read_notifications_path

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "authentication" do
    it "redirects unauthenticated users to sign in" do
      patch mark_read_notifications_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
