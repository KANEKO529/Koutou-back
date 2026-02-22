class CreateRecommendArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :recommend_articles do |t|
      t.string :article_url, null: false
      t.boolean :status, default: false, null: false
      t.string :created_by_author_id
      t.timestamps
    end
    add_index :recommend_articles, :article_url, unique: true
  end
end
