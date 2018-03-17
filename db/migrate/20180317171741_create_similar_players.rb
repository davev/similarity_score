class CreateSimilarPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :similar_players do |t|
      t.references :player, null: false, foreign_key: true, index: true
      t.references :related_player, null: false, index: true, foreign_key: { to_table: :players }
      t.integer :age
      t.float :score, null: false, index: true
      t.integer :player_type, null: false

      t.timestamps
    end

    add_index :similar_players, [:player_type, :age, :score]
    add_index :similar_players, [:player_id, :related_player_id], unique: true
  end
end
