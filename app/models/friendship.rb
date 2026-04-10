class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1, rejected: 2 }

  def self.accepted_between?(user_a, user_b)
    return false if user_a.blank? || user_b.blank?

    accepted.exists?(user_id: user_a.id, friend_id: user_b.id) ||
      accepted.exists?(user_id: user_b.id, friend_id: user_a.id)
  end

  validates :user, :friend, presence: true
  validates :friend_id, uniqueness: { scope: :user_id }
  validate :not_self_referential
  validate :no_reverse_duplicate

  private

  def not_self_referential
    return if user.blank? || friend.blank?
    same = user.equal?(friend) || (user_id.present? && user_id == friend_id)
    errors.add(:friend, "can't be yourself") if same
  end

  def no_reverse_duplicate
    return unless user_id && friend_id
    if Friendship.where(user_id: friend_id, friend_id: user_id).exists?
      errors.add(:base, "Friendship already exists")
    end
  end
end
