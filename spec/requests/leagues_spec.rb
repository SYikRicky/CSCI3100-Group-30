require 'rails_helper'

RSpec.describe "Leagues", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/leagues"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      league = FactoryBot.create(:league)
      get "/leagues/#{league.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/leagues/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/leagues"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /join" do
    it "returns http success" do
      get "/leagues/join"
      expect(response).to have_http_status(:success)
    end
  end
end
