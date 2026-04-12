class CreateIdeaTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_taggings do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :idea_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :idea_taggings, [ :idea_id, :idea_tag_id ], unique: true
  end
end
