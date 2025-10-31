class Announcement < ApplicationRecord
    has_many :announcement_tags, dependent: :destroy
    # throughを指定することでコントローラで明示する必要なし.
    has_many :tags, through: :announcement_tags
  
    validates :title, :content, presence: true
end
  