FactoryBot.define do
  factory :idea_comment do
    association :idea
    association :user
    body { "Great analysis, I agree with this thesis." }
  end
end
