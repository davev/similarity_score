class CreateSimilarPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :similar_players do |t|
      t.references :player, foreign_key: true
      t.references :similar_player, index: true, foreign_key: { to_table: :players }
      t.integer :age
      t.float :score, null: false, index: true
      t.integer :player_type, null: false

      t.timestamps
    end

    add_index :similar_players, [:player_type, :age, :score]
  end
end
