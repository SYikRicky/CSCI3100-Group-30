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

  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
