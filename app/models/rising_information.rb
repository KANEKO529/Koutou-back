class RisingInformation < ApplicationRecord
    # アソシエーション
    belongs_to :item
    # belongs_to :created_by_user, class_name: 'User', foreign_key: 'created_by_user_id', optional: true

    # バリデーション
    validates :item_id, presence: true
    validates :market_price, presence: true, numericality: { greater_than: 0 }
    validates :appreciation_rate, presence: true, numericality: true
    validates :description, presence: true, length: { maximum: 1000 }
    validates :is_displayed, inclusion: { in: [true, false] }
    validates :created_by_user_id, presence: true

    # スコープ
    scope :displayed, -> { where(is_displayed: true) }
    scope :by_appreciation_rate, -> { order(appreciation_rate: :desc) }

    # 計算メソッド
    def price_difference
        return 0 unless item&.regular_price && market_price
        market_price - item.regular_price
    end

    def calculated_appreciation_rate
        return 0 unless item&.regular_price && market_price && item.regular_price > 0
        ((market_price - item.regular_price) / item.regular_price * 100).round(2)
    end
end
