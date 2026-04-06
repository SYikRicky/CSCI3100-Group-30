When(/^I visit the league page$/) do
  visit league_path(@league)
end

Then(/^I should see the sidebar tab "([^"]+)"$/) do |label|
  expect(page).to have_css("[data-testid='sidebar-tab-#{label.downcase}']", visible: :all)
end

Then(/^the details panel should contain "([^"]+)"$/) do |text|
  expect(page).to have_css("[data-testid='sidebar-panel-details']", text: text, visible: :all)
end

Then(/^the members panel should contain "([^"]+)"$/) do |text|
  expect(page).to have_css("[data-testid='sidebar-panel-members']", text: text, visible: :all)
end

When(/^I invite "([^"]+)" to the league from the sidebar$/) do |identifier|
  visit league_path(@league)
  within("[data-testid='sidebar-panel-members']") do
    fill_in "identifier", with: identifier
    click_button "Invite"
  end
end

Then(/^I should see a "([^"]+)" nav link$/) do |text|
  within("nav[data-testid='main-nav']") do
    expect(page).to have_link(text)
  end
end
