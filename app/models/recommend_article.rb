class RecommendArticle < ApplicationRecord
    has_many :featured_articles, dependent: :destroy
    has_many :tags, through: :featured_articles
  
    validates :article_url, presence: true, uniqueness: true
  end  