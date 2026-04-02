FactoryBot.define do
  factory :notification do
    association :user
    kind  { :system }
    title { "System Message" }
    body  { "This is a system notification." }
    read_at { nil }
  end
end
