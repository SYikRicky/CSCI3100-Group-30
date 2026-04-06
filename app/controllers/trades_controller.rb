class TradesController < ApplicationController
  before_action :set_portfolio

  def create
    stock = Stock.find_by(ticker: trade_params[:ticker].to_s.upcase)
    unless stock
      flash[:alert] = "Stock not found"
      return redirect_to portfolio_path(@portfolio)
    end

    begin
      TradingService.new(
        portfolio: @portfolio,
        stock: stock,
        action: trade_params[:action],
        quantity: trade_params[:quantity],
        price: trade_params[:price]
      ).call

      flash[:notice] = "Trade executed successfully (Virtual Trading Only)"
    rescue TradingService::Error => e
      flash[:alert] = e.message
    end

    redirect_to portfolio_path(@portfolio)
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find(params[:portfolio_id])
  end

  def trade_params
    params.expect(trade: [ :ticker, :action, :quantity, :price ])
  end
end
