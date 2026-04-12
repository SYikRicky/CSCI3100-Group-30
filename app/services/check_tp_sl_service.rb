class CheckTpSlService
  def initialize(stock:, current_price: nil)
    @stock = stock
    @current_price = (current_price || stock.last_price).to_d
  end

  def call
    triggered = []

    Holding.where(stock: @stock).includes(:portfolio).find_each do |holding|
      trade = latest_tp_sl_trade(holding)
      next unless trade

      result = check_and_execute(holding, trade)
      triggered << result if result
    end

    triggered
  end

  private

  def latest_tp_sl_trade(holding)
    holding.portfolio.trades
      .where(stock: @stock, status: "filled")
      .where("take_profit IS NOT NULL OR stop_loss IS NOT NULL")
      .order(created_at: :desc)
      .first
  end

  def check_and_execute(holding, trade)
    if holding.long?
      if trade.take_profit && @current_price >= trade.take_profit.to_d
        close_position(holding, "sell")
      elsif trade.stop_loss && @current_price <= trade.stop_loss.to_d
        close_position(holding, "sell")
      end
    elsif holding.short?
      if trade.take_profit && @current_price <= trade.take_profit.to_d
        close_position(holding, "buy")
      elsif trade.stop_loss && @current_price >= trade.stop_loss.to_d
        close_position(holding, "buy")
      end
    end
  end

  def close_position(holding, action)
    # Temporarily set stock price to the simulated price for accurate execution
    @stock.last_price = @current_price
    TradingService.new(
      portfolio: holding.portfolio,
      stock: @stock,
      action: action,
      quantity: holding.quantity
    ).call
  end
end
