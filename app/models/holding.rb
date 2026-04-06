class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  validates :quantity, :average_cost, presence: true, numericality: { greater_than: 0 }
  validates :stock_id, uniqueness: { scope: :portfolio_id }

  def market_price
    stock.last_price || average_cost
  end

  def market_value
    quantity.to_d * market_price.to_d
  end
end
