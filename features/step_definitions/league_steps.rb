Given(/^I am signed in as "(.*)"$/) do |user_email|
  user = FactoryBot.create(:user, email: user_email)
  login_as(user, scope: :user)
end

When(/^I create a league with starting capital of (.*)$/) do |capital_amount|
  visit new_league_path
  fill_in "Starting Capital",	with: capital_amount
  click_button "create"
end

Then(/^"(.*)" should be shown on the page$/) do |message|
  expect(page).to have_content(message)
end

# And(/the league with random id (.*) should appear on the leagues page/) do |id|
#   league = Factory.create(:factory, id: id)
#   visit main_path
#   expect(page).to have_content(league)
# end

Given(/a league exists with invite code "(.*)"/) do |code|
  @league = FactoryBot.create(:league, invite_code: code)
end

And(/^I am signed in as "(.*)"$/) do |user_email|
  @user = FactoryBot.create(:user, email: user_email)
  login_as(@user, scope: :user)
end

When(/I join the league using invite code "(.*)"/) do |code|
  visit join_league_path
  fill_in "Invite Code",	with: code
  click_button "OK"
end

Then(/I should have a portfolio with cash balance of (.*)/) do |balance|
  portfolio = @user.portfolios.find_by(league: @league)
  expect(portfolio.balance).to eq(balance.to_d)
end

Given(/a league exists/) do
  @league = FactoryBot.create(:league)
end

Given(/I am signed in as a non-member/) do
  @user = FactoryBot.create(:user)
  login_as(@user, scope: :user)
end

When(/I try to view the league's portfolio/) do
  visit league_path(@league)
end

Then(/I should see "(.*)"/) do |message|
  expect(page).to have_content(message)
end
