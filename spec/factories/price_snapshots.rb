FactoryBot.define do
  factory :price_snapshot do
    association :stock
    recorded_at { Time.zone.parse("2023-01-03 09:30:00") }
    open        { 148.50 }
    high        { 150.00 }
    low         { 147.80 }
    close       { 149.20 }
    price       { 149.20 }
    volume      { 3500.0 }
  end
end
