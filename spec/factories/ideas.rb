FactoryBot.define do
  factory :idea do
    association :user
    association :stock
    sequence(:title) { |n| "Trading Idea #{n}" }
    body { "This is my analysis of the stock price action and fundamentals." }
    direction { :long }
    published_at { Time.current }
    views_count { 0 }
  end
end
