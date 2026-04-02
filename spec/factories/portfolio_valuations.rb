FactoryBot.define do
  factory :portfolio_valuation do
    association :portfolio
    valued_at { Time.current }
    cash_value { 1000.0 }
    holdings_value { 500.0 }
    total_value { 1500.0 }
  end
end
