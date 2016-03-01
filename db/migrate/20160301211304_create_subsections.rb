class CreateSubsections < ActiveRecord::Migration
  def change
    create_table :subsections do |t|
      t.string :name
      t.string :href
      t.references :section, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
