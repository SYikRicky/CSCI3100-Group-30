class Stock < ApplicationRecord
  has_many :price_snapshots, dependent: :destroy

  validates :ticker, presence: true, uniqueness: true
  validates :company_name, presence: true
end

