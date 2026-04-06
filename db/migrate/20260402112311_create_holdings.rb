class CreateHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :holdings do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.decimal :quantity, precision: 15, scale: 4, null: false
      t.decimal :average_cost, precision: 15, scale: 4, null: false

      t.timestamps
    end

    add_index :holdings, [ :portfolio_id, :stock_id ], unique: true
  end
end
