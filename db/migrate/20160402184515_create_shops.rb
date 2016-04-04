class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.text :address
      t.float :lat
      t.float :lng
      t.string :monday
      t.string :tuesday
      t.string :wednesday
      t.string :thursday
      t.string :friday
      t.string :saturday
      t.string :sunday
      t.references :website, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
