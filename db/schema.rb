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

ActiveRecord::Schema[8.0].define(version: 2025_11_16_123345) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "announcement_tags", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_tags_on_announcement_id"
    t.index ["tag_id"], name: "index_announcement_tags_on_tag_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "published_at"
    t.boolean "status", default: false, null: false
    t.string "created_by_author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "featured_articles", force: :cascade do |t|
    t.bigint "recommend_article_id", null: false
    t.bigint "tag_id"
    t.integer "position", default: 0, null: false
    t.string "section_name"
    t.string "created_by_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recommend_article_id"], name: "index_featured_articles_on_recommend_article_id"
    t.index ["tag_id"], name: "index_featured_articles_on_tag_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "item_name"
    t.string "model_number"
    t.decimal "regular_price"
    t.date "release_date"
    t.string "merkari_image_url"
    t.string "merkari_url"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recommend_articles", force: :cascade do |t|
    t.string "article_url", null: false
    t.boolean "status", default: false, null: false
    t.string "created_by_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_url"], name: "index_recommend_articles_on_article_url", unique: true
  end

  create_table "rising_informations", force: :cascade do |t|
    t.integer "item_id"
    t.decimal "market_price"
    t.string "description"
    t.decimal "appreciation_rate"
    t.boolean "is_displayed"
    t.string "created_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_rising_informations_on_created_by_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "clerk_user_id"
    t.string "role"
    t.string "user_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clerk_user_id"], name: "index_users_on_clerk_user_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "announcement_tags", "announcements"
  add_foreign_key "announcement_tags", "tags"
  add_foreign_key "featured_articles", "recommend_articles"
  add_foreign_key "featured_articles", "tags"
end
