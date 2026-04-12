# ── Short selling trade steps ──

When('I place a JSON short sell of {int} shares of {string}') do |qty, ticker|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "sell", quantity: qty,
                                  order_type: "market" })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('I place a JSON short sell of {int} shares of {string} with TP {float} and SL {float}') do |qty, ticker, tp, sl|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "sell", quantity: qty,
                                  order_type: "market", take_profit: tp, stop_loss: sl })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('I place a JSON buy of {int} shares of {string}') do |qty, ticker|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "buy", quantity: qty,
                                  order_type: "market" })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('I place a JSON sell of {int} shares of {string}') do |qty, ticker|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "sell", quantity: qty,
                                  order_type: "market" })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

Then('the JSON response trade action should be {string}') do |expected|
  expect(@json_response["trade"]["action"]).to eq(expected)
end

Then('my portfolio should have a short holding of {int} shares of {string}') do |qty, ticker|
  @portfolio.reload
  stock = Stock.find_by!(ticker: ticker)
  holding = @portfolio.holdings.find_by(stock: stock)
  expect(holding).to be_present
  expect(holding.direction).to eq("short")
  expect(holding.quantity.to_i).to eq(qty)
end

Then('my portfolio should have a long holding of {int} shares of {string}') do |qty, ticker|
  @portfolio.reload
  stock = Stock.find_by!(ticker: ticker)
  holding = @portfolio.holdings.find_by(stock: stock)
  expect(holding).to be_present
  expect(holding.direction).to eq("long")
  expect(holding.quantity.to_i).to eq(qty)
end

Then('my portfolio should have no holdings of {string}') do |ticker|
  @portfolio.reload
  stock = Stock.find_by!(ticker: ticker)
  holding = @portfolio.holdings.find_by(stock: stock)
  expect(holding).to be_nil
end

Then('my portfolio cash should be {float}') do |expected|
  @portfolio.reload
  expect(@portfolio.cash_balance.to_f).to be_within(0.01).of(expected)
end

# ── TP/SL auto-execution steps ──

When('the stock {string} price moves to {float}') do |ticker, price|
  stock = Stock.find_by!(ticker: ticker)
  stock.update!(last_price: price)
end

When('the TP\/SL checker runs for {string}') do |ticker|
  stock = Stock.find_by!(ticker: ticker)
  CheckTpSlService.new(stock: stock).call
end
