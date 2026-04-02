class CreatePortfolioValuations < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolio_valuations do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.datetime :valued_at, null: false
      t.decimal :cash_value, precision: 15, scale: 4, null: false
      t.decimal :holdings_value, precision: 15, scale: 4, null: false
      t.decimal :total_value, precision: 15, scale: 4, null: false

      t.timestamps
    end

    add_index :portfolio_valuations, [ :portfolio_id, :valued_at ]
  end
end
