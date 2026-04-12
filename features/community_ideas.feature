Feature: Community Ideas

  As a user
  So that I can share and discover trading ideas
  I want to browse, create, and view community trading ideas

  Scenario: Community link is visible in the navigation bar
    Given I am signed in as "alice@cuhk.edu.hk"
    When I visit the leagues page
    Then I should see a "Community" link in the navigation bar

  Scenario: Community link is not visible when signed out
    When I visit the home page without signing in
    Then I should not see a "Community" link in the navigation bar

  Scenario: User browses the ideas feed
    Given I am signed in as "alice@cuhk.edu.hk"
    And the following ideas exist:
      | title             | author             | direction |
      | AAPL Bull Case    | bob@cuhk.edu.hk   | long      |
      | TSLA Bear Thesis  | carol@cuhk.edu.hk | short     |
    When I visit the ideas page
    Then I should see "AAPL Bull Case"
    And I should see "TSLA Bear Thesis"

  Scenario: Ideas are sorted by most recent by default
    Given I am signed in as "alice@cuhk.edu.hk"
    And the following ideas exist:
      | title        | published_at        |
      | Older Idea   | 2026-04-01 10:00:00 |
      | Newer Idea   | 2026-04-10 10:00:00 |
    When I visit the ideas page
    Then I should see "Newer Idea" before "Older Idea" on the page

  Scenario: User creates a new idea
    Given I am signed in as "alice@cuhk.edu.hk"
    And a stock exists with ticker "AAPL"
    When I visit the new idea page
    And I fill in the idea form with:
      | Title     | AAPL breakout coming     |
      | Body      | The chart shows a cup... |
      | Direction | long                     |
      | Stock     | AAPL                     |
    And I submit the idea form
    Then I should see "Idea was successfully published"
    And I should see "AAPL breakout coming"

  Scenario: User views an individual idea
    Given I am signed in as "alice@cuhk.edu.hk"
    And an idea exists with title "AAPL Bull Case" by "bob@cuhk.edu.hk"
    When I visit the ideas page
    And I click on "AAPL Bull Case"
    Then I should see the idea detail page for "AAPL Bull Case"
    And I should see the author information
