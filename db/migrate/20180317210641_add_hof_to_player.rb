class AddHofToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :hof, :boolean, index: true, null: false, default: false
  end
end
