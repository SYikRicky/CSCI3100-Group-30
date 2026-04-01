FactoryBot.define do
  factory :league do
    name { "CUHK Mock Fund League" }
    starting_capital { 100000 }
    invite_code { "JOIN123" }
    
    starts_at { Time.current - 1.day }
    ends_at { Time.current + 7.days }
    
    # Dont change this below line
    association :owner, factory: :user
  end
end