class StocksController < ApplicationController
  before_action :set_stock, only: [ :show, :ohlcv ]
  def index
    @stocks = Stock.all
    # Session-open reference: open of the latest snapshot per ticker
    @day_open = {}
    Stock.find_each do |stock|
      snap = PriceSnapshot.where(stock_id: stock.id).order(:recorded_at).last
      @day_open[stock.ticker] = snap&.open.to_f
    end
  end

  def prices
    tickers = params[:tickers].to_s.split(",").map(&:strip).map(&:upcase)
    stocks  = tickers.any? ? Stock.where(ticker: tickers) : Stock.all
    render json: stocks.each_with_object({}) { |s, h| h[s.ticker] = s.last_price.to_f }
  end

  def ohlcv
    interval     = (params[:interval] || 1).to_i.clamp(1, 1440)
    interval_sec = interval * 60

    rows = PriceSnapshot
      .where(stock_id: @stock.id)
      .order(:recorded_at)
      .pluck(:recorded_at, :open, :high, :low, :close, :volume)

    candles = rows
      .group_by { |r| (r[0].to_i / interval_sec) * interval_sec }
      .map do |bucket_time, group|
        {
          timestamp: bucket_time,
          open:      group.first[1].to_f,
          high:      group.map { |r| r[2].to_f }.max,
          low:       group.map { |r| r[3].to_f }.min,
          close:     group.last[4].to_f,
          volume:    group.sum { |r| r[5].to_f }
        }
      end

    render json: candles
  end

  def show
    ensure_owner_portfolios
    @portfolios = current_user.portfolios.includes(:league)
    presenter = StockShowPresenter.new(stock: @stock, portfolios: @portfolios)
    @portfolio_cash = presenter.portfolio_cash
    @my_holdings    = presenter.my_holdings
    @all_holdings   = presenter.all_holdings
    @pending_orders = presenter.pending_orders
    @trade_history  = presenter.trade_history
  end

  private

  def set_stock
    @stock = Stock.find(params[:id])
  end

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
