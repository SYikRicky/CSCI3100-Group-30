Feature: Friend System

  As a user
  So that I can easily invite people I know to my leagues
  I want to manage a list of friends

  Scenario: User sends a friend request by email
    Given I am signed in as "alice@cuhk.edu.hk"
    And a user exists with email "bob@cuhk.edu.hk"
    When I send a friend request to "bob@cuhk.edu.hk"
    Then I should see "Friend request sent"

  Scenario: User sends a friend request by display name
    Given I am signed in as "alice@cuhk.edu.hk"
    And a user exists with email "bob@cuhk.edu.hk" and display name "Bobby"
    When I send a friend request to "Bobby"
    Then I should see "Friend request sent"

  Scenario: User cannot send a friend request to a non-existent user
    Given I am signed in as "alice@cuhk.edu.hk"
    When I send a friend request to "ghost@cuhk.edu.hk"
    Then I should see "User not found"

  Scenario: User accepts a friend request
    Given a pending friend request from "alice@cuhk.edu.hk" to "bob@cuhk.edu.hk"
    And I am signed in as "bob@cuhk.edu.hk"
    When I accept the friend request from "alice@cuhk.edu.hk"
    Then I should see "Friend request accepted"

  Scenario: Friends list shows accepted friends
    Given I am signed in as "alice@cuhk.edu.hk"
    And "bob@cuhk.edu.hk" is my accepted friend
    When I visit the friends page
    Then I should see "bob@cuhk.edu.hk"
