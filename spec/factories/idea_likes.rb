FactoryBot.define do
  factory :idea_like do
    association :idea
    association :user
  end
end
