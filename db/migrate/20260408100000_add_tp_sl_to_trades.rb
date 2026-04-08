class AddTpSlToTrades < ActiveRecord::Migration[8.1]
  def change
    add_column :trades, :take_profit, :decimal, precision: 12, scale: 4
    add_column :trades, :stop_loss,   :decimal, precision: 12, scale: 4
  end
end
