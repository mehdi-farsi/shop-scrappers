class CreateNutritionalValues < ActiveRecord::Migration
  def change
    create_table :nutritional_values do |t|
      t.text :information
      t.text :energy_value
      t.text :additional_information

      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
