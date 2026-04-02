class Trade < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  # To match the spec in phase 4b
  validates :action, presence: true, inclusion: { in: %w[buy sell] }
  validates :quantity, :price_at_trade, presence: true, numericality: { greater_than: 0 }
end
