class CreatePricings < ActiveRecord::Migration
  def change
    create_table :pricings do |t|
      t.string     :unit_price
      t.string     :price_per_kilo
      t.datetime   :extracted_at
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
