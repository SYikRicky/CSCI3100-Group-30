class RemoveStatusFromLeagues < ActiveRecord::Migration[8.1]
  def change
    remove_column :leagues, :status, :string
  end
end
