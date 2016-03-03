class CreateNutritionalValues < ActiveRecord::Migration
  def change
    create_table :nutritional_values do |t|
      t.text :information,            default: ""
      t.text :energy_value,           default: ""
      t.text :additional_information, default: ""

      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
