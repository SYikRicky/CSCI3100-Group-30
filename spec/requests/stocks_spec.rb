require 'rails_helper'

RSpec.describe "Stocks", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /stocks" do
    it "returns http success" do
      get stocks_path          # 對應 /stocks (index action)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /stocks/:id" do
    it "returns http success" do
      stock = create(:stock)   # 先建一筆 stock
      get stock_path(stock)    # 對應 /stocks/:id (show action)
      expect(response).to have_http_status(:success)
    end
  end
end
