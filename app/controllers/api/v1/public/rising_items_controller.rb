class Api::V1::Public::RisingItemsController < ApplicationController
    #   protect_from_forgery with: :null_session

  # GET /api/v1/public/rising-items
  def index

    @rising_items = RisingInformation.displayed.includes(:item)

    # --- キーワード検索 ---
    if params[:keyword].present?
      @rising_items = @rising_items.search_by_keyword(params[:keyword])
    end

    # --- 絞り込み処理 ---
    # 発売日範囲
    if params[:from].present?
      @rising_items = @rising_items.joins(:item)
                                  .where("items.release_date >= ?", params[:from])
    end

    if params[:to].present?
      @rising_items = @rising_items.joins(:item)
                                  .where("items.release_date <= ?", params[:to])
    end

    # 中古価格帯
    if params[:price_min].present?
      @rising_items = @rising_items.where("rising_informations.market_price >= ?", params[:price_min].to_i)
    end

    if params[:price_max].present?
      @rising_items = @rising_items.where("rising_informations.market_price <= ?", params[:price_max].to_i)
    end

    # 高騰率範囲
    if params[:appreciation_min].present?
      @rising_items = @rising_items.where("rising_informations.appreciation_rate >= ?", params[:appreciation_min].to_f)
    end

    if params[:appreciation_max].present?
      @rising_items = @rising_items.where("rising_informations.appreciation_rate <= ?", params[:appreciation_max].to_f)
    end

    # 定価情報あり
    if params[:has_regular_price] == "true"
      @rising_items = @rising_items.joins(:item).where.not(items: { regular_price: [nil, 0] })
    end
    # 説明文あり
    if params[:has_description] == "true"
      @rising_items = @rising_items.where.not(description: [nil, ""])
    end

    # 型番あり
    if params[:has_model_number] == "true"
      @rising_items = @rising_items.joins(:item).where.not(items: { model_number: [nil, ""] })
    end
    
    # --- ソート設定 ---
    sort_column = params[:sort].presence_in(%w[
      appreciation_rate
      release_date
      regular_price
      market_price
    ]) || "id"
    
    sort_order = params[:order].to_s.downcase.presence_in(%w[asc desc]) || "desc"
    
    # --- 並び替え処理 ---
    @rising_items =
      case sort_column
      when "release_date", "regular_price"
        @rising_items.joins(:item)
                     .order(Arel.sql("items.#{sort_column} #{sort_order} NULLS LAST"))
      else
        @rising_items.order(Arel.sql("rising_informations.#{sort_column} #{sort_order} NULLS LAST"))
      end
    
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
