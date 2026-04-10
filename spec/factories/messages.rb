FactoryBot.define do
  factory :message do
    content { "Hello friend" }
    association :sender, factory: :user
    association :receiver, factory: :user

    trait :between_friends do
      after(:build) do |msg|
        next if Friendship.accepted_between?(msg.sender, msg.receiver)

        FactoryBot.create(:friendship, user: msg.sender, friend: msg.receiver, status: :accepted)
      end
    end
  end
end
