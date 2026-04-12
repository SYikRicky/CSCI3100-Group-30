class Stock < ApplicationRecord
  has_many :price_snapshots, dependent: :destroy
  has_many :trades, dependent: :destroy
  has_many :holdings, dependent: :destroy
  has_many :ideas, dependent: :nullify

  validates :ticker, presence: true, uniqueness: true
  validates :company_name, presence: true
end
