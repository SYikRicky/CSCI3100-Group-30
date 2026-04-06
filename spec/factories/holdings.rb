FactoryBot.define do
  factory :holding do
    association :portfolio
    association :stock
    quantity { 10 }
    average_cost { 100.0 }
  end
end
