class AdvancePriceJob < ApplicationJob
  queue_as :default

  # Must match the constants in stocks/show.html.erb
  STEPS           = 60
  TICK_MS         = 1000
  CANDLE_GAP_MS   = 0
  CANDLE_TOTAL_MS = (STEPS * TICK_MS) + CANDLE_GAP_MS  # 60_000 ms = 1 minute per candle
  INITIAL_COUNT   = 50

  def perform
    server_start_ms = Rails.application.config.server_start_time.to_i * 1000
    elapsed_ms      = (Time.current.to_f * 1000).to_i - server_start_ms
    skip_count      = (elapsed_ms / CANDLE_TOTAL_MS).floor

    Stock.find_each do |stock|
      snapshots = PriceSnapshot.where(stock_id: stock.id)
                               .order(:recorded_at)
                               .pluck(:close)

      next if snapshots.empty?

      current_index = [INITIAL_COUNT + skip_count, snapshots.length - 1].min
      current_price = snapshots[current_index]

      stock.update_columns(
        last_price:     current_price,
        last_synced_at: Time.current
      )
    end
  end
end
