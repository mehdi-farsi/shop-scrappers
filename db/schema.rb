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

ActiveRecord::Schema.define(version: 20160303200755) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "website_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "categories", ["website_id"], name: "index_categories_on_website_id"

  create_table "ingredients", force: :cascade do |t|
    t.text     "ingredients",            default: ""
    t.text     "additional_information", default: ""
    t.integer  "product_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "ingredients", ["product_id"], name: "index_ingredients_on_product_id"

  create_table "nutritional_values", force: :cascade do |t|
    t.text     "information",            default: ""
    t.text     "energy_value",           default: ""
    t.text     "additional_information", default: ""
    t.integer  "product_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "nutritional_values", ["product_id"], name: "index_nutritional_values_on_product_id"

  create_table "products", force: :cascade do |t|
    t.string   "title",         default: ""
    t.float    "unit_price",    default: 0.0
    t.string   "weight",        default: ""
    t.string   "picture",       default: ""
    t.text     "description",   default: ""
    t.text     "conservation",  default: ""
    t.integer  "subsection_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "products", ["subsection_id"], name: "index_products_on_subsection_id"

  create_table "sections", force: :cascade do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sections", ["category_id"], name: "index_sections_on_category_id"

  create_table "subsections", force: :cascade do |t|
    t.string   "name"
    t.string   "href"
    t.integer  "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subsections", ["section_id"], name: "index_subsections_on_section_id"

  create_table "websites", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
