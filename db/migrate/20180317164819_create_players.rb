class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :name, index: true
      t.integer :active_year_begin
      t.integer :active_year_end
      t.string :handle, index: { unique: true }
      t.string :image

      t.timestamps
    end
  end
end
