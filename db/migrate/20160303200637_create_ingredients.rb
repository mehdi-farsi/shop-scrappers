class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.text :ingredients,            default: ""
      t.text :additional_information, default: ""

      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
