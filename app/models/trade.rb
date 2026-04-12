class Trade < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  enum :action, { buy: "buy", sell: "sell" }, validate: true
  enum :order_type, { market: "market", limit: "limit", stop: "stop" }, validate: true, default: :market, prefix: true
  enum :status, { pending: "pending", filled: "filled", cancelled: "cancelled" }, validate: true, default: :filled

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_trade, presence: true, numericality: { greater_than: 0 }, if: :filled?
  validates :executed_at, presence: true, if: :filled?
  validates :limit_price, presence: true, numericality: { greater_than: 0 }, if: :order_type_limit?
  validates :stop_price, presence: true, numericality: { greater_than: 0 }, if: :order_type_stop?
  validates :take_profit, numericality: { greater_than: 0 }, allow_nil: true
  validates :stop_loss, numericality: { greater_than: 0 }, allow_nil: true
end
