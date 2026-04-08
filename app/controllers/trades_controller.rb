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
      quantity: trade_params[:quantity]
    ).call

    respond_to do |format|
      format.html { flash[:notice] = "Trade executed successfully (Virtual Trading Only)"; redirect_to portfolio_path(@portfolio) }
      format.json { render json: { notice: "#{trade_params[:action].capitalize} #{trade.quantity} × #{stock.ticker} executed." } }
    end
  rescue TradingService::Error => e
    respond_with_error(e.message)
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find(params[:portfolio_id])
  end

  def trade_params
    params.expect(trade: [ :ticker, :action, :quantity ])
  end

  def respond_with_error(message)
    respond_to do |format|
      format.html { flash[:alert] = message; redirect_to portfolio_path(@portfolio) }
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end
end
