class AddDirectionToHoldings < ActiveRecord::Migration[8.1]
  def change
    add_column :holdings, :direction, :string, default: "long", null: false

    # Update uniqueness index to include direction (allow long + short for same stock)
    remove_index :holdings, [ :portfolio_id, :stock_id ]
    add_index :holdings, [ :portfolio_id, :stock_id, :direction ], unique: true
  end
end
