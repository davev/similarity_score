class RemovePlayerTypeFromSimilarPlayer < ActiveRecord::Migration[5.1]
  def change
    remove_column :similar_players, :player_type, :integer
  end
end
