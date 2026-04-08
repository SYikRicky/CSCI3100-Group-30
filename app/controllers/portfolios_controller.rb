class PortfoliosController < ApplicationController
  before_action :set_portfolio

  def show
    @holdings   = @portfolio.holdings.includes(:stock).order("stocks.ticker ASC")
    @all_stocks = Stock.all.each_with_object({}) do |s, h|
      h[s.ticker] = { name: s.company_name, price: s.last_price.to_f }
    end
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end
end
