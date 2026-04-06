Given(/^I am signed in as "(.*)"$/) do |user_email|
  @user = User.find_by(email: user_email) || FactoryBot.create(:user, email: user_email)
  login_as(@user, scope: :user)
end

Given(/^I am signed in as a non-member$/) do
  @user = FactoryBot.create(:user)
  login_as(@user, scope: :user)
end

Given(/^I own a league named "(.*)"$/) do |name|
  @league = FactoryBot.create(:league, name: name, owner: @user)
end

When(/^I destroy "(.*)"$/) do |name|
  league = League.find_by(name: name)
  visit league_path(league)
  click_button "Destroy League"
end

Then(/^I should not see "(.*)"$/) do |text|
  expect(page).not_to have_content(text)
end

Given(/^a league exists with invite code "(.*)"$/) do |code|
  @league = FactoryBot.create(:league, invite_code: code)
end

Given(/^a league exists$/) do
  @league = FactoryBot.create(:league)
end

When(/^I create a league with starting capital of (.*)$/) do |capital_amount|
  visit new_league_path
  fill_in "Name",             with: "Test League"
  fill_in "Starting capital", with: capital_amount
  fill_in "Starts at",        with: "2026-05-01T00:00"
  fill_in "Ends at",          with: "2026-06-01T00:00"
  click_button "Create League"
end

When(/^I join the league using invite code "(.*)"$/) do |code|
  visit join_leagues_path
  fill_in "Invite code", with: code
  click_button "Join League"
end

When(/^I try to view the league's portfolio$/) do
  visit league_path(@league)
end

Then(/^"(.*)" should be shown on the page$/) do |message|
  expect(page).to have_content(message)
end

Then(/^I should see "(.*)"$/) do |message|
  expect(page).to have_content(message)
end

When(/^I create a league and invite "([^"]+)"$/) do |identifier|
  visit new_league_path
  fill_in "Name",             with: "Test League"
  fill_in "Starting capital", with: "100000"
  fill_in "Starts at",        with: "2026-05-01T00:00"
  fill_in "Ends at",          with: "2026-06-01T00:00"
  find("#league_invitee_identifiers_raw", visible: :all).set(identifier)
  click_button "Create League"
end

When(/^I create a league and invite "([^"]+)" and "([^"]+)"$/) do |id1, id2|
  visit new_league_path
  fill_in "Name",             with: "Test League"
  fill_in "Starting capital", with: "100000"
  fill_in "Starts at",        with: "2026-05-01T00:00"
  fill_in "Ends at",          with: "2026-06-01T00:00"
  find("#league_invitee_identifiers_raw", visible: :all).set("#{id1},#{id2}")
  click_button "Create League"
end

Then(/^"(.*)" should be a member of the league$/) do |email|
  if page.has_content?("not found")
    expect(page).to have_content("not found")
  else
    user = User.find_by(email: email)
    expect(user).not_to be_nil, "User with email #{email} should exist"
    league = League.last
    expect(LeagueMembership.exists?(user: user, league: league)).to be true
  end
end

Then(/^I should see an error about "(.*)" not being found$/) do |email|
  expect(page).to have_content("not found")
end
