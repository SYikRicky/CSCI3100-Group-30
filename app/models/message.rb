class Message < ApplicationRecord
  MAX_CONTENT_LENGTH = 5_000

  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :sender, :receiver, :content, presence: true
  validates :content, length: { maximum: MAX_CONTENT_LENGTH }
  validate :not_messaging_self
  validate :must_be_accepted_friends

  scope :conversation_between, lambda { |user_a, user_b|
    a_id = user_a.id
    b_id = user_b.id
    where(sender_id: [ a_id, b_id ], receiver_id: [ a_id, b_id ])
  }

  def self.dm_stream_name(user_a, user_b)
    "dm_#{[ user_a.id, user_b.id ].min}_#{[ user_a.id, user_b.id ].max}"
  end

  private

  def not_messaging_self
    return if sender_id.blank? || receiver_id.blank?
    return unless sender_id == receiver_id

    errors.add(:receiver, "can't be the same as sender")
  end

  def must_be_accepted_friends
    return if sender.blank? || receiver.blank?
    return if Friendship.accepted_between?(sender, receiver)

    errors.add(:base, "You can only message accepted friends")
  end
end
