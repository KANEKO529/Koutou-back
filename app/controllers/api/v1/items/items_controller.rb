class Api::V1::Items::ItemsController < ApplicationController
  before_action :set_item, only: [:show, :update, :destroy]
  # before_action :verify_internal_api_key, only: [:search_by_model_number]

  # def search_by_model_number
  #   model_number = params[:model_number].to_s.strip.upcase

  #   if model_number.blank?
  #     render json: {
  #       status: "error",
  #       message: "model_number is required"
  #     }, status: :bad_request
  #     return
  #   end

  #   item = Item.includes(:item_market_prices).find_by(model_number: model_number)

  #   if item.nil?
  #     render json: {
  #       status: "error",
  #       message: "商品が見つかりません"
  #     }, status: :not_found
  #     return
  #   end

  #   latest_market_price_info = item.item_market_prices.order(recorded_at: :desc, created_at: :desc).first

  #   render json: {
  #     status: "success",
  #     data: {
  #       id: item.id,
  #       item_name: item.item_name,
  #       model_number: item.model_number,
  #       image_url: item.image_url,
  #       regular_price: item.regular_price,
  #       release_date: item.release_date,
  #       mercari_url: item.mercari_url,
  #       market_price: latest_market_price_info&.market_price,
  #       market_price_recorded_at: latest_market_price_info&.recorded_at
  #     }
  #   }, status: :ok
  # end

  def index
    @items = Item.all
    render json: {
      status: 'success',
      data: @items
    }
  end

  def show
    render json: {
      status: 'success',
      data: @item
    }
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      render json: {
        status: 'success',
        message: '商品が正常に作成されました',
        data: @item
      }, status: :created
    else
      render json: {
        status: 'error',
        message: '商品の作成に失敗しました',
        errors: @item.errors
      }, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      render json: {
        status: 'success',
        message: '商品が正常に更新されました',
        data: @item
      }
    else
      render json: {
        status: 'error',
        message: '商品の更新に失敗しました',
        errors: @item.errors
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    render json: {
      status: 'success',
      message: '商品が正常に削除されました'
    }
  end

  private

  def set_item
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: '商品が見つかりません'
    }, status: :not_found
    return
  end

  def item_params
    params.require(:item).permit(
      :item_name,
      :model_number,
      :regular_price,
      :release_date,
      :merkari_image_url,
      :merkari_url,
      :image_url
    )
  end

end