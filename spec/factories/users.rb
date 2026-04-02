FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@cuhk.edu.hk" }
    sequence(:display_name) { |n| "User#{n}" }
    password { "password123" }
  end
end
