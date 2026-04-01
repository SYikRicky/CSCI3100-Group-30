FactoryBot.define do
  factory :trade do
    association :portfolio
    association :stock

    action { "buy" }
    quantity { 10 }
    price_at_trade { 150.0 }
    executed_at { Time.current }
  end
end
