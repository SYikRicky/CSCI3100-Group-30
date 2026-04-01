class CreateTrades < ActiveRecord::Migration[8.1]
  def change
    create_table :trades do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.string :action
      t.decimal :quantity
      t.decimal :price_at_trade
      t.datetime :executed_at

      t.timestamps
    end
  end
end
