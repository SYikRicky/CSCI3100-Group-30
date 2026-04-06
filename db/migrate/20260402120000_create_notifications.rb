class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user,   null: false, foreign_key: true
      t.integer    :kind,   null: false, default: 0
      t.string     :title,  null: false
      t.text       :body,   null: false
      t.datetime   :read_at

      t.timestamps
    end

    add_index :notifications, [ :user_id, :created_at ]
  end
end
