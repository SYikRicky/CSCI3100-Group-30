FactoryBot.define do
  factory :league do
    name { Faker::App.name }
    description { Faker::Lorem.sentence }
    association :owner, factory: :user
    starting_capital { 100_000 }
    status { "active" }
    starts_at { Time.current }
    ends_at { 1.weeks.from_now }
    invite_code { SecureRandom.alphanumeric(6).upcase }
  end
end
