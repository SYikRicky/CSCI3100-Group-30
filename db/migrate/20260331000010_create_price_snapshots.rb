class CreatePriceSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :price_snapshots do |t|
      t.references :stock, null: false, foreign_key: true

      t.decimal :price,  precision: 12, scale: 4
      t.decimal :open,   precision: 12, scale: 4
      t.decimal :high,   precision: 12, scale: 4
      t.decimal :low,    precision: 12, scale: 4
      t.decimal :close,  precision: 12, scale: 4
      t.decimal :volume, precision: 12, scale: 4

      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :price_snapshots, [:stock_id, :recorded_at], unique: true
  end
end

