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
      expect(mail.reply_to).to eq([ "support@mock-fund-league.cuhk.edu.hk" ])
    end

    it "includes trade details and the mandatory disclaimer" do
        expect(mail.body.encoded).to include("bought")
        expect(mail.body.encoded).to include("10.0")
        expect(mail.body.encoded).to include("AAPL")
        expect(mail.body.encoded).to include("Virtual Trading Only")
    end

    it "uses 'sold' terminology for sell trades" do
      sell_trade = create(:trade, portfolio: portfolio, stock: stock, action: "sell")
      sell_mail = TradeMailer.confirmation(sell_trade)
      expect(sell_mail.body.encoded).to include("sold")
    end

    it "greets the user by name" do
      # changed to greet by random names
      expect(mail.body.encoded).to include("Hello #{user.name}")
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

    it "notifies user if no trades were made today" do
      # empty portfolios
      expect(mail.body.encoded).to include("You didn't make any trades today")
    end
  end
end
