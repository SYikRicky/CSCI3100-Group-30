FactoryBot.define do
  factory :message do
    association :sender, factory: :user
    association :receiver, factory: :user
    content { "Hello there!" }
    read_at { nil }
  end
end
