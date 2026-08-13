class ItemEmbedding < ApplicationRecord
  belongs_to :item

  has_neighbors :embedding
end
