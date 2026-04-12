class CreateIdeaTags < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :idea_tags, :name, unique: true
  end
end
