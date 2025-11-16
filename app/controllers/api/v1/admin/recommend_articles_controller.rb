class Api::V1::Admin::RecommendArticlesController < ApplicationController
    before_action :set_recommend_article, only: [:update, :destroy, :toggle_status]
  
    # 一覧
    def index
      articles = RecommendArticle.includes(:featured_articles, :tags).order(id: :desc)
      
      render json: {
        status: "success",
        data: articles.map { |a| serialize_admin_article(a) }
      }
    end
  
    # 新規登録
    def create
      article = RecommendArticle.new(recommend_article_params)
  
      if article.save
        create_featured_articles(article)
        render json: { status: "success", message: "おすすめ記事を登録しました", data: serialize_admin_article(article) }
      else
        render json: { status: "error", message: article.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # 更新
    def update
      if @recommend_article.update(recommend_article_params)
        update_featured_articles(@recommend_article)
        render json: { status: "success", message: "おすすめ記事を更新しました", data: serialize_admin_article(@recommend_article) }
      else
        render json: { status: "error", message: @recommend_article.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # 削除
    def destroy
      @recommend_article.destroy
      render json: { status: "success", message: "おすすめ記事を削除しました", id: @recommend_article.id }
    end
  
    # ステータス切り替え
    def toggle_status
      @recommend_article.update(status: !@recommend_article.status)
      message = @recommend_article.status ? "記事を公開しました" : "記事を下書きにしました"
      render json: {
        status: "success",
        message: message,
        data: { id: @recommend_article.id, status: @recommend_article.status, updated_at: @recommend_article.updated_at }
      }
    end
  
    private
  
    def set_recommend_article
      @recommend_article = RecommendArticle.find(params[:id])
    end
  
    def recommend_article_params
      params.require(:recommend_article).permit(:article_url, :status, :created_by_author_id)
    end
  
    def featured_article_params
      params.require(:featured_article).permit(:section_name, :position, tag_ids: [])
    end
  
    def create_featured_articles(article)
      featured_article_params[:tag_ids]&.each do |tag_id|
        article.featured_articles.create!(
          tag_id: tag_id,
          section_name: featured_article_params[:section_name],
          position: featured_article_params[:position],
          created_by_author_id: article.created_by_author_id
        )
      end
    end
  
    def update_featured_articles(article)
      article.featured_articles.destroy_all
      create_featured_articles(article)
    end
  
    def serialize_admin_article(article)
      meta = Rails.cache.fetch("meta:#{article.article_url}", expires_in: 12.hours) do
        MetadataFetchService.fetch(article.article_url)
      end
  
      {
        article_id: article.id,
        article_url: article.article_url,
        title: meta[:title],
        description: meta[:description],
        image_url: meta[:image_url],
        status: article.status,
        position: article.featured_articles.first&.position,
        section_name: article.featured_articles.first&.section_name,
        tags: article.tags.pluck(:name),
        author: { id: article.created_by_author_id, name: "管理チーム" }
      }
    end
  end
  