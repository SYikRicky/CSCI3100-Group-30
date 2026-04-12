FactoryBot.define do
  factory :idea_tagging do
    association :idea
    association :idea_tag
  end
end
