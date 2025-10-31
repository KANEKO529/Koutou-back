class CreateAnnouncementsAndTags < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.string   :title, null: false
      t.text     :content, null: false
      t.datetime :published_at
      t.boolean  :status, default: false, null: false
      t.string   :created_by_author_id, null: false
      t.timestamps
    end

    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :announcement_tags do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
  end
end
