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

ActiveRecord::Schema.define(version: 2022_12_06_151543) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "api_keys", force: :cascade do |t|
    t.integer "bearer_id", null: false
    t.string "bearer_type", null: false
    t.string "token_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bearer_id", "bearer_type"], name: "index_api_keys_on_bearer_id_and_bearer_type"
    t.index ["token_digest"], name: "index_api_keys_on_token_digest", unique: true
  end

  create_table "email_logs", force: :cascade do |t|
    t.string "recipient"
    t.string "subject"
    t.text "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invites", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "invite_code", limit: 40
    t.datetime "invited_at"
    t.datetime "redeemed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false
    t.index ["id", "email"], name: "index_invites_on_id_and_email", unique: true
    t.index ["id", "invite_code"], name: "index_invites_on_id_and_invite_code", unique: true
  end

  create_table "participants", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "country"
    t.string "self_generated_id"
    t.string "rds_id"
    t.string "code"
    t.string "referrer_code"
    t.string "sgm_group"
    t.string "referrer_sgm_group"
    t.boolean "match"
    t.integer "raffles_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "preferred_contact_method"
    t.boolean "verified", default: false
    t.string "verification_code"
    t.string "name"
    t.boolean "seed", default: false
    t.boolean "remind", default: true
    t.boolean "enter_raffle", default: true
    t.boolean "raffle_quota_met", default: false
    t.string "seed_id"
    t.index ["code"], name: "index_participants_on_code", unique: true
    t.index ["email"], name: "index_participants_on_email"
  end

  create_table "raffles", force: :cascade do |t|
    t.integer "participant_id"
    t.boolean "completion_entry", default: false
    t.boolean "recruitment_entry", default: true
    t.string "recruitee_code"
    t.string "response_uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["participant_id", "recruitee_code"], name: "index_raffles_on_participant_id_and_recruitee_code", unique: true
    t.index ["participant_id", "response_uuid"], name: "index_raffles_on_participant_id_and_response_uuid", unique: true
  end

  create_table "reminders", force: :cascade do |t|
    t.integer "participant_id"
    t.integer "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "survey_responses", force: :cascade do |t|
    t.integer "participant_id"
    t.string "survey_uuid"
    t.string "response_uuid"
    t.boolean "survey_complete"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "survey_title"
    t.string "country"
    t.boolean "eligible", default: true
    t.boolean "consented", default: true
    t.hstore "metadata"
    t.index ["metadata"], name: "index_survey_responses_on_metadata", using: :gist
    t.index ["participant_id"], name: "index_survey_responses_on_participant_id"
    t.index ["response_uuid"], name: "index_survey_responses_on_response_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", limit: 128
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

end
