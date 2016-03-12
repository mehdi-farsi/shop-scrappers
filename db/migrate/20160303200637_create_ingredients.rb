class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.text :ingredients
      t.text :additional_information

      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
