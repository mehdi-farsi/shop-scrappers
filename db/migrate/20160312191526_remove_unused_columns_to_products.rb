class RemoveUnusedColumnsToProducts < ActiveRecord::Migration
  def change
    remove_column :nutritional_values, :energy_value
    remove_column :nutritional_values, :additional_information
    remove_column :ingredients,        :additional_information
  end
end
