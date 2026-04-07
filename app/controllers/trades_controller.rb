class TradesController < ApplicationController
  before_action :set_portfolio

  def create
    stock = Stock.find_by(ticker: trade_params[:ticker].to_s.upcase)
    unless stock
      return respond_with_error("Stock not found")
    end

    trade = TradingService.new(
      portfolio: @portfolio,
      stock: stock,
      action: trade_params[:action],
      quantity: trade_params[:quantity],
      order_type: trade_params[:order_type] || "market",
      limit_price: trade_params[:limit_price],
      stop_price: trade_params[:stop_price]
    ).call

    msg = if trade.pending?
            "#{trade.order_type.capitalize} order placed (#{trade_params[:action]} #{trade.quantity.to_i} × #{stock.ticker})"
          else
            "Trade executed successfully (Virtual Trading Only)"
          end

    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to portfolio_path(@portfolio) }
      format.json { render json: { notice: msg, trade: trade_json(trade) } }
    end
  rescue TradingService::Error => e
    respond_with_error(e.message)
  end

  def cancel
    trade = @portfolio.trades.pending.find(params[:id])
    trade.update!(status: "cancelled")

    respond_to do |format|
      format.html { flash[:notice] = "Order cancelled"; redirect_to portfolio_path(@portfolio) }
      format.json { render json: { notice: "Order cancelled" } }
    end
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find(params[:portfolio_id])
  end

  def trade_params
    params.require(:trade).permit(:ticker, :action, :quantity, :order_type, :limit_price, :stop_price)
  end

  def trade_json(trade)
    {
      id: trade.id,
      action: trade.action,
      order_type: trade.order_type,
      quantity: trade.quantity.to_f,
      price_at_trade: trade.price_at_trade&.to_f,
      limit_price: trade.limit_price&.to_f,
      stop_price: trade.stop_price&.to_f,
      status: trade.status,
      ticker: trade.stock.ticker,
      executed_at: trade.executed_at
    }
  end

  def respond_with_error(message)
    respond_to do |format|
      format.html { flash[:alert] = message; redirect_to portfolio_path(@portfolio) }
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end
end
