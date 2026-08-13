class ItemEmbeddingSearchService
  EMBEDDING_DIMENSION = 384
  DEFAULT_TOP_K = 3
  DEFAULT_THRESHOLD = 0.0

  def self.call(embedding:, top_k: DEFAULT_TOP_K, threshold: DEFAULT_THRESHOLD)
    new(embedding: embedding, top_k: top_k, threshold: threshold).call
  end

  def initialize(embedding:, top_k:, threshold:)
    @embedding = embedding
    @top_k = top_k
    @threshold = threshold
  end

  def call
    validate!

    best_similarity_by_item_id = {}

    ItemEmbedding
      .select(:item_id)
      .nearest_neighbors(:embedding, embedding, distance: :cosine)
      .each do |item_embedding|
        similarity = 1 - item_embedding.neighbor_distance
        next if similarity < threshold

        current = best_similarity_by_item_id[item_embedding.item_id]
        best_similarity_by_item_id[item_embedding.item_id] = similarity if current.nil? || similarity > current
      end

    best_similarity_by_item_id
      .map { |item_id, similarity| { item_id: item_id, similarity: similarity } }
      .sort_by { |result| -result[:similarity] }
      .first(top_k)
  end

  private

  attr_reader :embedding, :top_k, :threshold

  def validate!
    raise ArgumentError, "embedding must be an array of #{EMBEDDING_DIMENSION} numbers" unless valid_embedding?
    raise ArgumentError, "top_k must be a positive integer" unless top_k.is_a?(Integer) && top_k.positive?
    raise ArgumentError, "threshold must be a number between -1 and 1" unless valid_threshold?
  end

  def valid_embedding?
    embedding.is_a?(Array) &&
      embedding.length == EMBEDDING_DIMENSION &&
      embedding.all? { |value| value.is_a?(Numeric) }
  end

  def valid_threshold?
    threshold.is_a?(Numeric) && threshold >= -1 && threshold <= 1
  end
end
