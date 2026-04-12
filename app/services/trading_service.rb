class TradingService
  include PositionManager

  class Error < StandardError; end

  def initialize(portfolio:, stock:, action:, quantity:, order_type: "market",
                 limit_price: nil, stop_price: nil, take_profit: nil,
                 stop_loss: nil, executed_at: Time.current)
    @portfolio = portfolio
    @stock = stock
    @action = action.to_s
    @quantity = BigDecimal(quantity.to_s)
    @market_price = BigDecimal(stock.last_price.to_s)
    @order_type = order_type.to_s
    @limit_price = limit_price ? BigDecimal(limit_price.to_s) : nil
    @stop_price = stop_price ? BigDecimal(stop_price.to_s) : nil
    @take_profit = take_profit.present? ? BigDecimal(take_profit.to_s) : nil
    @stop_loss = stop_loss.present? ? BigDecimal(stop_loss.to_s) : nil
    @executed_at = executed_at
  end

  def call
    validate_inputs!

    if order_type == "market"
      execute_market_order!
    else
      place_pending_order!
    end
  end

  private

  attr_reader :portfolio, :stock, :action, :quantity, :market_price,
              :order_type, :limit_price, :stop_price, :take_profit,
              :stop_loss, :executed_at

  def validate_inputs!
    raise Error, "action must be buy or sell" unless %w[buy sell].include?(action)
    raise Error, "quantity must be greater than 0" unless quantity.positive?
    raise Error, "market price unavailable" unless stock.last_price.present?
    raise Error, "market price must be greater than 0" unless market_price.positive?
    raise Error, "order type must be market, limit, or stop" unless %w[market limit stop].include?(order_type)
    raise Error, "limit price required for limit orders" if order_type == "limit" && limit_price.nil?
    raise Error, "stop price required for stop orders" if order_type == "stop" && stop_price.nil?
  end

  def execute_market_order!
    trade = nil

    ActiveRecord::Base.transaction do
      if action == "buy"
        process_buy!(portfolio, stock, market_price, quantity)
      else
        process_sell!(portfolio, stock, market_price, quantity)
      end

      trade = portfolio.trades.create!(
        stock: stock,
        action: action,
        quantity: quantity,
        price_at_trade: market_price,
        executed_at: executed_at,
        order_type: "market",
        status: "filled",
        take_profit: take_profit,
        stop_loss: stop_loss
      )

      PortfolioValuationService.new(portfolio: portfolio, valued_at: executed_at).call
    end

    begin
      TradeMailer.confirmation(trade).deliver_later
    rescue StandardError => e
      Rails.logger.warn("Trade mailer failed: #{e.message}")
    end
    trade
  end

  def place_pending_order!
    if action == "buy"
      price = order_type == "limit" ? limit_price : stop_price
      cost = quantity * price
      raise Error, "Insufficient cash balance for this order" if portfolio.cash_balance.to_d < cost
    else
      # For sells: allow pending short orders (no holding check needed for shorts)
      long_holding = portfolio.holdings.find_by(stock: stock, direction: "long")
      if long_holding && long_holding.quantity.to_d < quantity
        # Selling more than long — that's fine (will flip to short on fill)
      end
    end

    portfolio.trades.create!(
      stock: stock,
      action: action,
      quantity: quantity,
      order_type: order_type,
      limit_price: limit_price,
      stop_price: stop_price,
      status: "pending",
      take_profit: take_profit,
      stop_loss: stop_loss
    )
  end
end
