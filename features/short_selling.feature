Feature: Short Selling
  As a trader
  So that I can profit from price declines
  I want to open and close short positions

  Background:
    Given I am a member of league "Test League" with 100000.0 cash
    And the stock "AAPL" has a price of 150.0

  Scenario: Opening a short position via JSON
    When I place a JSON short sell of 10 shares of "AAPL"
    Then the JSON response trade status should be "filled"
    And the JSON response trade action should be "sell"
    And my portfolio should have a short holding of 10 shares of "AAPL"
    And my portfolio cash should be 101500.0

  Scenario: Covering a short position by buying
    When I place a JSON short sell of 10 shares of "AAPL"
    And the stock "AAPL" has a price of 140.0
    And I place a JSON buy of 10 shares of "AAPL"
    Then my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 100100.0

  Scenario: Partial cover of a short position
    When I place a JSON short sell of 10 shares of "AAPL"
    And the stock "AAPL" has a price of 145.0
    And I place a JSON buy of 4 shares of "AAPL"
    Then my portfolio should have a short holding of 6 shares of "AAPL"
    And my portfolio cash should be 100920.0

  Scenario: Selling when holding long reduces long position
    When I place a JSON buy of 10 shares of "AAPL"
    And I place a JSON sell of 10 shares of "AAPL"
    Then my portfolio should have no holdings of "AAPL"
    And my portfolio cash should be 100000.0

  Scenario: Selling more than long holding flips to short
    When I place a JSON buy of 5 shares of "AAPL"
    And I place a JSON sell of 8 shares of "AAPL"
    Then my portfolio should have a short holding of 3 shares of "AAPL"
    And my portfolio cash should be 100450.0
