class Idea < ApplicationRecord
  belongs_to :user
  belongs_to :stock, optional: true

  has_many :idea_comments, dependent: :destroy
  has_many :idea_likes,    dependent: :destroy
  has_many :idea_taggings, dependent: :destroy
  has_many :idea_tags, through: :idea_taggings

  has_rich_text :body

  enum :direction, { long: 0, short: 1, neutral: 2 }

  validates :title, presence: true, length: { maximum: 200 }
  validates :body,  presence: true
  validates :direction, presence: true
  validate :body_attachments_are_images

  private

  def body_attachments_are_images
    return unless body.body.present?

    body.body.attachables.grep(ActiveStorage::Blob).each do |blob|
      unless blob.image?
        errors.add(:body, "only allows image attachments (JPEG, PNG, GIF, WEBP)")
      end
    end
  end

  public

  scope :published, -> { where.not(published_at: nil) }
  scope :recent,    -> { order(published_at: :desc) }

  def likes_count
    idea_likes.count
  end

  def liked_by?(user)
    return false unless user
    idea_likes.exists?(user: user)
  end

  def comments_count
    idea_comments.count
  end
end
