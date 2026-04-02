Given('I am a member of league {string} with {float} cash') do |league_name, cash|
  @user = FactoryBot.create(:user)
  @league = FactoryBot.create(:league, name: league_name, owner: @user)
  @portfolio = FactoryBot.create(:portfolio, user: @user, league: @league, cash_balance: cash)
end

Given('the stock {string} has a price of {float}') do |ticker, price|
  @stock = Stock.find_or_create_by!(ticker: ticker) do |stock|
    stock.company_name = "#{ticker} Inc."
  end
  @stock.update!(last_price: price)
end

When('I buy {int} shares of {string}') do |quantity, ticker|
  stock = Stock.find_by!(ticker: ticker)
  TradingService.new(
    portfolio: @portfolio,
    stock: stock,
    action: :buy,
    quantity: quantity,
    price: stock.last_price
  ).call
  @last_message = "Trade executed successfully (Virtual Trading Only)"
end

When('I try to buy {int} shares of {string} at {float}') do |quantity, ticker, price|
  stock = Stock.find_or_create_by!(ticker: ticker) do |created|
    created.company_name = "#{ticker} Inc."
  end
  stock.update!(last_price: price)

  begin
    TradingService.new(
      portfolio: @portfolio,
      stock: stock,
      action: :buy,
      quantity: quantity,
      price: price
    ).call
  rescue TradingService::Error => e
    @last_message = e.message
  end
end

When('I sell {int} shares of {string}') do |quantity, ticker|
  stock = Stock.find_by!(ticker: ticker)
  @cash_before_sell = @portfolio.reload.cash_balance.to_d

  TradingService.new(
    portfolio: @portfolio,
    stock: stock,
    action: :sell,
    quantity: quantity,
    price: stock.last_price
  ).call
end

Then('I should see trading message {string}') do |message|
  expect(@last_message.to_s.downcase).to include(message.downcase)
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
