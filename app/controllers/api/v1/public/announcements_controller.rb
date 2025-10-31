class Api::V1::Public::AnnouncementsController < ApplicationController
  # GET /api/v1/public/announcements
  def index
    @announcements = Announcement.includes(:tags)
                                    .where(status: true)
                                    .order(published_at: :asc)

    render json: {
      status: 'success',
      data: @announcements.map { |announcement| announcement_data(announcement) }
    }
  end

  # GET /api/v1/public//announcements/:id
  def show
    @announcement = Announcement.includes(:tags).where(status: true).find(params[:id])
    
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

  private

  def announcement_data(announcement)
    {
      id: announcement.id,
      title: announcement.title,
      content: announcement.content,
      published_at: announcement.published_at,
      updated_at: announcement.updated_at,
      tags: announcement.tags.pluck(:name)
    }
  end

end
