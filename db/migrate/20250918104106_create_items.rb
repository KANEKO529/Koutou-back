class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :item_name
      t.string :model_number
      t.decimal :regular_price
      t.date :release_date
      t.string :merkari_image_url
      t.string :merkari_url
      t.string :image_url

      t.timestamps
    end
  end
end
