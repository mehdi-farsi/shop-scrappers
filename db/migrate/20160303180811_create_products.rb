class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title,      default: ""
      t.float :unit_price,  default: 0.0
      t.string :weight,     default: ""
      t.string :picture,    default: ""
      t.text :description,  default: ""
      t.text :conservation, default: ""

      t.references :subsection, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
