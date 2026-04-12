class Notification < ApplicationRecord
  belongs_to :user

  enum :kind, { system: 0, invitation: 1, portfolio_summary: 2 }

  validates :user,  presence: true
  validates :title, presence: true
  validates :body,  presence: true
  validates :kind,  presence: true

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :unread, -> { where(read_at: nil) }

  after_create_commit :broadcast_to_user

  private

  def broadcast_to_user
    NotificationChannel.broadcast_to(user, {
      type: "notification",
      title: title,
      body: body
    })
  end
end
