require "csv"

namespace :poc do
  desc "Register dummy item embeddings for PoC search-speed evaluation. " \
       "Usage: bin/rails poc:generate_dummy_embeddings[path/to/model_number_list.csv]"
  task :generate_dummy_embeddings, [:csv_path] => :environment do |_task, args|
    csv_path = args[:csv_path]

    abort("Usage: bin/rails poc:generate_dummy_embeddings[path/to/csv]") if csv_path.blank?
    abort("CSV file not found: #{csv_path}") unless File.exist?(csv_path)

    stats = Hash.new(0)

    CSV.foreach(csv_path, headers: true) do |row|
      stats[:total] += 1
      model_number = row["model_number"].to_s.strip.upcase

      if model_number.blank?
        Rails.logger.warn("[Poc::GenerateDummyEmbeddings] row #{stats[:total]}: blank model_number, skipping")
        stats[:skipped_blank] += 1
        next
      end

      item = Item.find_by(model_number: model_number)

      if item.nil?
        Rails.logger.warn("[Poc::GenerateDummyEmbeddings] model_number=#{model_number}: item not found, skipping")
        stats[:skipped_not_found] += 1
        next
      end

      if Poc::DummyEmbeddingGenerator::TARGET_MODEL_NUMBERS.include?(model_number)
        stats[:skipped_target] += 1
        next
      end

      if item.item_embeddings.exists?
        stats[:skipped_existing] += 1
        next
      end

      embedding = Poc::DummyEmbeddingGenerator.call

      if embedding.nil?
        Rails.logger.warn("[Poc::GenerateDummyEmbeddings] model_number=#{model_number}: dummy embedding generation failed, skipping")
        stats[:skipped_generation_failed] += 1
        next
      end

      item.item_embeddings.create!(embedding: embedding)
      stats[:registered] += 1
    end

    puts "==== poc:generate_dummy_embeddings summary ===="
    puts "csv rows processed:          #{stats[:total]}"
    puts "registered:                  #{stats[:registered]}"
    puts "skipped (blank model_number):#{stats[:skipped_blank]}"
    puts "skipped (item not found):    #{stats[:skipped_not_found]}"
    puts "skipped (target item):       #{stats[:skipped_target]}"
    puts "skipped (already has embedding): #{stats[:skipped_existing]}"
    puts "skipped (generation failed): #{stats[:skipped_generation_failed]}"
  end
end
