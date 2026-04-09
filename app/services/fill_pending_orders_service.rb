class FillPendingOrdersService
  def initialize(stock:, current_price: nil)
    @stock = stock
    @current_price = (current_price || stock.last_price).to_d
  end

  def call
    filled = []

    Trade.where(stock: @stock, status: "pending").includes(:portfolio).find_each do |order|
      next unless should_fill?(order)
      fill_order!(order)
      filled << order
    end

    filled
  end

  private

  # Limit buy:  fill when price <= limit_price
  # Limit sell: fill when price >= limit_price
  # Stop buy:   fill when price >= stop_price
  # Stop sell:  fill when price <= stop_price
  def should_fill?(order)
    case order.order_type
    when "limit"
      if order.buy?
        @current_price <= order.limit_price.to_d
      else
        @current_price >= order.limit_price.to_d
      end
    when "stop"
      if order.buy?
        @current_price >= order.stop_price.to_d
      else
        @current_price <= order.stop_price.to_d
      end
    else
      false
    end
  end

  def fill_order!(order)
    fill_price = order.order_type == "limit" ? order.limit_price.to_d : order.stop_price.to_d

    ActiveRecord::Base.transaction do
      if order.buy?
        process_buy!(order.portfolio, fill_price, order.quantity.to_d)
      else
        process_sell!(order.portfolio, fill_price, order.quantity.to_d)
      end

      order.update!(
        status: "filled",
        price_at_trade: fill_price,
        executed_at: Time.current
      )

      PortfolioValuationService.new(portfolio: order.portfolio).call
    end
  end

  def process_buy!(portfolio, price, quantity)
    short_holding = portfolio.holdings.find_by(stock: @stock, direction: "short")

    if short_holding
      cover_qty = [quantity, short_holding.quantity.to_d].min
      remainder = quantity - cover_qty

      cover_cost = cover_qty * price
      portfolio.update!(cash_balance: portfolio.cash_balance.to_d - cover_cost)

      remaining_short = short_holding.quantity.to_d - cover_qty
      if remaining_short.zero?
        short_holding.destroy!
      else
        short_holding.update!(quantity: remaining_short)
      end

      open_long!(portfolio, price, remainder) if remainder.positive?
    else
      open_long!(portfolio, price, quantity)
    end
  end

  def process_sell!(portfolio, price, quantity)
    long_holding = portfolio.holdings.find_by(stock: @stock, direction: "long")

    if long_holding
      close_qty = [quantity, long_holding.quantity.to_d].min
      remainder = quantity - close_qty

      proceeds = close_qty * price
      portfolio.update!(cash_balance: portfolio.cash_balance.to_d + proceeds)

      remaining_long = long_holding.quantity.to_d - close_qty
      if remaining_long.zero?
        long_holding.destroy!
      else
        long_holding.update!(quantity: remaining_long)
      end

      open_short!(portfolio, price, remainder) if remainder.positive?
    else
      open_short!(portfolio, price, quantity)
    end
  end

  def open_long!(portfolio, price, qty)
    cost = qty * price
    raise TradingService::Error, "Insufficient cash balance" if portfolio.cash_balance.to_d < cost

    portfolio.update!(cash_balance: portfolio.cash_balance.to_d - cost)

    holding = portfolio.holdings.find_or_initialize_by(stock: @stock, direction: "long")
    current_quantity = holding.quantity.to_d
    current_cost = current_quantity * holding.average_cost.to_d
    new_quantity = current_quantity + qty
    new_average_cost = (current_cost + cost) / new_quantity

    holding.update!(quantity: new_quantity, average_cost: new_average_cost)
  end

  def open_short!(portfolio, price, qty)
    proceeds = qty * price
    portfolio.update!(cash_balance: portfolio.cash_balance.to_d + proceeds)

    holding = portfolio.holdings.find_or_initialize_by(stock: @stock, direction: "short")
    current_quantity = holding.quantity.to_d
    current_cost = current_quantity * holding.average_cost.to_d
    new_quantity = current_quantity + qty
    new_average_cost = (current_cost + proceeds) / new_quantity

    holding.update!(quantity: new_quantity, average_cost: new_average_cost)
  end
end
