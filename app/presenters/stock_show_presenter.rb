class StockShowPresenter
  def initialize(stock:, portfolios:)
    @stock = stock
    @portfolios = portfolios
    @portfolio_ids = portfolios.map(&:id)
  end

  def portfolio_cash
    @portfolios.each_with_object({}) { |p, h| h[p.id] = p.cash_balance.to_f }
  end

  def my_holdings
    Holding.where(portfolio_id: @portfolio_ids, stock_id: @stock.id)
           .each_with_object({}) do |h, memo|
      memo[h.portfolio_id] = { quantity: h.quantity.to_f, average_cost: h.average_cost.to_f, direction: h.direction }
    end
  end

  def all_holdings
    Holding.where(portfolio_id: @portfolio_ids)
           .includes(:stock)
           .each_with_object({}) do |h, memo|
      (memo[h.portfolio_id] ||= []) << {
        ticker: h.stock.ticker,
        company: h.stock.company_name,
        quantity: h.quantity.to_f,
        average_cost: h.average_cost.to_f,
        current_price: h.stock.last_price.to_f,
        stock_id: h.stock_id,
        direction: h.direction
      }
    end
  end

  def pending_orders
    Trade.where(portfolio_id: @portfolio_ids, status: "pending")
         .includes(:stock)
         .each_with_object({}) do |t, memo|
      (memo[t.portfolio_id] ||= []) << {
        id: t.id,
        ticker: t.stock.ticker,
        action: t.action,
        order_type: t.order_type,
        quantity: t.quantity.to_f,
        limit_price: t.limit_price&.to_f,
        stop_price: t.stop_price&.to_f,
        created_at: t.created_at.strftime("%b %d %H:%M")
      }
    end
  end

  def trade_history
    Trade.where(portfolio_id: @portfolio_ids)
         .where.not(status: "pending")
         .includes(:stock)
         .order(created_at: :desc)
         .limit(50)
         .each_with_object({}) do |t, memo|
      (memo[t.portfolio_id] ||= []) << {
        id: t.id,
        ticker: t.stock.ticker,
        action: t.action,
        order_type: t.order_type,
        quantity: t.quantity.to_f,
        price: t.price_at_trade&.to_f,
        status: t.status,
        take_profit: t.take_profit&.to_f,
        stop_loss: t.stop_loss&.to_f,
        executed_at: t.executed_at&.strftime("%b %d %H:%M"),
        created_at: t.created_at.strftime("%b %d %H:%M")
      }
    end
  end
end
