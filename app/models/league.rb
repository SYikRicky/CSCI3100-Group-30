class League < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"
  has_many :league_memberships, dependent: :destroy
  has_many :members, through: :league_memberships, source: :user

  attr_accessor :invitee_identifier

  before_validation :generate_invite_code, on: :create

  validates :name, presence: true, length: { maximum: 100 }
  validates :owner, :invite_code, :starts_at, :ends_at, presence: true
  validates :invite_code, uniqueness: true
  validates :starting_capital, numericality: { greater_than: 0 }
  validate :starts_at_before_ends_at

  def status
    return "upcoming" if Time.current < starts_at
    return "active"   if Time.current < ends_at
    "passed"
  end

  private

  def generate_invite_code
    self.invite_code ||= SecureRandom.alphanumeric(6).upcase
  end

  def starts_at_before_ends_at
    return unless starts_at && ends_at
    if starts_at >= ends_at
      errors.add(:ends_at, "must be after start date")
    end
  end
end
