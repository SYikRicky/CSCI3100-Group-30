require 'rails_helper'

RSpec.describe "Stocks", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /stocks" do
    it "returns http success" do
      get stocks_path
      expect(response).to have_http_status(:success)
    end

    it "includes stock tickers in the response" do
      stock = create(:stock, ticker: "TSLA")
      get stocks_path
      expect(response.body).to include("TSLA")
    end
  end

  describe "GET /stocks/:id" do
    it "returns http success" do
      stock = create(:stock)
      get stock_path(stock)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /stocks/prices" do
    let!(:aapl) { create(:stock, ticker: "AAPL", last_price: 175.50) }
    let!(:tsla) { create(:stock, ticker: "TSLA", last_price: 250.00) }

    it "returns prices for specified tickers" do
      get prices_stocks_path, params: { tickers: "AAPL,TSLA" },
          headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["AAPL"]).to eq(175.50)
      expect(json["TSLA"]).to eq(250.00)
    end

    it "returns all stocks when no tickers param" do
      get prices_stocks_path, headers: { "Accept" => "application/json" }

      json = JSON.parse(response.body)
      expect(json.keys).to include("AAPL", "TSLA")
    end

    it "ignores non-existent tickers" do
      get prices_stocks_path, params: { tickers: "FAKE" },
          headers: { "Accept" => "application/json" }

      json = JSON.parse(response.body)
      expect(json).to be_empty
    end
  end

  describe "GET /stocks/:id/ohlcv" do
    let(:stock) { create(:stock) }

    it "returns OHLCV candle data" do
      base = Time.zone.parse("2026-01-01 09:30:00")
      create(:price_snapshot, stock: stock, recorded_at: base,
             open: 100, high: 105, low: 99, close: 103, volume: 1000)
      create(:price_snapshot, stock: stock, recorded_at: base + 1.minute,
             open: 103, high: 106, low: 101, close: 104, volume: 1200)

      get ohlcv_stock_path(stock), headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json.first.keys).to include("open", "high", "low", "close", "volume", "timestamp")
    end

    it "returns empty array when no snapshots" do
      get ohlcv_stock_path(stock), headers: { "Accept" => "application/json" }

      json = JSON.parse(response.body)
      expect(json).to eq([])
    end

    it "groups candles by interval" do
      base = Time.zone.parse("2026-01-01 09:30:00")
      3.times do |i|
        create(:price_snapshot, stock: stock, recorded_at: base + i.minutes,
               open: 100, high: 105, low: 99, close: 103, volume: 500)
      end

      get ohlcv_stock_path(stock), params: { interval: 5 },
          headers: { "Accept" => "application/json" }

      json = JSON.parse(response.body)
      expect(json.length).to eq(1) # 3 minutes fit in one 5-min bucket
    end
  end
end
