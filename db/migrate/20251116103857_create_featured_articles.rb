class CreateFeaturedArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :featured_articles do |t|
      t.references :recommend_article, null: false, foreign_key: true
      t.references :tag, foreign_key: true
      t.integer :position, default: 0, null: false
      t.string :section_name, null: false
      t.string :created_by_author_id
      t.timestamps
    end
  end
end
