class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title,      default: ""
      t.string :picture,    default: ""
      t.text :description
      t.text :conservation

      t.references :subsection, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
