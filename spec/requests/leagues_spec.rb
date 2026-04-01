require 'rails_helper'

RSpec.describe "/leagues", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user)   { FactoryBot.create(:user) }
  let(:league) { FactoryBot.create(:league, owner: user) }

  # attributes_for excludes associations — owner is set by the controller from current_user
  let(:valid_attributes)   { FactoryBot.attributes_for(:league) }
  let(:invalid_attributes) { { name: nil, starting_capital: nil, invite_code: nil } }

  before { sign_in user }

  describe "GET /leagues" do
    it "renders a successful response" do
      league
      get leagues_url
      expect(response).to be_successful
    end
  end

  describe "GET /leagues/:id" do
    it "renders a successful response" do
      get league_url(league)
      expect(response).to be_successful
    end
  end

  describe "GET /leagues/new" do
    it "renders a successful response" do
      get new_league_url
      expect(response).to be_successful
    end
  end

  describe "POST /leagues" do
    context "with valid parameters" do
      it "creates a new League owned by the current user" do
        expect {
          post leagues_url, params: { league: valid_attributes }
        }.to change(League, :count).by(1)
        expect(League.last.owner).to eq(user)
      end

      it "redirects to the created league" do
        post leagues_url, params: { league: valid_attributes }
        expect(response).to redirect_to(league_url(League.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new League" do
        expect {
          post leagues_url, params: { league: invalid_attributes }
        }.not_to change(League, :count)
      end

      it "renders a 422 response" do
        post leagues_url, params: { league: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /leagues/:id" do
    context "as the owner" do
      it "destroys the league" do
        league  # force creation before the expect block
        expect {
          delete league_url(league)
        }.to change(League, :count).by(-1)
      end

      it "redirects to leagues list" do
        delete league_url(league)
        expect(response).to redirect_to(leagues_url)
      end
    end

    context "as a non-owner" do
      let(:other_user) { FactoryBot.create(:user) }

      it "does not destroy the league" do
        league  # force creation before the expect block
        sign_in other_user
        expect {
          delete league_url(league)
        }.not_to change(League, :count)
      end
    end
  end

  describe "GET /leagues/join" do
    it "renders a successful response" do
      get join_leagues_url
      expect(response).to be_successful
    end
  end

  describe "POST /leagues/join" do
    context "with a valid invite code" do
      it "creates a league membership for the user" do
        expect {
          post join_leagues_url, params: { invite_code: league.invite_code }
        }.to change(LeagueMembership, :count).by(1)
      end

      it "creates a portfolio with the league's starting capital" do
        post join_leagues_url, params: { invite_code: league.invite_code }
        portfolio = user.portfolios.find_by(league: league)
        expect(portfolio).to be_present
        expect(portfolio.cash_balance).to eq(league.starting_capital)
      end

      it "redirects to the league page" do
        post join_leagues_url, params: { invite_code: league.invite_code }
        expect(response).to redirect_to(league_url(league))
      end
    end

    context "with an invalid invite code" do
      it "does not create a membership" do
        expect {
          post join_leagues_url, params: { invite_code: "INVALID" }
        }.not_to change(LeagueMembership, :count)
      end

      it "renders the join form again with 422 status" do
        post join_leagues_url, params: { invite_code: "INVALID" }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "authentication" do
    before { sign_out user }

    it "redirects unauthenticated users to sign in" do
      get leagues_url
      expect(response).to redirect_to(new_user_session_url)
    end
  end
end
