class CreateItemEmbeddings < ActiveRecord::Migration[8.0]
  def change
    create_table :item_embeddings do |t|
      t.references :item, null: false, foreign_key: true
      t.vector :embedding, limit: 384, null: false

      t.timestamps
    end
  end
end
