# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ── Stocks + Historical Price Data (1 year from Alpaca) ──
stocks_seed = [
  { ticker: "AAPL", company_name: "Apple Inc." },
  { ticker: "MSFT", company_name: "Microsoft Corporation" },
  { ticker: "GOOGL", company_name: "Alphabet Inc. (Class A)" },
  { ticker: "AMZN", company_name: "Amazon.com, Inc." },
  { ticker: "NVDA", company_name: "NVIDIA Corporation" },
  { ticker: "TSLA", company_name: "Tesla, Inc." },
  { ticker: "META", company_name: "Meta Platforms, Inc." },
  { ticker: "IBM", company_name: "International Business Machines" },
  { ticker: "JPM", company_name: "JPMorgan Chase & Co." },
  { ticker: "V", company_name: "Visa Inc." },
  { ticker: "JNJ", company_name: "Johnson & Johnson" },
  { ticker: "UNH", company_name: "UnitedHealth Group Incorporated" },
  { ticker: "WMT", company_name: "Walmart Inc." },
  { ticker: "PG", company_name: "The Procter & Gamble Company" },
  { ticker: "HD", company_name: "The Home Depot, Inc." },
  { ticker: "MA", company_name: "Mastercard Incorporated" },
  { ticker: "BAC", company_name: "Bank of America Corporation" },
  { ticker: "XOM", company_name: "Exxon Mobil Corporation" },
  { ticker: "CVX", company_name: "Chevron Corporation" },
  { ticker: "KO", company_name: "The Coca-Cola Company" },
  { ticker: "COST", company_name: "Costco Wholesale Corporation" },
  { ticker: "PEP", company_name: "PepsiCo, Inc." },
  { ticker: "MCD", company_name: "McDonald's Corporation" },
  { ticker: "CRM", company_name: "Salesforce, Inc." },
  { ticker: "AMD", company_name: "Advanced Micro Devices, Inc." },
  { ticker: "NFLX", company_name: "Netflix, Inc." },
  { ticker: "NKE", company_name: "NIKE, Inc." },
  { ticker: "DIS", company_name: "The Walt Disney Company" },
  { ticker: "INTC", company_name: "Intel Corporation" },
  { ticker: "SBUX", company_name: "Starbucks Corporation" }
]

stocks_seed.each do |attrs|
  Stock.find_or_create_by!(ticker: attrs[:ticker]) do |s|
    s.company_name = attrs[:company_name]
  end
end
puts "Stocks: #{Stock.count} total"

# Fetch 1 year of historical data from Alpaca (skip if already seeded)
start_date = "2023-01-01"
end_date   = "2024-01-01"

Stock.find_each.with_index do |stock, idx|
  next if stock.price_snapshots.exists?

  puts "[#{idx + 1}/#{Stock.count}] Fetching #{stock.ticker}..."
  HistoricalDataSeedJob.perform_now(stock.id, start_date, end_date)
  puts "  → #{stock.price_snapshots.count} snapshots"
rescue => e
  puts "  ⚠ Skipped #{stock.ticker}: #{e.message}"
end

puts "Total price snapshots: #{PriceSnapshot.count}"

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
