class RemoveBodyAndChartUrlFromIdeas < ActiveRecord::Migration[8.1]
  def change
    remove_column :ideas, :body, :text, null: false
    remove_column :ideas, :chart_url, :string
  end
end
