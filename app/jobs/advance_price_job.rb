class AdvancePriceJob < ApplicationJob
  queue_as :default

  LOOKBACK    = 100  # candles used to calibrate GBM
  TICKS       = 60   # sub-ticks per 1-minute candle (matches SUB_TICK_MS=500 × 120 ≈ 60s)

  def perform
    now = Time.current

    Stock.find_each do |stock|
      snaps = PriceSnapshot.where(stock_id: stock.id)
                           .order(:recorded_at)
                           .last(LOOKBACK)
      next if snaps.empty?

      last_snap  = snaps.last
      next_time  = last_snap.recorded_at + 1.minute

      # Avoid duplicate if job runs twice in the same minute
      next if PriceSnapshot.exists?(stock_id: stock.id, recorded_at: next_time)

      mu, sigma = calibrate_gbm(snaps)
      candle    = generate_candle(last_snap.close.to_f, mu, sigma)

      PriceSnapshot.create!(
        stock_id:    stock.id,
        recorded_at: next_time,
        open:        candle[:open],
        high:        candle[:high],
        low:         candle[:low],
        close:       candle[:close],
        volume:      candle[:volume]
      )

      stock.update_columns(last_price: candle[:close], last_synced_at: now)
    end
  end

  private

  def calibrate_gbm(snaps)
    closes  = snaps.map { |s| s.close.to_f }
    returns = closes.each_cons(2).map { |a, b| Math.log(b / a) rescue 0 }
    return [0.0, 0.012] if returns.length < 2

    n        = returns.length
    mean     = returns.sum / n
    variance = returns.map { |r| (r - mean)**2 }.sum / [n - 1, 1].max
    sigma    = [Math.sqrt(variance), 0.003].max
    [mean, sigma]
  end

  def generate_candle(prev_close, mu, sigma)
    open  = prev_close
    close = prev_close
    high  = open
    low   = open
    vol   = 0.0
    dt    = 1.0 / TICKS

    TICKS.times do
      z     = randn
      close = close * Math.exp((mu - 0.5 * sigma * sigma) * dt + sigma * Math.sqrt(dt) * z)
      high  = [high,  close].max
      low   = [low,   close].min
      vol  += (z.abs * 800 + 200) * dt
    end

    { open: open, high: high, low: low, close: close, volume: vol }
  end

  def randn
    u = rand; u = rand while u == 0
    Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math::PI * rand)
  end
end
