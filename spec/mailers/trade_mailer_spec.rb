require "rails_helper"

RSpec.describe TradeMailer, type: :mailer do
  let(:user) { create(:user, email: "alice@cuhk.edu.hk") }
  let(:league) { create(:league, name: "CUHK Mock Fund League") }
  let(:portfolio) { create(:portfolio, user: user, league: league) }
  let(:stock) { create(:stock, ticker: "AAPL") }

  describe "confirmation" do
    let(:trade) { create(:trade, portfolio: portfolio, stock: stock, action: "buy", quantity: 10, price_at_trade: 150.00) }
    let(:mail) { TradeMailer.confirmation(trade) }

    it "renders the headers" do
      expect(mail.subject).to eq("Trade Confirmation - #{league.name}")
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ "notifications@mock-fund-league.cuhk.edu.hk" ])
    end

    it "includes trade details and the mandatory disclaimer" do
        expect(mail.body.encoded).to include("bought")
        expect(mail.body.encoded).to include("10.0")
        expect(mail.body.encoded).to include("AAPL")
        expect(mail.body.encoded).to include("Virtual Trading Only")
    end
  end

  describe "daily_summary" do
    let(:mail) { TradeMailer.daily_summary(portfolio) }

    it "renders the headers" do
      expect(mail.subject).to eq("Daily Portfolio Summary - #{league.name}")
      expect(mail.to).to eq([ user.email ])
    end

    it "lists portfolio value" do
      # Listing holdings and portfolio value
      expect(mail.body.encoded).to match("Your daily summary for #{league.name}")
    end
  end
end
