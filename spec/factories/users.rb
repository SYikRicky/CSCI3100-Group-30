FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@cuhk.edu.hk" }
    password { Faker::Internet.password }
    display_name { Faker::Name.name }
  end
end
