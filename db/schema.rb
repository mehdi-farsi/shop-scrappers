# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160312191526) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "website_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["website_id"], name: "index_categories_on_website_id", using: :btree

  create_table "energy_values", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "weight",               limit: 255
    t.string   "unit",                 limit: 255
    t.integer  "nutritional_value_id", limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "energy_values", ["nutritional_value_id"], name: "index_energy_values_on_nutritional_value_id", using: :btree

  create_table "ingredient_types", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.text     "info",          limit: 65535
    t.integer  "ingredient_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "ingredient_types", ["ingredient_id"], name: "index_ingredient_types_on_ingredient_id", using: :btree

  create_table "ingredients", force: :cascade do |t|
    t.text     "ingredients", limit: 65535
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "ingredients", ["product_id"], name: "index_ingredients_on_product_id", using: :btree

  create_table "nutrition_types", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "weight",               limit: 255
    t.string   "unit",                 limit: 255
    t.integer  "nutritional_value_id", limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "nutrition_types", ["nutritional_value_id"], name: "index_nutrition_types_on_nutritional_value_id", using: :btree

  create_table "nutritional_values", force: :cascade do |t|
    t.text     "information", limit: 65535
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "nutritional_values", ["product_id"], name: "index_nutritional_values_on_product_id", using: :btree

  create_table "pricings", force: :cascade do |t|
    t.string   "unit_price",     limit: 255
    t.string   "price_per_kilo", limit: 255
    t.datetime "extracted_at"
    t.integer  "product_id",     limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "pricings", ["product_id"], name: "index_pricings_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title",             limit: 255,   default: ""
    t.string   "picture",           limit: 255,   default: ""
    t.text     "description",       limit: 65535
    t.text     "conservation",      limit: 65535
    t.integer  "subsection_id",     limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "brand",             limit: 255
    t.string   "url",               limit: 255
    t.string   "conservation_type", limit: 255
  end

  add_index "products", ["subsection_id"], name: "index_products_on_subsection_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "category_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "sections", ["category_id"], name: "index_sections_on_category_id", using: :btree

  create_table "subsections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "href",       limit: 255
    t.integer  "section_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "subsections", ["section_id"], name: "index_subsections_on_section_id", using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "weights", force: :cascade do |t|
    t.string   "size",       limit: 255
    t.string   "unit",       limit: 255
    t.integer  "product_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "weights", ["product_id"], name: "index_weights_on_product_id", using: :btree

  add_foreign_key "categories", "websites"
  add_foreign_key "energy_values", "nutritional_values"
  add_foreign_key "ingredient_types", "ingredients"
  add_foreign_key "ingredients", "products"
  add_foreign_key "nutrition_types", "nutritional_values"
  add_foreign_key "nutritional_values", "products"
  add_foreign_key "pricings", "products"
  add_foreign_key "products", "subsections"
  add_foreign_key "sections", "categories"
  add_foreign_key "subsections", "sections"
  add_foreign_key "weights", "products"
end
