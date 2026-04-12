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

    it "flips to short when selling more shares than long holding" do
      create(:holding, portfolio: portfolio, stock: stock, quantity: 2, average_cost: 90)

      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: stock.ticker, action: "sell", quantity: 5 }
      }

      expect(response).to redirect_to(portfolio_path(portfolio))
      follow_redirect!
      expect(response.body).to include("Trade executed successfully")

      holding = portfolio.holdings.find_by(stock: stock)
      expect(holding.direction).to eq("short")
      expect(holding.quantity.to_i).to eq(3)
    end

    it "opens short position when selling without holdings" do
      post portfolio_trades_path(portfolio), params: {
        trade: { ticker: stock.ticker, action: "sell", quantity: 5 }
      }

      expect(response).to redirect_to(portfolio_path(portfolio))
      holding = portfolio.holdings.find_by(stock: stock)
      expect(holding.direction).to eq("short")
      expect(holding.quantity.to_i).to eq(5)
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

    context "with take_profit and stop_loss" do
      it "saves TP and SL on the trade" do
        post portfolio_trades_path(portfolio), params: {
          trade: { ticker: stock.ticker, action: "buy", quantity: 1,
                   take_profit: "110.00", stop_loss: "95.00" }
        }

        trade = Trade.order(:created_at).last
        expect(trade.take_profit.to_f).to eq(110.0)
        expect(trade.stop_loss.to_f).to eq(95.0)
      end
    end

    context "with JSON format" do
      it "returns trade data including TP/SL" do
        post portfolio_trades_path(portfolio), params: {
          trade: { ticker: stock.ticker, action: "buy", quantity: 1,
                   take_profit: "110.00", stop_loss: "95.00" }
        }, headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["trade"]["take_profit"]).to eq(110.0)
        expect(json["trade"]["stop_loss"]).to eq(95.0)
        expect(json["trade"]["status"]).to eq("filled")
        expect(json["trade"]["ticker"]).to eq("AAPL")
        expect(json["trade"]["portfolio_id"]).to eq(portfolio.id)
      end

      it "returns pending status for limit orders" do
        post portfolio_trades_path(portfolio), params: {
          trade: { ticker: stock.ticker, action: "buy", quantity: 1,
                   order_type: "limit", limit_price: "95.00" }
        }, headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["trade"]["status"]).to eq("pending")
        expect(json["trade"]["order_type"]).to eq("limit")
        expect(json["trade"]["limit_price"]).to eq(95.0)
      end
    end
  end

  describe "POST /portfolios/:portfolio_id/trades/check_tp_sl" do
    it "returns triggered and filled_orders arrays" do
      create(:holding, portfolio: portfolio, stock: stock, quantity: 5, average_cost: 90,
             direction: "long")

      post check_tp_sl_portfolio_trades_path(portfolio), params: {
        ticker: stock.ticker, current_price: "100.0"
      }, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key("triggered")
      expect(json).to have_key("filled_orders")
      expect(json).to have_key("cash_balance")
    end

    it "returns empty arrays when stock not found" do
      post check_tp_sl_portfolio_trades_path(portfolio), params: {
        ticker: "NONEXIST"
      }, headers: { "Accept" => "application/json" }

      json = JSON.parse(response.body)
      expect(json["triggered"]).to eq([])
      expect(json["filled_orders"]).to eq([])
    end
  end

  describe "PATCH /portfolios/:portfolio_id/trades/:id/cancel" do
    it "cancels a pending trade" do
      trade = create(:trade, portfolio: portfolio, stock: stock, status: "pending",
                     order_type: "limit", limit_price: 95)

      patch cancel_portfolio_trade_path(portfolio, trade),
            headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(trade.reload.status).to eq("cancelled")
    end
  end

  describe "PATCH /portfolios/:portfolio_id/trades/:id" do
    let!(:trade) do
      create(:trade, portfolio: portfolio, stock: stock,
             take_profit: 110.0, stop_loss: 90.0)
    end

    it "updates take_profit and stop_loss" do
      patch portfolio_trade_path(portfolio, trade), params: {
        trade: { take_profit: "120.00", stop_loss: "85.00" }
      }, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["trade"]["take_profit"]).to eq(120.0)
      expect(json["trade"]["stop_loss"]).to eq(85.0)
    end
  end
end
