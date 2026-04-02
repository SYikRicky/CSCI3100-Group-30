class LeagueMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.league_mailer.invite.subject
  #
  def invite(user, league)
    @user = user
    @league = league

    mail to: @user.email, subject: "You've been invited to join #{@league.name}"
  end
end
