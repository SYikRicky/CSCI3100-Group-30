Given(/^the following ideas exist:$/) do |table|
  table.hashes.each do |row|
    author = if row["author"]
      User.find_by(email: row["author"]) || FactoryBot.create(:user, email: row["author"])
    else
      FactoryBot.create(:user)
    end

    attrs = {
      user: author,
      title: row["title"],
      direction: row["direction"] || "long",
      published_at: row["published_at"] ? Time.zone.parse(row["published_at"]) : Time.current
    }

    FactoryBot.create(:idea, **attrs)
  end
end

Given(/^a stock exists with ticker "([^"]*)"$/) do |ticker|
  Stock.find_by(ticker: ticker) || FactoryBot.create(:stock, ticker: ticker, company_name: "#{ticker} Inc")
end

Given(/^an idea exists with title "([^"]*)" by "([^"]*)"$/) do |title, email|
  author = User.find_by(email: email) || FactoryBot.create(:user, email: email)
  FactoryBot.create(:idea, title: title, user: author, published_at: Time.current)
end

Given(/^an idea exists with title "([^"]*)"$/) do |title|
  FactoryBot.create(:idea, title: title, published_at: Time.current)
end

When(/^I visit the ideas page$/) do
  visit ideas_path
end

When(/^I visit the new idea page$/) do
  visit new_idea_path
end

When(/^I fill in the idea form with:$/) do |table|
  data = table.rows_hash
  fill_in "idea_title", with: data["Title"] if data["Title"]
  if data["Body"]
    find("input[name='idea[body]']", visible: :all).set(data["Body"])
  end

  if data["Direction"]
    choose "idea_direction_#{data['Direction']}"
  end

  if data["Stock"]
    select data["Stock"], from: "idea_stock_id"
  end
end

When(/^I submit the idea form$/) do
  click_button "Publish Idea"
end

When(/^I click on "([^"]*)"$/) do |text|
  click_link text
end

Then(/^I should see "([^"]*)" before "([^"]*)" on the page$/) do |first_text, second_text|
  expect(page.body.index(first_text)).to be < page.body.index(second_text)
end

Then(/^I should see the idea detail page for "([^"]*)"$/) do |title|
  expect(page).to have_css("[data-testid='idea-detail']")
  expect(page).to have_content(title)
end

Then(/^I should see the author information$/) do
  expect(page).to have_css("[data-testid='idea-author']")
end


Then(/^I should see an idea form error$/) do
  expect(page).to have_css("[data-testid='new-idea-form']")
end
