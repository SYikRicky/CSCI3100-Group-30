class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :league
  has_many :trades, dependent: :destroy
  has_many :holdings, dependent: :destroy
  has_many :portfolio_valuations, dependent: :destroy

  validates :cash_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def holdings_value
    holdings.includes(:stock).sum(&:market_value)
  end

  def total_value
    cash_balance.to_d + holdings_value
  end
end
