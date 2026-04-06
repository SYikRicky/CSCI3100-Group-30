Given(/^"([^"]+)" has sent me a friend request$/) do |sender_email|
  sender = User.find_by(email: sender_email) || FactoryBot.create(:user, email: sender_email)
  FactoryBot.create(:friendship, user: sender, friend: @user, status: :pending)
end

Then(/^"([^"]+)" should have a notification containing "([^"]+)"$/) do |email, text|
  user = User.find_by!(email: email)
  expect(user.notifications.any? { |n| n.title.downcase.include?(text.downcase) || n.body.downcase.include?(text.downcase) }).to be true
end
