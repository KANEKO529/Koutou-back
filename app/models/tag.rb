class Tag < ApplicationRecord
    has_many :announcement_tags, dependent: :destroy
    has_many :announcements, through: :announcement_tags

    # おすすめ記事
    has_many :featured_articles, dependent: :destroy
    has_many :recommend_articles, through: :featured_articles
  
    validates :name, presence: true, uniqueness: true
end
  