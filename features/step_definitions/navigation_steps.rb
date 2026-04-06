When(/^I visit the leagues page$/) do
  visit leagues_path
end

When(/^I visit the home page without signing in$/) do
  visit root_path
end

Then(/^I should see the navigation bar$/) do
  expect(page).to have_css("nav[data-testid='main-nav']")
end

Then(/^the logo should link to the home page$/) do
  within("nav[data-testid='main-nav']") do
    expect(page).to have_css("a[href='#{root_path}']")
  end
end

Then(/^I should see the friend panel button$/) do
  expect(page).to have_css("[data-testid='friend-panel-btn']")
end

Then(/^I should not see the friend panel button$/) do
  expect(page).not_to have_css("[data-testid='friend-panel-btn']")
end

Then(/^the friend panel should contain "(.*)"$/) do |text|
  expect(page).to have_css("[data-testid='friend-panel']", text: text, visible: :all)
end
