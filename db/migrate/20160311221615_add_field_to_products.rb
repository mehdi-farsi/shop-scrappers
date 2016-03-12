class AddFieldToProducts < ActiveRecord::Migration
  def change
    add_column :products, :brand, :string
    add_column :products, :url, :string
    add_column :products, :conservation_type, :string
  end
end
