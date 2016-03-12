class CreateIngredientTypes < ActiveRecord::Migration
  def change
    create_table :ingredient_types do |t|
      t.string     :name
      t.text       :info
      t.references :ingredient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
