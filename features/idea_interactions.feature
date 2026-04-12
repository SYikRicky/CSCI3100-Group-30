Feature: Idea Interactions

  As a user
  So that I can engage with trading ideas
  I want to like and comment on ideas

  @javascript @allow-rescue
  Scenario: User likes an idea
    Given I am signed in as "alice@cuhk.edu.hk"
    And an idea exists with title "AAPL Bull Case" by "bob@cuhk.edu.hk"
    When I visit the idea page for "AAPL Bull Case"
    And I click the like button
    Then the like count should be 1

  @javascript @allow-rescue
  Scenario: User unlikes an idea
    Given I am signed in as "alice@cuhk.edu.hk"
    And an idea exists with title "AAPL Bull Case" by "bob@cuhk.edu.hk"
    And I have liked the idea "AAPL Bull Case"
    When I visit the idea page for "AAPL Bull Case"
    And I click the like button
    Then the like count should be 0

  Scenario: User comments on an idea
    Given I am signed in as "alice@cuhk.edu.hk"
    And an idea exists with title "AAPL Bull Case" by "bob@cuhk.edu.hk"
    When I visit the idea page for "AAPL Bull Case"
    And I fill in the comment form with "Great analysis!"
    And I submit the comment form
    Then I should see "Great analysis!" in the comments section

  Scenario: Viewing an idea increments the view count
    Given I am signed in as "alice@cuhk.edu.hk"
    And an idea exists with title "AAPL Bull Case" by "bob@cuhk.edu.hk" with 5 views
    When I visit the idea page for "AAPL Bull Case"
    Then the idea "AAPL Bull Case" should have 6 views
