class CreateLeagues < ActiveRecord::Migration[8.1]
  def change
    create_table :leagues do |t|
      t.string :name
      t.text :description
      t.references :owner, null: false, foreign_key: true
      t.decimal :starting_capital
      t.string :status
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :invite_code

      t.timestamps
    end
  end
end
