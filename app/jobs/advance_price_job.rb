class AdvancePriceJob < ApplicationJob
  queue_as :default

  # Must match the constants in stocks/show.html.erb
  STEPS           = 60
  TICK_MS         = 1000
  CANDLE_GAP_MS   = 0
  CANDLE_TOTAL_MS = (STEPS * TICK_MS) + CANDLE_GAP_MS  # 60_000 ms = 1 minute per candle
  INITIAL_COUNT   = 38560  # ~2023-06-01 starting point

  def perform
    server_start_ms = Rails.application.config.server_start_time.to_i * 1000
    elapsed_ms      = (Time.current.to_f * 1000).to_i - server_start_ms
    skip_count      = (elapsed_ms / CANDLE_TOTAL_MS).floor
    now             = Time.current

    # Batch all reads first, then do a single short transaction for writes
    # to minimize SQLite lock duration
    updates = []
    Stock.find_each do |stock|
      snapshots = PriceSnapshot.where(stock_id: stock.id)
                               .order(:recorded_at)
                               .pluck(:close)

      next if snapshots.empty?

      current_index = [ INITIAL_COUNT + skip_count - 1, snapshots.length - 1 ].min
      current_index = [ current_index, 0 ].max
      updates << { id: stock.id, price: snapshots[current_index] }
    end

    # Single transaction — holds write lock briefly instead of per-stock
    ActiveRecord::Base.transaction do
      updates.each do |u|
        Stock.where(id: u[:id]).update_all(last_price: u[:price], last_synced_at: now)
      end
    end
  end
end
