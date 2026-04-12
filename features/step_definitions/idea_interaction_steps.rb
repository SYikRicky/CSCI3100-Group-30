Given(/^an idea exists with title "([^"]*)" by "([^"]*)" with (\d+) views$/) do |title, email, views|
  author = User.find_by(email: email) || FactoryBot.create(:user, email: email)
  FactoryBot.create(:idea, title: title, user: author, published_at: Time.current, views_count: views.to_i)
end

Given(/^I have liked the idea "([^"]*)"$/) do |title|
  idea = Idea.find_by!(title: title)
  IdeaLike.create!(idea: idea, user: @user)
end

When(/^I visit the idea page for "([^"]*)"$/) do |title|
  idea = Idea.find_by!(title: title)
  visit idea_path(idea)
end

When(/^I click the like button$/) do
  find("[data-testid='like-button'] button").click
end

When(/^I fill in the comment form with "([^"]*)"$/) do |text|
  within("[data-testid='comment-form']") do
    fill_in "idea_comment_body", with: text
  end
end

When(/^I submit the comment form$/) do
  within("[data-testid='comment-form']") do
    click_button "Post Comment"
  end
end

Then(/^the like count should be (\d+)$/) do |count|
  within("[data-testid='like-button']") do
    expect(page).to have_content(count.to_s)
  end
end

Then(/^I should see "([^"]*)" in the comments section$/) do |text|
  within("[data-testid='comments-section']") do
    expect(page).to have_content(text)
  end
end

Then(/^the idea "([^"]*)" should have (\d+) views$/) do |title, expected_views|
  idea = Idea.find_by!(title: title)
  expect(idea.reload.views_count).to eq(expected_views.to_i)
end
