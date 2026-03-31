Feature: User Authentication

    # phase 1 - step 1 - cucumber scenarios
    
    Scenario: User signs up
        Given I am on the sign up page
        When I fill in valid registration details
        Then I should be signed in and see "Welcome"

    Scenario: User signs in
        Given a user exists with email "alice@cuhk.edu.hk"
        When I sign in with correct credentials
        Then I should see the dashboard
    
    Scenario: User cannot access leagues when logged out
        When I visit the leagues page without signing in
        Then I should be redirected to the sign in page