class TradeMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.trade_mailer.confirmation.subject
  #

  default from: "notifications@mock-fund-league.cuhk.edu.hk",
    reply_to: "support@mock-fund-league.cuhk.edu.hk"


  def confirmation(trade)
    @trade = trade
    @user = trade.portfolio.user
    @league = trade.portfolio.league

    # Don't change the subject
    mail to: @user.email, subject: "Trade Confirmation - #{@league.name}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.trade_mailer.daily_summary.subject
  #
  def daily_summary(portfolio)
    @portfolio = portfolio
    @user = portfolio.user
    @league = portfolio.league

    @trades = portfolio.trades.where("created_at > ?", 1.day.ago)

    # Don't change the subject
    mail to: @user.email, subject: "Daily Portfolio Summary - #{@league.name}"
  end

  def confirmation(trade)
    @trade = trade
    @user = trade.user
    @league = trade.league
    # user model will track the balance
    @remaining_balance = @user.balance_in_league(@league) 
    mail(to: @user.email, subject: "Trade Confirmed: #{@trade.stock.ticker}")
  end

  def trade_confirmation(trade)
    @trade = trade
    @user = trade.user
    @league = trade.league
  
    # the logic to calculate balance
    @remaining_balance = @user.balance_for_league(@league) 

    mail(to: @user.email, subject: "Trade Confirmation: #{@trade.stock.ticker}")
  end

end
