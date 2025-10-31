class Tag < ApplicationRecord
    has_many :announcement_tags, dependent: :destroy
    has_many :announcements, through: :announcement_tags
  
    validates :name, presence: true, uniqueness: true
end
  