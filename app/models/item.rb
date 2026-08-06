class Item < ApplicationRecord
    # バリデーション
    # validates :item_name, presence: true, length: { maximum: 255 }
    # validates :model_number, length: { maximum: 100 } #null OK
    # validates :regular_price, numericality: { greater_than: 0 }
    # validates :release_date
    # validates :merkari_url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "正しいURL形式で入力してください" }, allow_blank: true
    # validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "正しいURL形式で入力してください" }, allow_blank: true

    validates :item_name, presence: true, length: { maximum: 255 }
    validates :model_number, length: { maximum: 100 }, allow_blank: true
    validates :regular_price, numericality: { greater_than: 0, allow_nil: true }
    validates :merkari_url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "正しいURL形式で入力してください" }, allow_blank: true
    validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "正しいURL形式で入力してください" }, allow_blank: true

    # アソシエーション
    has_many :rising_informations, dependent: :destroy
    has_many :item_market_prices, dependent: :destroy
    
    # 現在表示中の高騰情報を取得
    def current_rising_info
        rising_informations.displayed.order(created_at: :desc).first
    end
end
