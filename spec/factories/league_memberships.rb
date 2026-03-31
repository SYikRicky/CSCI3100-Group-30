FactoryBot.define do
  factory :league_membership do
    user { nil }
    league { nil }
    role { 1 }
  end
end
