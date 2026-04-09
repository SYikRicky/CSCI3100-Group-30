Feature: Automatic Take Profit and Stop Loss Execution
  As a trader
  So that I can manage risk automatically
  I want positions to close when price hits TP or SL

  Background:
    Given I am a member of league "Test League" with 100000.0 cash
    And the stock "AAPL" has a price of 150.0

  Scenario: Long position auto-closes at take profit
    When I place a JSON trade to buy 10 shares of "AAPL" with TP 160.0 and SL 140.0
    And the stock "AAPL" price moves to 160.0
    And the TP/SL checker runs for "AAPL"
    Then my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 100100.0

  Scenario: Long position auto-closes at stop loss
    When I place a JSON trade to buy 10 shares of "AAPL" with TP 160.0 and SL 140.0
    And the stock "AAPL" price moves to 140.0
    And the TP/SL checker runs for "AAPL"
    Then my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 99900.0

  Scenario: Short position auto-closes at take profit
    When I place a JSON short sell of 10 shares of "AAPL" with TP 140.0 and SL 160.0
    And the stock "AAPL" price moves to 140.0
    And the TP/SL checker runs for "AAPL"
    Then my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 100100.0

  Scenario: Short position auto-closes at stop loss
    When I place a JSON short sell of 10 shares of "AAPL" with TP 140.0 and SL 160.0
    And the stock "AAPL" price moves to 160.0
    And the TP/SL checker runs for "AAPL"
    Then my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 99900.0

  Scenario: No trigger when price is between TP and SL
    When I place a JSON trade to buy 10 shares of "AAPL" with TP 160.0 and SL 140.0
    And the stock "AAPL" price moves to 155.0
    And the TP/SL checker runs for "AAPL"
    Then my portfolio should have a long holding of 10 shares of "AAPL"
