class CreateWeights < ActiveRecord::Migration
  def change
    create_table :weights do |t|
      t.string :size
      t.string :unit
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
