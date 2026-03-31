class League < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  validates :name,
    :owner,
    :starting_capital,
    :invite_code,
    :starts_at,
    :ends_at,
    presence: true

  validate :starts_at_before_ends_at

  private
    def starts_at_before_ends_at
      return if self.starts_at < self.ends_at
      if self.starts_at > self.ends_at
        errors.add(:starts_at, "The start date must be earlier than end date")
      end
    end
end
