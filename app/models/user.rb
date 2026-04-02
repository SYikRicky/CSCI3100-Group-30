class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Key associations
  has_many :portfolios
  has_many :league_memberships
  has_many :leagues, through: :league_memberships
  has_many :owned_leagues, class_name: "League", foreign_key: "owner_id"

  has_many :sent_friendships,     class_name: "Friendship", foreign_key: :user_id,   dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def friends
    accepted_sent     = sent_friendships.accepted.pluck(:friend_id)
    accepted_received = received_friendships.accepted.pluck(:user_id)
    User.where(id: accepted_sent + accepted_received)
  end

  def pending_received_requests
    received_friendships.pending
  end
end
