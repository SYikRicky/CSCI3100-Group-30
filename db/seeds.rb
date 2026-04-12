# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ── Stocks ──
stocks_data = [
  { ticker: "AAPL",  company_name: "Apple Inc." },
  { ticker: "GOOGL", company_name: "Alphabet Inc." },
  { ticker: "MSFT",  company_name: "Microsoft Corporation" },
  { ticker: "AMZN",  company_name: "Amazon.com Inc." },
  { ticker: "TSLA",  company_name: "Tesla Inc." },
  { ticker: "META",  company_name: "Meta Platforms Inc." },
  { ticker: "NVDA",  company_name: "NVIDIA Corporation" },
  { ticker: "JPM",   company_name: "JPMorgan Chase & Co." },
  { ticker: "V",     company_name: "Visa Inc." },
  { ticker: "JNJ",   company_name: "Johnson & Johnson" }
]

stocks_data.each do |data|
  Stock.find_or_create_by!(ticker: data[:ticker]) do |s|
    s.company_name = data[:company_name]
  end
end

# Fetch historical price data from Alpaca (last 2 trading days)
if ENV.fetch("SKIP_STOCK_DATA", nil).blank?
  start_date = 2.business_days.ago.to_date.to_s rescue 3.days.ago.to_date.to_s
  end_date   = Date.current.to_s

  Stock.find_each do |stock|
    next if stock.price_snapshots.exists?

    puts "  Fetching price data for #{stock.ticker}..."
    HistoricalDataSeedJob.perform_now(stock.id, start_date, end_date)
  rescue => e
    puts "  ⚠ Skipped #{stock.ticker}: #{e.message}"
  end
end

# ── Idea tags for the Community feature ──
%w[
  Technical\ Analysis
  Fundamental\ Analysis
  Earnings
  Macro
  Sector\ Rotation
  Swing\ Trade
  Day\ Trade
  Long\ Term
].each { |name| IdeaTag.find_or_create_by!(name: name) }
