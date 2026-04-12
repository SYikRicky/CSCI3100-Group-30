class NotificationsController < ApplicationController
  def mark_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    head :no_content
  end
end
