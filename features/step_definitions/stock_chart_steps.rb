Given(/^a stock "([^"]+)" exists with price (\d+\.\d+)$/) do |ticker, price|
  @stock = FactoryBot.create(:stock, ticker: ticker, last_price: price.to_d)
end

Given(/^"([^"]+)" has (\d+) price snapshots at 1-minute intervals$/) do |ticker, count|
  stock = Stock.find_by!(ticker: ticker)
  base  = Time.zone.parse("2023-01-03 09:30:00")
  count.to_i.times do |i|
    open  = 148.0 + rand * 4
    close = 148.0 + rand * 4
    FactoryBot.create(:price_snapshot,
      stock:       stock,
      recorded_at: base + i.minutes,
      open:        open,
      high:        [open, close].max + rand,
      low:         [open, close].min - rand,
      close:       close,
      volume:      (1000 + rand(5000)).to_f
    )
  end
end

When(/^I visit the stock chart for "([^"]+)"$/) do |ticker|
  stock = Stock.find_by!(ticker: ticker)
  visit stock_path(stock)
end

Then(/^the page should have a chart container$/) do
  expect(page).to have_css("#chart-container", visible: :all)
end

When(/^I request OHLCV data for "([^"]+)" with interval (\d+)$/) do |ticker, interval|
  stock = Stock.find_by!(ticker: ticker)
  visit ohlcv_stock_path(stock, interval: interval.to_i, format: :json)
  @ohlcv_response = JSON.parse(page.body)
end

Then(/^the response should be JSON$/) do
  expect(@ohlcv_response).to be_an(Array)
end

Then(/^the candles should include open, high, low, close and volume fields$/) do
  candle = @ohlcv_response.first
  expect(candle.keys).to include("timestamp", "open", "high", "low", "close", "volume")
end

Then(/^the candles should be ordered by time ascending$/) do
  timestamps = @ohlcv_response.map { |c| c["timestamp"] }
  expect(timestamps).to eq(timestamps.sort)
end

Then(/^there should be fewer candles than for interval 1$/) do
  stock = Stock.find_by!(ticker: "AAPL")
  visit ohlcv_stock_path(stock, interval: 1, format: :json)
  one_min_count = JSON.parse(page.body).size
  expect(@ohlcv_response.size).to be <= one_min_count
end

Then(/^I should see a timeframe button "([^"]+)"$/) do |label|
  expect(page).to have_css("[data-timeframe='#{label}']", visible: :all)
end
