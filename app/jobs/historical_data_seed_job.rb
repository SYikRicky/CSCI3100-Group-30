class HistoricalDataSeedJob < ApplicationJob
  queue_as :default

  def perform(stock_id, start_date, end_date)
    stock = Stock.find(stock_id)

    service = TiingoService.new
    data_points = service.fetch_historical_prices(
      ticker: stock.ticker,
      start_date: start_date,
      end_date: end_date
    )

    return if data_points.empty?

    rows = data_points.map do |point|
      {
        stock_id: stock.id,
        recorded_at: point[:recorded_at],
        price: point[:price],
        open: point[:open],
        high: point[:high],
        low: point[:low],
        close: point[:close],
        volume: point[:volume],
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    PriceSnapshot.insert_all!(rows)

    latest = data_points.max_by { |p| p[:recorded_at] }
    stock.update!(
      last_price: latest[:close],
      last_synced_at: Time.current
    )
  end
end
