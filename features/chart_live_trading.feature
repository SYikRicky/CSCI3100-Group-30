Feature: Live Chart Price Action and Order Management
  As a trader
  So that I can trade in a realistic environment
  I want continuously moving price action and direct chart-based order management

  Background:
    Given I am signed in as "alice@cuhk.edu.hk"
    And a stock "AAPL" exists with price 150.00
    And "AAPL" has 20 price snapshots at 1-minute intervals

  Scenario: Chart has no pause or replay controls
    When I visit the stock chart for "AAPL"
    Then the page should have a chart container
    And there should be no element with id "play-pause-btn"

  Scenario: Trade modal includes take profit and stop loss fields
    When I visit the stock chart for "AAPL"
    Then the page should have a chart container
    And the page should have a take profit input field
    And the page should have a stop loss input field

  Scenario: Right-click context menu element is present on chart
    When I visit the stock chart for "AAPL"
    Then the page should have a chart context menu element

  Scenario: OHLCV API provides data needed for volatility calculation
    When I request OHLCV data for "AAPL" with interval 1
    Then the response should be JSON
    And the candles should include open, high, low, close and volume fields

  Scenario: Placing a market buy via JSON returns trade with TP and SL
    Given I am a member of league "Test League" with 100000.0 cash
    And the stock "AAPL" has a price of 150.0
    When I place a JSON trade to buy 10 shares of "AAPL" with TP 165.0 and SL 142.5
    Then the JSON response should include a trade with take_profit 165.0
    And the JSON response should include a trade with stop_loss 142.5
    And the JSON response trade status should be "filled"

  Scenario: Placing a limit order via JSON returns pending trade
    Given I am a member of league "Test League" with 100000.0 cash
    And the stock "AAPL" has a price of 150.0
    When I place a JSON limit buy of 5 shares of "AAPL" at 145.0
    Then the JSON response trade status should be "pending"
    And the JSON response trade order_type should be "limit"

  Scenario: Chart JS uses wall-clock candle timing
    When I visit the stock chart for "AAPL"
    Then the chart script should not contain a fixed TICKS_PER_CANDLE constant
    And the chart script should compute candle boundaries from wall-clock time
