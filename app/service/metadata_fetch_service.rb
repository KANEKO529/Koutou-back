require 'open-uri'
require 'nokogiri'

class MetadataFetchService
    def self.fetch(url)
      html = URI.open(url, "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)").read
      doc = Nokogiri::HTML(html)
  
      {
        title: doc.at('meta[property="og:title"]')&.[]('content') || doc.title || "タイトル不明",
        description: doc.at('meta[property="og:description"]')&.[]('content') || "この記事の情報を取得できませんでした",
        image_url: doc.at('meta[property="og:image"]')&.[]('content')
      }
    rescue => e
      Rails.logger.error("[MetaFetcher] Failed to fetch metadata from #{url}: #{e.message}")
      {
        title: "取得エラー",
        description: "この記事の情報を取得できませんでした",
        image_url: nil
      }
    end
  end
  
