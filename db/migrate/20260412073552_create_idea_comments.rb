class CreateIdeaComments < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_comments do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :idea_comments }
      t.text :body, null: false

      t.timestamps
    end

    add_index :idea_comments, [ :idea_id, :created_at ]
  end
end
