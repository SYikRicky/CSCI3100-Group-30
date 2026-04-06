Given('I am a member of league {string} with {float} cash') do |league_name, cash|
  establish_trading_context!(league_name: league_name, cash: cash)
end

Given('I have {float} cash remaining') do |cash|
  establish_trading_context!(league_name: "Alpha League", cash: cash)
end

Given('the stock {string} has a price of {float}') do |ticker, price|
  @stock = Stock.find_or_create_by!(ticker: ticker) do |stock|
    stock.company_name = "#{ticker} Inc."
  end
  @stock.update!(last_price: price)
end

When('I buy {int} shares of {string}') do |quantity, ticker|
  stock = Stock.find_by!(ticker: ticker)
  fill_in "Ticker", with: ticker
  select "Buy", from: "Action"
  fill_in "Quantity", with: quantity
  fill_in "Price", with: stock.last_price
  click_button "Execute Trade"
end

When('I try to buy {int} shares of {string} at {float}') do |quantity, ticker, price|
  stock = Stock.find_or_create_by!(ticker: ticker) do |created|
    created.company_name = "#{ticker} Inc."
  end
  stock.update!(last_price: price)

  fill_in "Ticker", with: ticker
  select "Buy", from: "Action"
  fill_in "Quantity", with: quantity
  fill_in "Price", with: price
  click_button "Execute Trade"
end

When('I sell {int} shares of {string}') do |quantity, ticker|
  stock = Stock.find_by!(ticker: ticker)
  @cash_before_sell = @portfolio.reload.cash_balance.to_d

  fill_in "Ticker", with: ticker
  select "Sell", from: "Action"
  fill_in "Quantity", with: quantity
  fill_in "Price", with: stock.last_price
  click_button "Execute Trade"
end

Then('my cash balance should be {float}') do |amount|
  expect(@portfolio.reload.cash_balance.to_d).to eq(BigDecimal(amount.to_s))
end

Then('I should hold {int} shares of {string}') do |quantity, ticker|
  stock = Stock.find_by!(ticker: ticker)
  holding = @portfolio.holdings.find_by(stock: stock)

  expect(holding).to be_present
  expect(holding.quantity.to_d).to eq(BigDecimal(quantity.to_s))
end

Given('I hold {int} shares of {string} at current price {float}') do |quantity, ticker, price|
  establish_trading_context!(league_name: "Alpha League", cash: 100000) unless defined?(@portfolio) && @portfolio.present?
  step %(the stock "#{ticker}" has a price of #{price})
  stock = Stock.find_by!(ticker: ticker)
  FactoryBot.create(
    :holding,
    portfolio: @portfolio,
    stock: stock,
    quantity: quantity,
    average_cost: price
  )
end

Then('my cash balance should increase by {float}') do |amount|
  expected_balance = @cash_before_sell + BigDecimal(amount.to_s)
  expect(@portfolio.reload.cash_balance.to_d).to eq(expected_balance)
end

def establish_trading_context!(league_name:, cash:)
  @user = FactoryBot.create(:user)
  @league = FactoryBot.create(:league, name: league_name, owner: @user)
  FactoryBot.create(:league_membership, user: @user, league: @league, role: :participant)
  @portfolio = FactoryBot.create(:portfolio, user: @user, league: @league, cash_balance: cash)

  login_as(@user, scope: :user)
  visit portfolio_path(@portfolio)
end
