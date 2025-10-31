class Api::V1::Admin::AnnouncementsController < ApplicationController
  # GET /api/v1/admin/announcements
  def index
    @announcements = Announcement.includes(:tags).order(published_at: :asc)

    render json: {
      status: 'success',
      data: @announcements.map { |a| announcement_data(a) }
    }
  end

  # GET /api/v1/admin/announcements/:id 
  def show
    @announcement = Announcement.includes(:tags).find(params[:id])
    
    render json: {
      status: 'success',
      data: announcement_data(@announcement)
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'お知らせが見つかりません'
    }, status: :not_found
  end

  # POST /api/v1/admin/announcements
  def create
    ActiveRecord::Base.transaction do
      tag_names = params[:tag_names] || []
      tags = tag_names.map { |name| Tag.find_or_create_by!(name:) }

      @announcement = Announcement.new(announcement_params)
      # ここで中間テーブルAnnouncementsTagにレコードを自動的に追加
      @announcement.tags = tags

      raise ActiveRecord::RecordInvalid.new(@announcement) unless @announcement.save

      render json: {
        status: 'success',
        message: 'お知らせが正常に作成されました',
        data: announcement_data(@announcement)
      }, status: :created
    end

  rescue ActiveRecord::RecordInvalid => e
    render json: {
      status: 'error',
      message: '作成に失敗しました',
      errors: e.record.errors
    }, status: :unprocessable_entity
  rescue StandardError => e
    render json: {
      status: 'error',
      message: "予期しないエラー: #{e.message}"
    }, status: :internal_server_error
  end

  # PUT /api/v1/admin/announcements/:id
  def update
    ActiveRecord::Base.transaction do
      @announcement = Announcement.find(params[:id])

      tag_names = params[:tag_names] || []
      tags = tag_names.map { |name| Tag.find_or_create_by!(name:) }

      raise ActiveRecord::RecordInvalid.new(@announcement) unless @announcement.update(announcement_params.merge(tags: tags))

      render json: {
        status: 'success',
        message: 'お知らせが正常に更新されました',
        data: announcement_data(@announcement)
      }
    end

  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'お知らせが見つかりません'
    }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      status: 'error',
      message: '更新に失敗しました',
      errors: e.record.errors
    }, status: :unprocessable_entity
  rescue StandardError => e
    render json: {
      status: 'error',
      message: "予期しないエラー: #{e.message}"
    }, status: :internal_server_error
  end

  # DELETE /api/v1/admin/announcements/:id
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy!

    render json: {
      status: 'success',
      message: 'お知らせが正常に削除されました',
      id: @announcement.id
    }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'お知らせが見つかりません'
    }, status: :not_found
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: {
      status: 'error',
      message: '削除に失敗しました',
      errors: e.record.errors
    }, status: :unprocessable_entity
  rescue StandardError => e
    render json: {
      status: 'error',
      message: "予期しないエラー: #{e.message}"
    }, status: :internal_server_error
  end

  private

  def announcement_params
    params.require(:announcement).permit(
      :title,
      :content,
      :status,
      :published_at,
      :created_by_author_id
    )
  end

  def announcement_data(announcement)
    {
      id: announcement.id,
      title: announcement.title,
      content: announcement.content,
      status: announcement.status,
      published_at: announcement.published_at,
      updated_at: announcement.updated_at,
      tags: announcement.tags.pluck(:name)
    }
  end

end
