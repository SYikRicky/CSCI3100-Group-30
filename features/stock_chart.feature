Feature: Stock Chart
  As a league participant
  So that I can analyse price action before trading
  I want to view an interactive candlestick chart for each stock

  Background:
    Given I am signed in as "alice@cuhk.edu.hk"
    And a stock "AAPL" exists with price 150.00
    And "AAPL" has 5 price snapshots at 1-minute intervals

  Scenario: User can view the chart page for a stock
    When I visit the stock chart for "AAPL"
    Then I should see "AAPL"
    And the page should have a chart container

  Scenario: OHLCV API returns 1-minute candles by default
    When I request OHLCV data for "AAPL" with interval 1
    Then the response should be JSON
    And the candles should include open, high, low, close and volume fields
    And the candles should be ordered by time ascending

  Scenario: OHLCV API aggregates into 5-minute candles
    When I request OHLCV data for "AAPL" with interval 5
    Then the response should be JSON
    And there should be fewer candles than for interval 1

  Scenario: Chart page has timeframe selector buttons
    When I visit the stock chart for "AAPL"
    Then I should see a timeframe button "1m"
    And I should see a timeframe button "5m"
    And I should see a timeframe button "15m"
    And I should see a timeframe button "1h"
    And I should see a timeframe button "1D"
