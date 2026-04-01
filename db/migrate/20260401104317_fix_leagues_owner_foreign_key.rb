class FixLeaguesOwnerForeignKey < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key "leagues", "owners"
    add_foreign_key "leagues", "users", column: "owner_id"
  end
end
