require "rails_helper"

RSpec.describe "Trades", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:portfolio) { create(:portfolio, user: user, cash_balance: 1000) }
  let(:stock) { create(:stock, ticker: "AAPL", company_name: "Apple Inc", last_price: 100) }

  before { sign_in user }

  describe "POST /portfolios/:portfolio_id/trades" do
    it "executes a buy and redirects to portfolio page" do
      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: stock.ticker, action: "buy", quantity: 2 }
      }

      expect(response).to redirect_to(portfolio_path(portfolio))
      follow_redirect!
      expect(response.body).to include("Trade executed successfully (Virtual Trading Only)")
    end

    it "shows error when cash is insufficient" do
      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: stock.ticker, action: "buy", quantity: 20 }
      }

      expect(response).to redirect_to(portfolio_path(portfolio))
      follow_redirect!
      expect(response.body).to include("Insufficient cash balance")
    end

    it "shows error when user tries to sell more shares than owned" do
      create(:holding, portfolio: portfolio, stock: stock, quantity: 2, average_cost: 90)

      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: stock.ticker, action: "sell", quantity: 5 }
      }

      expect(response).to redirect_to(portfolio_path(portfolio))
      follow_redirect!
      expect(response.body).to include("insufficient shares to sell")
    end

    it "shows error when stock ticker is unknown" do
      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: "UNKNOWN", action: "buy", quantity: 1 }
      }

      expect(response).to redirect_to(portfolio_path(portfolio))
      follow_redirect!
      expect(response.body).to include("Stock not found")
    end

    it "uses stock market price instead of client supplied price" do
      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: stock.ticker, action: "buy", quantity: 1, price: 1 }
      }

      trade = Trade.order(:created_at).last
      expect(trade.price_at_trade.to_d).to eq(stock.last_price.to_d)
    end
  end
end
