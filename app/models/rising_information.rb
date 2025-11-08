class RisingInformation < ApplicationRecord
    # アソシエーション
    belongs_to :item
    # belongs_to :created_by_user, class_name: 'User', foreign_key: 'created_by_user_id', optional: true

    # バリデーション
    validates :item_id, presence: true
    validates :market_price, presence: true, numericality: { greater_than: 0 }
    validates :appreciation_rate, numericality: { greater_than: 0, allow_nil: true }
    validates :description, length: { maximum: 1000 }
    validates :is_displayed, inclusion: { in: [true, false] }
    validates :created_by_user_id, presence: true

    # スコープ
    scope :displayed, -> { where(is_displayed: true) }

    scope :search_by_keyword, ->(keyword) {
        return all if keyword.blank?

        # 全角・半角スペースで分割して配列化
        keywords = keyword.split(/[\s　]+/).reject(&:blank?)
        return all if keywords.empty?

        # items と rising_informations の両方を対象に部分一致検索
        joins(:item).where(
            keywords.map { |kw|
            sanitized = sanitize_sql_like(kw)
            "(items.item_name ILIKE '%#{sanitized}%' OR
                items.model_number ILIKE '%#{sanitized}%' OR
                rising_informations.description ILIKE '%#{sanitized}%')"
            }.join(' AND ')
        )
    }

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
