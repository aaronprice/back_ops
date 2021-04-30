# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_30_151503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "back_ops_actions", force: :cascade do |t|
    t.bigint "operation_id"
    t.integer "order", default: 0, null: false
    t.text "branch"
    t.text "name"
    t.datetime "perform_at"
    t.text "error_message"
    t.text "stack_trace"
    t.datetime "errored_at"
    t.datetime "completed_at"
    t.integer "attempts_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["operation_id"], name: "index_back_ops_actions_on_operation_id"
  end

  create_table "back_ops_operations", force: :cascade do |t|
    t.string "name"
    t.string "params_hash"
    t.jsonb "globals", default: {}, null: false
    t.bigint "next_action_id"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "params_hash"], name: "index_back_ops_operations_on_name_and_params_hash"
  end

  create_table "widgets", force: :cascade do |t|
    t.string "state"
  end

end
