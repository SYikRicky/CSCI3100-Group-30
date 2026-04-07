class StocksController < ApplicationController
  before_action :set_stock, only: [ :show, :ohlcv ]

  def index
    @stocks = Stock.all
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
          volume:    group.sum { |r| r[5].to_f },
        }
      end

    render json: candles
  end

  def show
    ensure_owner_portfolios
    @portfolios = current_user.portfolios.includes(:league)
    @portfolio_cash = @portfolios.each_with_object({}) { |p, h| h[p.id] = p.cash_balance.to_f }
    holding_rows = Holding.where(portfolio_id: @portfolios.map(&:id), stock_id: @stock.id)
    @my_holdings = holding_rows.each_with_object({}) do |h, memo|
      memo[h.portfolio_id] = { quantity: h.quantity.to_f, average_cost: h.average_cost.to_f }
    end

    # All holdings across all portfolios (for bottom panel)
    @all_holdings = Holding.where(portfolio_id: @portfolios.map(&:id))
                           .includes(:stock)
                           .each_with_object({}) do |h, memo|
      (memo[h.portfolio_id] ||= []) << {
        ticker: h.stock.ticker,
        company: h.stock.company_name,
        quantity: h.quantity.to_f,
        average_cost: h.average_cost.to_f,
        current_price: h.stock.last_price.to_f,
        stock_id: h.stock_id
      }
    end

    # Pending orders per portfolio
    @pending_orders = Trade.where(portfolio_id: @portfolios.map(&:id), status: "pending")
                          .includes(:stock)
                          .each_with_object({}) do |t, memo|
      (memo[t.portfolio_id] ||= []) << {
        id: t.id,
        ticker: t.stock.ticker,
        action: t.action,
        order_type: t.order_type,
        quantity: t.quantity.to_f,
        limit_price: t.limit_price&.to_f,
        stop_price: t.stop_price&.to_f,
        created_at: t.created_at.strftime("%b %d %H:%M")
      }
    end

    # Recent filled/cancelled trades per portfolio (last 20)
    @trade_history = Trade.where(portfolio_id: @portfolios.map(&:id))
                         .where.not(status: "pending")
                         .includes(:stock)
                         .order(created_at: :desc)
                         .limit(50)
                         .each_with_object({}) do |t, memo|
      (memo[t.portfolio_id] ||= []) << {
        ticker: t.stock.ticker,
        action: t.action,
        order_type: t.order_type,
        quantity: t.quantity.to_f,
        price: t.price_at_trade&.to_f,
        status: t.status,
        executed_at: t.executed_at&.strftime("%b %d %H:%M"),
        created_at: t.created_at.strftime("%b %d %H:%M")
      }
    end
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
