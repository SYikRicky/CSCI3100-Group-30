class PortfoliosController < ApplicationController
  before_action :set_portfolio

  def show
    @holdings = @portfolio.holdings.includes(:stock).order("stocks.ticker ASC")
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find(params[:id])
  end
end
