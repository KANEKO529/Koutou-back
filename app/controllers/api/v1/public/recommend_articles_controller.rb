class Api::V1::Public::RecommendArticlesController < ApplicationController
    def index
        articles = RecommendArticle
                    .includes(:featured_articles, :tags)
                    .where(status: true)
    
        # section_name絞り込み
        if params[:section_name].present?
            articles = articles.joins(:featured_articles).where(featured_articles: { section_name: params[:section_name] }) 
        end

    
        # tag_name絞り込み
        if params[:tag_name].present?
            articles = articles.joins(:tags).where(tags: { name: params[:tag_name] })
        end
    
        # 並び順
        articles = articles.left_joins(:featured_articles)
                            .order('featured_articles.position ASC NULLS LAST, recommend_articles.created_at DESC')
    
        render json: {
            status: "success",
            data: articles.map { |a| serialize_article(a) }
        }
    end
  
    private
  
    def serialize_article(article)
    
        #ここで取得
        meta = Rails.cache.fetch("meta:#{article.article_url}", expires_in: 12.hours) do
            MetadataFetchService.fetch(article.article_url)
        end
    
        {
            article_id: article.id,
            article_url: article.article_url,
            title: meta[:title] || "タイトル情報なし",
            description: meta[:description],
            image_url: meta[:image_url],
            tags: article.tags.pluck(:name),
            author: {
            id: article.created_by_author_id,
            name: "管理チーム"
            }
        }
    rescue => e
      Rails.logger.error("[RecommendArticles] Meta fetch failed for #{article.article_url}: #{e.message}")
      {
        article_id: article.id,
        article_url: article.article_url,
        title: "取得エラー",
        description: "この記事の情報を取得できませんでした",
        image_url: nil,
        tags: article.tags.pluck(:name),
        author: { id: article.created_by_author_id, name: "管理チーム" }
      }
    end
  end
  