module PositionManager
  extend ActiveSupport::Concern

  private

  # ── BUY logic ──
  # 1. If short holding exists -> cover short first, then open long with remainder
  # 2. If no short -> open/add to long position
  def process_buy!(portfolio, stock, price, quantity)
    short_holding = portfolio.holdings.find_by(stock: stock, direction: "short")

    if short_holding
      cover_qty = [ quantity, short_holding.quantity.to_d ].min
      remainder = quantity - cover_qty

      cover_cost = cover_qty * price
      raise TradingService::Error, "Insufficient cash balance" if portfolio.cash_balance.to_d < cover_cost
      portfolio.update!(cash_balance: portfolio.cash_balance.to_d - cover_cost)

      remaining_short = short_holding.quantity.to_d - cover_qty
      if remaining_short.zero?
        short_holding.destroy!
      else
        short_holding.update!(quantity: remaining_short)
      end

      open_long!(portfolio, stock, price, remainder) if remainder.positive?
    else
      open_long!(portfolio, stock, price, quantity)
    end
  end

  # ── SELL logic ──
  # 1. If long holding exists -> close long first, then open short with remainder
  # 2. If no long -> open/add to short position
  def process_sell!(portfolio, stock, price, quantity)
    long_holding = portfolio.holdings.find_by(stock: stock, direction: "long")

    if long_holding
      close_qty = [ quantity, long_holding.quantity.to_d ].min
      remainder = quantity - close_qty

      proceeds = close_qty * price
      portfolio.update!(cash_balance: portfolio.cash_balance.to_d + proceeds)

      remaining_long = long_holding.quantity.to_d - close_qty
      if remaining_long.zero?
        long_holding.destroy!
      else
        long_holding.update!(quantity: remaining_long)
      end

      open_short!(portfolio, stock, price, remainder) if remainder.positive?
    else
      open_short!(portfolio, stock, price, quantity)
    end
  end

  def open_long!(portfolio, stock, price, qty)
    cost = qty * price
    raise TradingService::Error, "Insufficient cash balance" if portfolio.cash_balance.to_d < cost

    portfolio.update!(cash_balance: portfolio.cash_balance.to_d - cost)

    holding = portfolio.holdings.find_or_initialize_by(stock: stock, direction: "long")
    current_quantity = holding.quantity.to_d
    current_cost = current_quantity * holding.average_cost.to_d
    new_quantity = current_quantity + qty
    new_average_cost = (current_cost + cost) / new_quantity

    holding.update!(quantity: new_quantity, average_cost: new_average_cost)
  end

  def open_short!(portfolio, stock, price, qty)
    proceeds = qty * price
    portfolio.update!(cash_balance: portfolio.cash_balance.to_d + proceeds)

    holding = portfolio.holdings.find_or_initialize_by(stock: stock, direction: "short")
    current_quantity = holding.quantity.to_d
    current_cost = current_quantity * holding.average_cost.to_d
    new_quantity = current_quantity + qty
    new_average_cost = (current_cost + proceeds) / new_quantity

    holding.update!(quantity: new_quantity, average_cost: new_average_cost)
  end
end
