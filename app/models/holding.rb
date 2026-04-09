class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  validates :quantity, :average_cost, presence: true, numericality: { greater_than: 0 }
  validates :direction, inclusion: { in: %w[long short] }
  validates :stock_id, uniqueness: { scope: [:portfolio_id, :direction] }

  def market_price
    stock.last_price || average_cost
  end

  def market_value
    quantity.to_d * market_price.to_d
  end

  def long?
    direction == "long"
  end

  def short?
    direction == "short"
  end
end
