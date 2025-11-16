class FeaturedArticle < ApplicationRecord
    belongs_to :recommend_article
    belongs_to :tag, optional: true
  
    enum section_name: {
      top_recommendation: 'top_recommendation'
    }
  
    validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
  