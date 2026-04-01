class CreateStocks < ActiveRecord::Migration[8.1]
  def change
    create_table :stocks do |t|
      t.string :ticker, null: false
      t.string :company_name, null: false
      t.decimal :last_price, precision: 12, scale: 4
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :stocks, :ticker, unique: true
  end
end

