class TradingService
  class Error < StandardError; end

  def initialize(portfolio:, stock:, action:, quantity:, executed_at: Time.current)
    @portfolio = portfolio
    @stock = stock
    @action = action.to_s
    @quantity = BigDecimal(quantity.to_s)
    @market_price = BigDecimal(stock.last_price.to_s)
    @executed_at = executed_at
  end

  def call
    validate_inputs!

    trade = nil

    ActiveRecord::Base.transaction do
      if action == "buy"
        process_buy!
      else
        process_sell!
      end

      trade = portfolio.trades.create!(
        stock: stock,
        action: action,
        quantity: quantity,
        price_at_trade: market_price,
        executed_at: executed_at
      )

      PortfolioValuationService.new(portfolio: portfolio, valued_at: executed_at).call
    end

    TradeMailer.confirmation(trade).deliver_later
    trade
  end

  private

  attr_reader :portfolio, :stock, :action, :quantity, :market_price, :executed_at

  def validate_inputs!
    raise Error, "action must be buy or sell" unless %w[buy sell].include?(action)
    raise Error, "quantity must be greater than 0" unless quantity.positive?
    raise Error, "market price unavailable" unless stock.last_price.present?
    raise Error, "market price must be greater than 0" unless market_price.positive?
  end

  def process_buy!
    cost = quantity * market_price
    raise Error, "Insufficient cash balance" if portfolio.cash_balance.to_d < cost

    portfolio.update!(cash_balance: portfolio.cash_balance.to_d - cost)

    holding = portfolio.holdings.find_or_initialize_by(stock: stock)
    current_quantity = holding.quantity.to_d
    current_cost = current_quantity * holding.average_cost.to_d
    new_quantity = current_quantity + quantity
    new_average_cost = (current_cost + cost) / new_quantity

    holding.update!(quantity: new_quantity, average_cost: new_average_cost)
  end

  def process_sell!
    holding = portfolio.holdings.find_by(stock: stock)
    raise Error, "no holdings found for #{stock.ticker}" unless holding
    raise Error, "insufficient shares to sell" if holding.quantity.to_d < quantity

    proceeds = quantity * market_price
    portfolio.update!(cash_balance: portfolio.cash_balance.to_d + proceeds)

    remaining_quantity = holding.quantity.to_d - quantity
    if remaining_quantity.zero?
      holding.destroy!
    else
      holding.update!(quantity: remaining_quantity)
    end
  end
end
