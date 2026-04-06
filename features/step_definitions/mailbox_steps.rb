Given(/^I have a notification with title "([^"]+)" and body "([^"]+)"$/) do |title, body|
  FactoryBot.create(:notification, user: @user, title: title, body: body)
end

Then(/^I should see the mailbox button$/) do
  expect(page).to have_css("[data-testid='mailbox-btn']")
end

Then(/^I should not see the mailbox button$/) do
  expect(page).not_to have_css("[data-testid='mailbox-btn']")
end

Then(/^the mailbox dropdown should be in the page$/) do
  expect(page).to have_css("[data-testid='mailbox-dropdown']", visible: :all)
end

Then(/^the mailbox dropdown should contain "([^"]+)"$/) do |text|
  expect(page).to have_css("[data-testid='mailbox-dropdown']", text: text, visible: :all)
end
