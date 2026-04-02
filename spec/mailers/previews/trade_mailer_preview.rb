# Preview all emails at http://localhost:3000/rails/mailers/trade_mailer_mailer
class TradeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/trade_mailer_mailer/confirmation
  def confirmation
    TradeMailer.confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/trade_mailer_mailer/daily_summary
  def daily_summary
    TradeMailer.daily_summary
  end
end
