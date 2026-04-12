FactoryBot.define do
  factory :idea_tag do
    sequence(:name) { |n| "Tag #{n}" }
  end
end
