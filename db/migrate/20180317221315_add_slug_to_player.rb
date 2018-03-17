class AddSlugToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :slug, :string
  end
end
