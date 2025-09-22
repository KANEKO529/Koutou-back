class RemoveUniqueIndexFromRisingInformations < ActiveRecord::Migration[8.0]
  def change
    remove_index :rising_informations, :created_by_user_id
    # 通常のインデックスを追加（オプション）
    add_index :rising_informations, :created_by_user_id
  end
end
