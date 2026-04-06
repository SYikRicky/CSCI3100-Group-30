Feature: Mailbox Notification Dropdown

  As a signed-in user
  So that I can see messages from the system, invitations, and portfolio updates
  I want a mailbox icon in the navigation bar that shows a dropdown of notifications

  Scenario: Mailbox button appears in the nav when signed in
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then I should see the mailbox button

  Scenario: Mailbox button is not visible when signed out
    When I visit the home page without signing in
    Then I should not see the mailbox button

  Scenario: Mailbox dropdown is present in the DOM when signed in
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then the mailbox dropdown should be in the page

  Scenario: Mailbox shows a notification summary
    Given I am signed in as "alice@cuhk.edu.hk"
    And I have a notification with title "League Invitation" and body "You have been invited to join Alpha League by the admin."
    When I visit the leagues page
    Then the mailbox dropdown should contain "League Invitation"

  Scenario: Mailbox shows a portfolio summary notification
    Given I am signed in as "alice@cuhk.edu.hk"
    And I have a notification with title "Portfolio Summary" and body "Your portfolio has grown by 5.2% this week."
    When I visit the leagues page
    Then the mailbox dropdown should contain "Portfolio Summary"

  Scenario: Mailbox shows empty state when there are no notifications
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then the mailbox dropdown should contain "No notifications"
