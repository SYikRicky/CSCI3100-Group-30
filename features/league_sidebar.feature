Feature: League Show Page Sidebar

  As a league member
  So that I can manage and view league details without cluttering the main page
  I want a collapsible right sidebar with a Members panel and a Details panel

  Scenario: Sidebar tab buttons appear on the league show page
    Given I am signed in as "alice@cuhk.edu.hk"
    And I own a league named "Alpha League"
    When I visit the league page
    Then I should see the sidebar tab "Members"
    And I should see the sidebar tab "Details"

  Scenario: Details panel contains the league name
    Given I am signed in as "alice@cuhk.edu.hk"
    And I own a league named "Alpha League"
    When I visit the league page
    Then the details panel should contain "Alpha League"

  Scenario: Details panel contains the invite code for the owner
    Given I am signed in as "alice@cuhk.edu.hk"
    And I own a league named "Alpha League"
    When I visit the league page
    Then the details panel should contain "Invite code"

  Scenario: Members panel lists the league owner
    Given I am signed in as "alice@cuhk.edu.hk"
    And I own a league named "Alpha League"
    When I visit the league page
    Then the members panel should contain "alice@cuhk.edu.hk"

  Scenario: Owner can invite a new member from the sidebar
    Given I am signed in as "alice@cuhk.edu.hk"
    And I own a league named "Alpha League"
    And a user exists with email "bob@cuhk.edu.hk"
    When I invite "bob@cuhk.edu.hk" to the league from the sidebar
    Then "bob@cuhk.edu.hk" should be a member of the league

  Scenario: Leagues link appears in the navigation bar
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then I should see a "Leagues" nav link
