class PortfolioValuation < ApplicationRecord
  belongs_to :portfolio

  validates :valued_at, presence: true
  validates :cash_value, :holdings_value, :total_value, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :recent_first, -> { order(valued_at: :desc) }

  def self.record!(portfolio:, valued_at: Time.current)
    holdings_value = portfolio.holdings.includes(:stock).sum(&:market_value)
    cash_value = portfolio.cash_balance.to_d

    create!(
      portfolio: portfolio,
      valued_at: valued_at,
      cash_value: cash_value,
      holdings_value: holdings_value,
      total_value: cash_value + holdings_value
    )
  end
end
