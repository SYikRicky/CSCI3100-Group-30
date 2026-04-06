Feature: Virtual Trading
  As a league participant
  So that I can practice stock trading with virtual money
  I want to buy and sell stocks while respecting cash and holding constraints

  Scenario: User buys a stock successfully
    Given I am a member of league "Alpha League" with 100000 cash
    And the stock "AAPL" has a price of 150.00
    When I buy 10 shares of "AAPL"
    Then I should see trading message "Trade executed successfully (Virtual Trading Only)"
    And my cash balance should be 98500.00
    And I should hold 10 shares of "AAPL"

  Scenario: User cannot buy more than cash balance allows
    Given I am a member of league "Alpha League" with 100.00 cash
    And the stock "AAPL" has a price of 150.00
    When I try to buy 10 shares of "AAPL" at 150.00
    Then I should see trading message "insufficient cash balance"

  Scenario: User sells shares they own
    Given I am a member of league "Alpha League" with 100000 cash
    And I hold 10 shares of "AAPL" at current price 150.00
    When I sell 5 shares of "AAPL"
    Then my cash balance should increase by 750.00
    And I should hold 5 shares of "AAPL"
