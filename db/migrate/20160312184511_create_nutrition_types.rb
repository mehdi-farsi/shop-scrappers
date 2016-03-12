class CreateNutritionTypes < ActiveRecord::Migration
  def change
    create_table :nutrition_types do |t|
      t.string     :name
      t.string     :weight
      t.references :nutritional_value, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
