class IdeaTagging < ApplicationRecord
  belongs_to :idea
  belongs_to :idea_tag

  validates :idea_tag_id, uniqueness: { scope: :idea_id }
end
