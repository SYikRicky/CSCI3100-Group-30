Feature: Site Navigation

  As a user
  So that I can move around the app easily
  I want a navigation bar and a quick-access friends panel

  Scenario: Navigation bar appears on every page
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then I should see the navigation bar

  Scenario: Logo in the navigation bar links to the home page
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then the logo should link to the home page

  Scenario: Friend panel button is visible when signed in
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then I should see the friend panel button

  Scenario: Friend panel button is not visible when signed out
    When I visit the home page without signing in
    Then I should not see the friend panel button

  Scenario: Friend panel shows accepted friends
    Given I am signed in as "alice@cuhk.edu.hk"
    And "bob@cuhk.edu.hk" is my accepted friend
    When I visit the leagues page
    Then the friend panel should contain "bob@cuhk.edu.hk"
