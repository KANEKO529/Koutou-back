module Poc
  class DummyEmbeddingGenerator
    EMBEDDING_DIMENSION = 384
    SIMILARITY_THRESHOLD = 0.85
    MAX_ATTEMPTS = 10

    TARGET_MODEL_NUMBERS = %w[
      NTR-IPGJ-JPN
      NTR-A5RJ-JPN
      NTR-B2OJ-JPN
      NTR-A6DJ-JPN
      NTR-YH4J-JPN
      NTR-AJUJ-JPN
      NTR-A4VJ-JPN
      NTR-YHTJ-JPN
    ].freeze

    def self.call
      new.call
    end

    def self.target_embeddings
      @target_embeddings ||= ItemEmbedding
        .joins(:item)
        .where(items: { model_number: TARGET_MODEL_NUMBERS })
        .pluck(:embedding)
    end

    def call
      MAX_ATTEMPTS.times do
        candidate = generate_candidate
        return candidate if max_similarity_to_targets(candidate) < SIMILARITY_THRESHOLD
      end

      Rails.logger.warn(
        "[Poc::DummyEmbeddingGenerator] gave up after #{MAX_ATTEMPTS} attempts: " \
        "could not generate an embedding below similarity threshold #{SIMILARITY_THRESHOLD}"
      )
      nil
    end

    private

    def generate_candidate
      normalize(Array.new(EMBEDDING_DIMENSION) { rand(-1.0..1.0) })
    end

    def normalize(vector)
      norm = Math.sqrt(vector.sum { |value| value * value })
      vector.map { |value| value / norm }
    end

    def max_similarity_to_targets(vector)
      self.class.target_embeddings.map { |target| cosine_similarity(vector, target) }.max || -1.0
    end

    def cosine_similarity(a, b)
      dot_product = a.zip(b).sum { |x, y| x * y }
      norm_a = Math.sqrt(a.sum { |x| x * x })
      norm_b = Math.sqrt(b.sum { |y| y * y })
      dot_product / (norm_a * norm_b)
    end
  end
end
