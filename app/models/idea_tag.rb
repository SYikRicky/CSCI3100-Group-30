class IdeaTag < ApplicationRecord
  has_many :idea_taggings, dependent: :destroy
  has_many :ideas, through: :idea_taggings

  validates :name, presence: true, uniqueness: true
end
