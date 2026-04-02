class Trade < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  enum :action, { buy: "buy", sell: "sell" }, validate: true

  validates :quantity, :price_at_trade, presence: true, numericality: { greater_than: 0 }
  validates :executed_at, presence: true
end
