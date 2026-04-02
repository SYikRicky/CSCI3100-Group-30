FactoryBot.define do
  factory :stock do
    ticker { "AAPL" }
    company_name { "Apple Inc" }
    last_price { 150.0 }
  end
end
