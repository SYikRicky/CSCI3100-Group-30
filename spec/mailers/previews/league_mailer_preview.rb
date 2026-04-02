# Preview all emails at http://localhost:3000/rails/mailers/league_mailer_mailer
class LeagueMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/league_mailer_mailer/invite
  def invite
    LeagueMailer.invite
  end
end
