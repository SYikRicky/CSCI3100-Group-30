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

Then(/^I should see a "Friends" link in the navigation bar$/) do
  within("nav[data-testid='main-nav']") do
    expect(page).to have_link("Friends")
  end
end

Then(/^I should not see a "Friends" link in the navigation bar$/) do
  within("nav[data-testid='main-nav']") do
    expect(page).not_to have_link("Friends")
  end
end
