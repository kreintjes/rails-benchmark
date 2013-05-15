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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130515105402) do

  create_table "all_types_objects", :force => true do |t|
    t.binary   "binary_col"
    t.boolean  "boolean_col"
    t.date     "date_col"
    t.datetime "datetime_col"
    t.decimal  "decimal_col"
    t.float    "float_col"
    t.integer  "integer_col"
    t.string   "string_col"
    t.text     "text_col"
    t.time     "time_col"
    t.datetime "timestamp_col"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
