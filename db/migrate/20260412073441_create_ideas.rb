class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: true, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.integer :direction, null: false, default: 0
      t.integer :views_count, null: false, default: 0
      t.datetime :published_at
      t.string :chart_url

      t.timestamps
    end

    add_index :ideas, [ :user_id, :created_at ]
    add_index :ideas, :published_at
  end
end
