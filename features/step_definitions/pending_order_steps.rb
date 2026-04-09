# ── Pending order step definitions ──

When('I place a JSON limit sell of {int} shares of {string} at {float}') do |qty, ticker, price|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "sell", quantity: qty,
                                  order_type: "limit", limit_price: price })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('I place a JSON stop buy of {int} shares of {string} at {float}') do |qty, ticker, price|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "buy", quantity: qty,
                                  order_type: "stop", stop_price: price })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('I place a JSON stop sell of {int} shares of {string} at {float}') do |qty, ticker, price|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "sell", quantity: qty,
                                  order_type: "stop", stop_price: price })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('pending orders are checked for {string}') do |ticker|
  stock = Stock.find_by!(ticker: ticker)
  @filled_orders = FillPendingOrdersService.new(stock: stock).call
end

Then('the pending order for {string} should be filled') do |ticker|
  stock = Stock.find_by!(ticker: ticker)
  pending = @portfolio.trades.where(stock: stock, status: "pending")
  expect(pending.count).to eq(0)
  expect(@filled_orders.size).to be >= 1
end

Then('the pending order for {string} should still be pending') do |ticker|
  stock = Stock.find_by!(ticker: ticker)
  pending = @portfolio.trades.where(stock: stock, status: "pending")
  expect(pending.count).to be >= 1
end
