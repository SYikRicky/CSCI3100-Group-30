FactoryBot.define do
  factory :portfolio do
    association :user
    association :league
    cash_balance { 100000.0 }
  end
end
