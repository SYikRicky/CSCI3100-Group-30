Feature: Automatic Pending Order Execution
  As a trader
  So that my limit and stop orders execute at the right price
  I want pending orders to fill when the market reaches the target

  Background:
    Given I am a member of league "Test League" with 100000.0 cash
    And the stock "AAPL" has a price of 150.0

  Scenario: Limit buy fills when price drops to limit price
    When I place a JSON limit buy of 10 shares of "AAPL" at 145.0
    Then the JSON response trade status should be "pending"
    When the stock "AAPL" price moves to 145.0
    And pending orders are checked for "AAPL"
    Then the pending order for "AAPL" should be filled
    And my portfolio should have a long holding of 10 shares of "AAPL"
    And my portfolio cash should be 98550.0

  Scenario: Limit sell fills when price rises to limit price
    When I place a JSON buy of 10 shares of "AAPL"
    And the stock "AAPL" has a price of 155.0
    And I place a JSON limit sell of 10 shares of "AAPL" at 155.0
    Then the JSON response trade status should be "pending"
    When the stock "AAPL" price moves to 155.0
    And pending orders are checked for "AAPL"
    Then the pending order for "AAPL" should be filled
    And my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 100050.0

  Scenario: Stop buy fills when price rises to stop price
    When I place a JSON stop buy of 10 shares of "AAPL" at 160.0
    Then the JSON response trade status should be "pending"
    When the stock "AAPL" price moves to 160.0
    And pending orders are checked for "AAPL"
    Then the pending order for "AAPL" should be filled
    And my portfolio should have a long holding of 10 shares of "AAPL"
    And my portfolio cash should be 98400.0

  Scenario: Stop sell (short) fills when price drops to stop price
    When I place a JSON stop sell of 10 shares of "AAPL" at 140.0
    Then the JSON response trade status should be "pending"
    When the stock "AAPL" price moves to 140.0
    And pending orders are checked for "AAPL"
    Then the pending order for "AAPL" should be filled
    And my portfolio should have a short holding of 10 shares of "AAPL"
    And my portfolio cash should be 101400.0

  Scenario: Limit buy does not fill when price is above limit
    When I place a JSON limit buy of 10 shares of "AAPL" at 145.0
    And the stock "AAPL" price moves to 148.0
    And pending orders are checked for "AAPL"
    Then the pending order for "AAPL" should still be pending
