require 'rails_helper'

RSpec.describe "Leagues", type: :request do

  include Devise::Test::IntegrationHelpers

  describe "GET /index" do
    it "returns http success" do
      
      user = User.create!(email: "test@cuhk.edu.hk", password: "password123")
      sign_in user 
      
      get leagues_path
      expect(response).to have_http_status(:success)
    end
  end
end
