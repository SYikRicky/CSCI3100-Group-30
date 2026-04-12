class CreateIdeaLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_likes do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :idea_likes, [ :idea_id, :user_id ], unique: true
  end
end
