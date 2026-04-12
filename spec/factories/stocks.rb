FactoryBot.define do
  factory :stock do
    sequence(:ticker) { |n| "STK#{n}" }
    company_name { "Test Corp" }
    last_price { 150.0 }
  end
end
