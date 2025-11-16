require 'open-uri'
require 'nokogiri'

class MetadataFetcheService
  def self.fetch(url)
    html = URI.open(url, "User-Agent" => "Mozilla/5.0").read
    doc = Nokogiri::HTML(html)

    {
      title: doc.at('meta[property="og:title"]')&.[]('content') || doc.title,
      description: doc.at('meta[property="og:description"]')&.[]('content'),
      image_url: doc.at('meta[property="og:image"]')&.[]('content')
    }
    
  rescue => e
    Rails.logger.error("[MetaFetcher] Failed to fetch metadata from #{url}: #{e.message}")
    { title: nil, description: nil, image_url: nil, error: e.message }
  end
end
