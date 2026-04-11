When(/^I open the chatroom from the navigation bar$/) do
  within("nav[data-testid='main-nav']") do
    click_link "Chatroom"
  end
end

When(/^I visit the chatrooms page$/) do
  visit chatrooms_path
end

Then(/^I should see the chatroom heading$/) do
  expect(page).to have_css("h1", text: "Chatroom")
end

Then(/^I should see the chatroom sidebar$/) do
  expect(page).to have_css("[data-testid='chatroom-sidebar']")
end

When(/^I open a chat with "([^"]*)"$/) do |email|
  user = User.find_by!(email: email)
  find("[data-testid='chat-friend-link-#{user.id}']").click
end

Then(/^I should see the chat thread header for my friend$/) do
  expect(page).to have_content("Chatting with")
end

Then(/^I should see the chat message composer$/) do
  expect(page).to have_css("[data-testid='chat-message-form']")
end

Given(/^"([^"]+)" and "([^"]+)" are mutual friends$/) do |email_a, email_b|
  a = User.find_by(email: email_a) || FactoryBot.create(:user, email: email_a)
  b = User.find_by(email: email_b) || FactoryBot.create(:user, email: email_b)
  next if Friendship.accepted_between?(a, b)

  FactoryBot.create(:friendship, user: a, friend: b, status: :accepted)
end

Given(/^user "([^"]+)" is chatting with "([^"]+)" in session :(\w+)$/) do |me_email, other_email, session_name|
  me    = User.find_by!(email: me_email)
  other = User.find_by!(email: other_email)
  sym = session_name.to_sym
  @session_chat_urls ||= {}
  Capybara.using_session(sym) do
    login_as(me, scope: :user)
    visit chatrooms_path(friend_id: other.id)
    expect(page).to have_css("[data-testid='chat-message-form']", wait: 15)
    @session_chat_urls[sym] = page.current_url
  end
end

When(/^user "([^"]+)" sends chat message "([^"]*)" in session :(\w+)$/) do |_email, text, session_name|
  Capybara.using_session(session_name.to_sym) do
    expect(page).to have_css("[data-testid='chat-message-input']", wait: 15)
    find("[data-testid='chat-message-input']").set(text)
    find("[data-testid='chat-send-button']").click
    within("[data-testid='chat-messages']") do
      expect(page).to have_content(text, wait: 15)
    end
  end
end

Then(/^session :(\w+) should see "([^"]*)" within (\d+) seconds$/) do |session_name, text, seconds|
  sym = session_name.to_sym
  expect(Message.where(content: text)).to exist

  Capybara.using_session(sym) do
    chat_url = @session_chat_urls&.fetch(sym, nil) || page.current_url
    deadline = Time.now + seconds.to_i
    found = false
    while Time.now < deadline
      if page.has_content?(text, wait: 0.75)
        found = true
        break
      end
      visit chat_url
      sleep 0.35
    end
    expect(found).to be(true), %(expected to find #{text.inspect} within #{seconds}s (Turbo Stream or reload))
  end
end
