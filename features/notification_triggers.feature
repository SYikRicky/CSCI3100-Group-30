Feature: Notification Triggers

  As a user
  So that I am kept informed of activity that concerns me
  I want to receive notifications when I am invited to a league,
  when someone sends me a friend request, and when a request I sent is accepted

  Scenario: Invitee receives a notification when added to a league
    Given I am signed in as "alice@cuhk.edu.hk"
    And a user exists with email "bob@cuhk.edu.hk"
    When I create a league and invite "bob@cuhk.edu.hk"
    Then "bob@cuhk.edu.hk" should have a notification containing "invited"

  Scenario: User receives a notification when they get a friend request
    Given I am signed in as "alice@cuhk.edu.hk"
    And a user exists with email "bob@cuhk.edu.hk"
    When I send a friend request to "bob@cuhk.edu.hk"
    Then "bob@cuhk.edu.hk" should have a notification containing "friend request"

  Scenario: User receives a notification when their friend request is accepted
    Given I am signed in as "alice@cuhk.edu.hk"
    And "bob@cuhk.edu.hk" has sent me a friend request
    When I accept the friend request from "bob@cuhk.edu.hk"
    Then "bob@cuhk.edu.hk" should have a notification containing "accepted"
