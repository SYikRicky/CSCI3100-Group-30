class FillPendingOrdersService
  include PositionManager
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
        process_buy!(order.portfolio, @stock, fill_price, order.quantity.to_d)
      else
        process_sell!(order.portfolio, @stock, fill_price, order.quantity.to_d)
      end

      order.update!(
        status: "filled",
        price_at_trade: fill_price,
        executed_at: Time.current
      )

      PortfolioValuationService.new(portfolio: order.portfolio).call
    end
  end

end
