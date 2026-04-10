Feature: Private chatroom

  As a signed-in user
  So that I can coordinate with my friends
  I want a dedicated chatroom for 1-on-1 messaging

  Scenario: User navigates to the chatroom via the navbar button
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    And I open the chatroom from the navigation bar
    Then I should see the chatroom heading
    And I should see the chatroom sidebar

  Scenario: User selects a friend from the chatroom interface
    Given I am signed in as "alice@cuhk.edu.hk"
    And "bob@cuhk.edu.hk" is my accepted friend
    When I visit the chatrooms page
    And I open a chat with "bob@cuhk.edu.hk"
    Then I should see the chat thread header for my friend
    And I should see the chat message composer

  @javascript
  Scenario: User successfully sends a real-time message to the selected friend
    Given "alice@cuhk.edu.hk" and "bob@cuhk.edu.hk" are mutual friends
    And user "alice@cuhk.edu.hk" is chatting with "bob@cuhk.edu.hk" in session :alice
    And user "bob@cuhk.edu.hk" is chatting with "alice@cuhk.edu.hk" in session :bob
    When user "alice@cuhk.edu.hk" sends chat message "Hello Bob in realtime" in session :alice
    Then session :bob should see "Hello Bob in realtime" within 20 seconds

  @javascript
  Scenario: User successfully receives a real-time message from the friend
    Given "alice@cuhk.edu.hk" and "bob@cuhk.edu.hk" are mutual friends
    And user "alice@cuhk.edu.hk" is chatting with "bob@cuhk.edu.hk" in session :alice
    And user "bob@cuhk.edu.hk" is chatting with "alice@cuhk.edu.hk" in session :bob
    When user "bob@cuhk.edu.hk" sends chat message "Hi Alice from Bob" in session :bob
    Then session :alice should see "Hi Alice from Bob" within 20 seconds
