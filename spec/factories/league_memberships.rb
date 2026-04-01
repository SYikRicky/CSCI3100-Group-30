FactoryBot.define do
  factory :league_membership do
    association :user
    association :league
    role { :participant }
  end
end
