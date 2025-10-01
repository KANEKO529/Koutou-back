class Api::V1::Public::RisingItemsController < ApplicationController
    #   protect_from_forgery with: :null_session

  # GET /api/v1/public/rising-items
  def index
    @rising_items = RisingInformation.displayed

    # キーワード検索（includesの前に適用）
    if params[:keyword].present?
      @rising_items = @rising_items.search_by_keyword(params[:keyword])
    end
    
    # includesは最後に適用
    # @rising_items = @rising_items.includes(:item)
    # puts "#{@rising_items.includes(:item)}"
    @rising_items = @rising_items.includes(:item).order('rising_informations.id DESC')

    
    render json: {
      status: 'success',
      data: @rising_items.map { |rising| rising_item_data(rising) }
    }
  rescue StandardError => e
    render json: {
      status: 'error',
      message: "データの取得に失敗しました: #{e.message}"
    }, status: :internal_server_error
  end

  # GET /api/v1/public/rising-items/:id
  def show
    @rising_information = RisingInformation.includes(:item).find(params[:id])
    
    render json: {
      status: 'success',
      data: rising_item_data(@rising_information)
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: '高騰商品情報が見つかりません'
    }, status: :not_found
  end

  private

  # ここでレスポンスデータの中身を変更
  def rising_item_data(rising)
    item = rising.item
    
    {
      # 高騰情報
      rising_id: rising.id,
      market_price: rising.market_price,
      appreciation_rate: rising.appreciation_rate,
      description: rising.description,
      is_displayed: rising.is_displayed,
      
      # 商品情報
      item_id: item.id,
      item_name: item.item_name,
      model_number: item.model_number,
      regular_price: item.regular_price,
      release_date: item.release_date,
      merkari_url: item.merkari_url,
      merkari_image_url: item.merkari_image_url,
      image_url: item.image_url,
      
      # 計算された値
      price_difference: rising.price_difference,
      calculated_appreciation_rate: rising.calculated_appreciation_rate,
      
      # タイムスタンプ
      rising_created_at: rising.created_at,
      rising_updated_at: rising.updated_at,
      item_created_at: item.created_at,
      item_updated_at: item.updated_at
    }
  end
end
