class AddEanToProduct < ActiveRecord::Migration
  def change
    add_column :products, :ean, :string
  end
end
