class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.text :content, null: false
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [ :sender_id, :receiver_id, :created_at ]
  end
end
