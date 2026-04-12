class AddOrderTypeToTrades < ActiveRecord::Migration[8.1]
  def change
    add_column :trades, :order_type, :string, default: "market", null: false
    add_column :trades, :limit_price, :decimal, precision: 12, scale: 4
    add_column :trades, :stop_price, :decimal, precision: 12, scale: 4
    add_column :trades, :status, :string, default: "filled", null: false
  end
end
