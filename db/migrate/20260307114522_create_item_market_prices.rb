class CreateItemMarketPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :item_market_prices do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :market_price
      t.datetime :recorded_at
      t.text :memo

      t.timestamps
    end

    add_index :item_market_prices, :recorded_at
    add_index :item_market_prices, [:item_id, :recorded_at]
  end
end