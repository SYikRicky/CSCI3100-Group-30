Given('I am on the sign up page') do
    visit new_user_registration_path
end

When('I fill in valid registration details') do
    fill_in 'Email', with: 'andrewtate@cuhk.edu.hk'
    fill_in 'Password', with: 'andrewtate123'
    fill_in 'Password confirmation', with: 'andrewtate123'
    fill_in 'Display name', with: 'Andrew Tate'
    click_button 'Sign up'
end

Then('I should be signed in and see {string}') do |expected_text|
    expect(page).to have_content(/Welcome|Signed in/) 
end

Given('a user exists with email {string}') do |email|
    @user = User.create!(
        email: email, 
        password: 'password123', 
        password_confirmation: 'password123',
        display_name: 'Alice'
    )
end

When('I sign in with correct credentials') do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password123'
  click_button 'Log in'
end

Then('I should see the dashboard') do
   
  # Temporary page, expected to be on the root page - Leagues index
  # Should be modified once Phase 2 is completed

  expect(current_path).to eq(root_path)
end

When('I visit the leagues page without signing in') do
  visit leagues_path
end

Then('I should be redirected to the sign in page') do
  expect(current_path).to eq(new_user_session_path)
end
