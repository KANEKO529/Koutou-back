ActiveRecord::Schema[8.0].define(version: 2025_09_22_111205) do
  # create_schema "auth"
  # create_schema "extensions"
  # create_schema "graphql"
  # create_schema "graphql_public"
  # create_schema "pgbouncer"
  # create_schema "realtime"
  # create_schema "storage"
  # create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

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
end
