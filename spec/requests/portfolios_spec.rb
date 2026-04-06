require "rails_helper"

RSpec.describe "Portfolios", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /portfolios/:id" do
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user) }

    before { sign_in user }

    it "renders a successful response for owner" do
      get portfolio_path(portfolio)
      expect(response).to be_successful
    end

    it "returns not found for another user's portfolio" do
      other_user = create(:user)
      sign_in other_user

      get portfolio_path(portfolio)
      expect(response).to have_http_status(:not_found)
    end
  end
end
