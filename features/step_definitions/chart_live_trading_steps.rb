Then('there should be no element with id {string}') do |element_id|
  expect(page).not_to have_css("##{element_id}", visible: :all)
end

Then('the page should have a take profit input field') do
  expect(page).to have_css('#trade-take-profit', visible: :all)
end

Then('the page should have a stop loss input field') do
  expect(page).to have_css('#trade-stop-loss', visible: :all)
end

Then('the page should have a chart context menu element') do
  expect(page).to have_css('#chart-context-menu', visible: :all)
end

# ── Trading context setup (self-contained, no virtual_trading_steps dependency) ──

Given('I am a member of league {string} with {float} cash') do |league_name, cash|
  @user = FactoryBot.create(:user)
  @league = FactoryBot.create(:league, name: league_name, owner: @user)
  FactoryBot.create(:league_membership, user: @user, league: @league, role: :participant)
  @portfolio = FactoryBot.create(:portfolio, user: @user, league: @league, cash_balance: cash)
  login_as(@user, scope: :user)
end

Given('the stock {string} has a price of {float}') do |ticker, price|
  @stock = Stock.find_or_create_by!(ticker: ticker) { |s| s.company_name = "#{ticker} Inc." }
  @stock.update!(last_price: price)
end

# ── JSON trade placement steps ──

When('I place a JSON trade to buy {int} shares of {string} with TP {float} and SL {float}') do |qty, ticker, tp, sl|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "buy", quantity: qty,
                                  order_type: "market", take_profit: tp, stop_loss: sl })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

When('I place a JSON limit buy of {int} shares of {string} at {float}') do |qty, ticker, price|
  url = Rails.application.routes.url_helpers.portfolio_trades_path(@portfolio)
  page.driver.header('Accept', 'application/json')
  page.driver.post(url, trade: { ticker: ticker, action: "buy", quantity: qty,
                                  order_type: "limit", limit_price: price })
  @json_response = JSON.parse(page.driver.response.body)
  page.driver.header('Accept', 'text/html,application/xhtml+xml')
end

Then('the JSON response should include a trade with take_profit {float}') do |expected|
  expect(@json_response["trade"]["take_profit"]).to eq(expected)
end

Then('the JSON response should include a trade with stop_loss {float}') do |expected|
  expect(@json_response["trade"]["stop_loss"]).to eq(expected)
end

Then('the JSON response trade status should be {string}') do |status|
  expect(@json_response["trade"]["status"]).to eq(status)
end

Then('the JSON response trade order_type should be {string}') do |order_type|
  expect(@json_response["trade"]["order_type"]).to eq(order_type)
end

# ── Chart JS timing steps ──

Then('the chart script should not contain a fixed TICKS_PER_CANDLE constant') do
  expect(page.source).not_to include("const TICKS_PER_CANDLE")
end

Then('the chart script should use tick-counting for real-time candle duration') do
  # Candle duration is computed from _currentInterval and SUB_TICK_MS, not a fixed constant
  expect(page.source).to include("_currentInterval")
  expect(page.source).to include("SUB_TICK_MS")
end
