class StocksController < ApplicationController
  def index
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
    ensure_owner_portfolios
    @portfolios = current_user.portfolios.includes(:league)
    @portfolio_cash = @portfolios.each_with_object({}) { |p, h| h[p.id] = p.cash_balance.to_f }
    holding_rows = Holding.where(portfolio_id: @portfolios.map(&:id), stock_id: @stock.id)
    @my_holdings = holding_rows.each_with_object({}) do |h, memo|
      memo[h.portfolio_id] = { quantity: h.quantity.to_f, average_cost: h.average_cost.to_f }
    end
    @chart_data = PriceSnapshot.where(stock_id: @stock.id)
                               .order(:recorded_at)
                               .map do |s|
                                 {
                                   time:  s.recorded_at.to_i,
                                   open:  s.open.to_f,
                                   high:  s.high.to_f,
                                   low:   s.low.to_f,
                                   close: s.close.to_f
                                 }
                               end
                               .uniq { |d| d[:time] }
                               .to_json
  end

  private

  def ensure_owner_portfolios
    current_user.owned_leagues.each do |league|
      unless Portfolio.exists?(user: current_user, league: league)
        Portfolio.create!(user: current_user, league: league, cash_balance: league.starting_capital)
      end
      unless LeagueMembership.exists?(user: current_user, league: league)
        LeagueMembership.create!(user: current_user, league: league, role: :owner)
      end
    end
  end
end
