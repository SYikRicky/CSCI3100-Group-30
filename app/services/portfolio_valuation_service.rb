class PortfolioValuationService
  def initialize(portfolio:, valued_at: Time.current)
    @portfolio = portfolio
    @valued_at = valued_at
  end

  def call
    holdings_value = portfolio.holdings.includes(:stock).sum(&:market_value)
    cash_value = portfolio.cash_balance.to_d

    PortfolioValuation.create!(
      portfolio: portfolio,
      valued_at: valued_at,
      cash_value: cash_value,
      holdings_value: holdings_value,
      total_value: cash_value + holdings_value
    )
  end

  private

  attr_reader :portfolio, :valued_at
end
