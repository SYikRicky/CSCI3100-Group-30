Given(/^a user exists with email "([^"]+)" and display name "([^"]+)"$/) do |email, name|
  @other_user = FactoryBot.create(:user, email: email, display_name: name)
end

When(/^I send a friend request to "(.*)"$/) do |identifier|
  visit friendships_path
  fill_in "identifier", with: identifier
  click_button "Send Friend Request"
end

Given(/^a pending friend request from "(.*)" to "(.*)"$/) do |sender_email, receiver_email|
  sender   = FactoryBot.create(:user, email: sender_email)
  receiver = FactoryBot.create(:user, email: receiver_email)
  FactoryBot.create(:friendship, user: sender, friend: receiver, status: :pending)
end

When(/^I accept the friend request from "(.*)"$/) do |sender_email|
  sender     = User.find_by!(email: sender_email)
  friendship = Friendship.find_by!(user: sender, friend: @user)
  visit friendships_path
  within("#friendship-#{friendship.id}") do
    click_button "Accept"
  end
end

Given(/^"(.*)" is my accepted friend$/) do |friend_email|
  friend = FactoryBot.create(:user, email: friend_email)
  FactoryBot.create(:friendship, user: @user, friend: friend, status: :accepted)
end

When(/^I visit the friends page$/) do
  visit friendships_path
end
