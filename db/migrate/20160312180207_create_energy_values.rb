class CreateEnergyValues < ActiveRecord::Migration
  def change
    create_table :energy_values do |t|
      t.string :name
      t.string :weight
      t.references :nutritional_value, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
