puts "Clearing existing data..."
PriceSnapshot.delete_all
Stock.delete_all
puts "Existing data cleared."

stocks_seed = [
  { ticker: "AAPL", company_name: "Apple Inc." },
  { ticker: "MSFT", company_name: "Microsoft Corporation" },
  { ticker: "GOOGL", company_name: "Alphabet Inc. (Class A)" },
  { ticker: "AMZN", company_name: "Amazon.com, Inc." },
  { ticker: "NVDA", company_name: "NVIDIA Corporation" },
  { ticker: "TSLA", company_name: "Tesla, Inc." },
  { ticker: "META", company_name: "Meta Platforms, Inc." },
  { ticker: 'IBM', company_name: 'International Business Machines' },
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
].freeze

puts "Creating stocks..."
stocks = stocks_seed.map { |attrs| Stock.create!(attrs) }
puts "Created #{stocks.size} stocks."

start_date = "2023-01-01"
end_date = "2024-01-01"

puts "Seeding historical price data (#{start_date} to #{end_date})..."
total_inserted = 0

stocks.each_with_index do |stock, idx|
  puts "[#{idx + 1}/#{stocks.size}] Fetching data for #{stock.ticker}..."

  before_count = PriceSnapshot.where(stock_id: stock.id).count
  HistoricalDataSeedJob.perform_now(stock.id, start_date, end_date)
  after_count = PriceSnapshot.where(stock_id: stock.id).count

  inserted = after_count - before_count
  total_inserted += inserted

  puts "Fetched #{stock.ticker}: inserted #{inserted} price snapshots (total so far: #{total_inserted})."
end

puts "Successfully seeded #{Stock.count} stocks and #{PriceSnapshot.count} price snapshots."
