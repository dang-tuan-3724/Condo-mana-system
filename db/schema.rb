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

ActiveRecord::Schema[8.0].define(version: 2025_08_05_102651) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "uuid-ossp"

  create_table "bookings", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "facility_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "purpose"
    t.string "status", default: "pending", null: false
    t.uuid "approved_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_bookings_on_approved_by_id"
    t.index ["facility_id", "start_time", "end_time"], name: "index_bookings_on_time_range"
    t.index ["facility_id"], name: "index_bookings_on_facility_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text, 'cancelled'::character varying::text])", name: "check_booking_status"
  end

  create_table "condos", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.jsonb "configuration", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_condos_on_name", unique: true
  end

  create_table "facilities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "condo_id", null: false
    t.text "description"
    t.jsonb "availability_schedule", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "floor"
    t.index ["condo_id", "name"], name: "index_facilities_on_condo_id_and_name", unique: true
    t.index ["condo_id"], name: "index_facilities_on_condo_id"
  end

  create_table "notifications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "message", null: false
    t.string "status", default: "unread", null: false
    t.string "category"
    t.uuid "reference_id"
    t.string "reference_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference_id", "reference_type"], name: "index_notifications_on_reference_id_and_reference_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
    t.check_constraint "status::text = ANY (ARRAY['unread'::character varying::text, 'read'::character varying::text])", name: "check_notification_status"
  end

  create_table "unit_members", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "unit_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id", "user_id"], name: "index_unit_members_on_unit_id_and_user_id", unique: true
    t.index ["unit_id"], name: "index_unit_members_on_unit_id"
    t.index ["user_id"], name: "index_unit_members_on_user_id"
  end

  create_table "units", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "unit_number", null: false
    t.uuid "condo_id", null: false
    t.uuid "house_owner_id"
    t.integer "floor"
    t.decimal "size", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condo_id", "unit_number"], name: "index_units_on_condo_id_and_unit_number", unique: true
    t.index ["condo_id"], name: "index_units_on_condo_id"
    t.index ["house_owner_id"], name: "index_units_on_house_owner_id"
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "role", default: "house_member", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.uuid "condo_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condo_id"], name: "index_users_on_condo_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "role::text = ANY (ARRAY['super_admin'::character varying::text, 'operation_admin'::character varying::text, 'house_owner'::character varying::text, 'house_member'::character varying::text])", name: "check_user_role"
  end

  add_foreign_key "bookings", "facilities"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "users", column: "approved_by_id"
  add_foreign_key "facilities", "condos"
  add_foreign_key "notifications", "users"
  add_foreign_key "unit_members", "units"
  add_foreign_key "unit_members", "users"
  add_foreign_key "units", "condos"
  add_foreign_key "units", "users", column: "house_owner_id"
  add_foreign_key "users", "condos"
end
