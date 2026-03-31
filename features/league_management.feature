Feature: League Management

  As competition organizer
  So that I can only invite valid members to join the league 
  I want to organize different leagues with the specific invite code

  Scenario: Owner creates a league
    Given I am signed in as "alice@cuhk.edu.hk"
    When I create a league with starting capital of 100000
    Then "League was successfully created" should be shown on the page

  Scenario: Participant joins via invite code
    Given a league exists with invite code "ABC123"
    And I am signed in as "bob@cuhk.edu.hk"
    When I join the league using invite code "ABC123"
    Then I should have a portfolio with cash balance of 100000

  Scenario: Non-member cannot view a league's portfolio
    Given a league exists
    And I am signed in as a non-member
    When I try to view the league's portfolio
    Then I should see "Not authorized"
