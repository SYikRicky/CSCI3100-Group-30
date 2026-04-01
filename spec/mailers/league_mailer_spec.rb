require "rails_helper"

RSpec.describe LeagueMailer, type: :mailer do
  describe "#invite" do
    let(:user) { create(:user, email: "alice@cuhk.edu.hk") }
    let(:league) { create(:league, name: "Private League", invite_code: "JOIN123") }
    let(:mail) { LeagueMailer.invite(user, league) }

    it "renders the headers" do
      expect(mail.subject).to eq("You've been invited to join Private League")
      expect(mail.to).to eq(["alice@cuhk.edu.hk"])
    end

    it "includes the invite code" do
      expect(mail.body.encoded).to match("JOIN123")
    end
  end
end