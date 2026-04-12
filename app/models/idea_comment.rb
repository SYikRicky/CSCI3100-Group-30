class IdeaComment < ApplicationRecord
  belongs_to :idea
  belongs_to :user
  belongs_to :parent, class_name: "IdeaComment", optional: true

  has_many :replies, class_name: "IdeaComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true
end
