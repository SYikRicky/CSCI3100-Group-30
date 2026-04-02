FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@cuhk.edu.hk" }
    password { "password123" }
    display_name { "Alice" }
  end
end
