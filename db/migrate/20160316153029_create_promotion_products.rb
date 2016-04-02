class CreatePromotionProducts < ActiveRecord::Migration
  def change
    create_table :promotion_products do |t|
      t.string     :name
      t.string     :url
      t.text       :description_offer
      t.text       :information_offer
      t.boolean    :card_offer
      t.references :promotion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
