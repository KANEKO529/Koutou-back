class Api::V1::Items::ItemsController < ApplicationController
    before_action :set_item, only: [:show, :update, :destroy]
  
    # GET /api/v1/items
    def index
      @items = Item.all
      render json: {
        status: 'success',
        data: @items
      }
    end
  
    # GET /api/v1/items/:id
    def show
      render json: {
        status: 'success',
        data: @item
      }
    end
  
    # POST /api/v1/items
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
  
    # PUT /api/v1/items/:id
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
  
    # DELETE /api/v1/items/:id
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
