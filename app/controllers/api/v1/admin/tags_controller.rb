class Api::V1::Admin::TagsController < ApplicationController
  # GET /api/v1/admin/tags
  def index
    @tags = Tag.order(:id)

    render json: {
      status: 'success',
      data: @tags.map { |tag| tag_data(tag) }
    }
  end

  # GET /api/v1/admin/tags/:id
  def show
    @tag = Tag.find(params[:id])

    render json: {
      status: 'success',
      data: tag_data(@tag)
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'タグが見つかりません'
    }, status: :not_found
  end

  # POST /api/v1/admin/tags
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: {
        status: 'success',
        message: 'タグが正常に作成されました',
        data: tag_data(@tag)
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'タグの作成に失敗しました',
        errors: @tag.errors
      }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/admin/tags/:id
  def update
    @tag = Tag.find(params[:id])

    if @tag.update(tag_params)
      render json: {
        status: 'success',
        message: 'タグが正常に更新されました',
        data: tag_data(@tag)
      }
    else
      render json: {
        status: 'error',
        message: 'タグの更新に失敗しました',
        errors: @tag.errors
      }, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'タグが見つかりません'
    }, status: :not_found
  end

  # DELETE /api/v1/admin/tags/:id
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy!

    render json: {
      status: 'success',
      message: 'タグが正常に削除されました',
      id: @tag.id
    }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'タグが見つかりません'
    }, status: :not_found
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: {
      status: 'error',
      message: '削除に失敗しました',
      errors: e.record.errors
    }, status: :unprocessable_entity
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end

  def tag_data(tag)
    {
      id: tag.id,
      name: tag.name,
      created_at: tag.created_at,
      updated_at: tag.updated_at
    }
  end
end