class CreateRisingInformations < ActiveRecord::Migration[8.0]
  def change
    create_table :rising_informations do |t|
      t.integer :item_id
      t.decimal :market_price
      t.string :description
      t.decimal :appreciation_rate
      t.boolean :is_displayed
      t.string :created_by_user_id

      t.timestamps
    end
    add_index :rising_informations, :created_by_user_id, unique: true
  end
end
