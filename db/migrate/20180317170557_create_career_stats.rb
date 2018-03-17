class CreateCareerStats < ActiveRecord::Migration[5.1]
  def change
    create_table :career_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.float :war
      t.integer :ab
      t.integer :r
      t.integer :h
      t.float :ba
      t.integer :hr
      t.integer :rbi
      t.float :obp
      t.float :slg
      t.float :ops
      t.integer :ops_plus

      t.timestamps
    end
  end
end
