class Api::V1::Internal::ItemsController < ApplicationController
  before_action :verify_internal_api_key, only: [:search_by_model_number]

  def search_by_model_number
    model_number = params[:model_number].to_s.strip.upcase

    if model_number.blank?
      render json: {
        status: "error",
        message: "model_number is required"
      }, status: :bad_request
      return
    end

    # T6：Railsの商品検索開始
    t6_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    item = Item.find_by(model_number: model_number)

    if item.nil?
      t6_ms = elapsed_ms(t6_started_at)
    
      Rails.logger.info(
        "[OCR_MEASUREMENT] " \
        "model_number=#{model_number} " \
        "T6_ms=#{format('%.3f', t6_ms)} " \
        "status=item_not_found"
      )
    
      render json: {
        status: "error",
        message: "商品が見つかりません"
      }, status: :not_found
      return
    end

    latest_market_price_info = item.item_market_prices
                                   .order(recorded_at: :desc, created_at: :desc)
                                   .first
    # T6：商品情報・最新相場情報の取得完了
    t6_ms = elapsed_ms(t6_started_at)

    Rails.logger.info(
      "[OCR_MEASUREMENT] " \
      "model_number=#{model_number} " \
      "T6_ms=#{format('%.3f', t6_ms)} " \
      "status=success"
    )

    render json: {
      status: "success",
      data: {
        id: item.id,
        item_name: item.item_name,
        model_number: item.model_number,
        image_url: item.image_url,
        regular_price: item.regular_price,
        release_date: item.release_date,
        merkari_url: item.merkari_url,
        market_price: latest_market_price_info&.market_price,
        market_price_recorded_at: latest_market_price_info&.recorded_at
      }
    }, status: :ok
  end

  private

  def elapsed_ms(started_at)
    finished_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    (finished_at - started_at) * 1000
  end

  def verify_internal_api_key
    api_key = request.headers["X-Internal-API-Key"].to_s
    internal_api_key = ENV["INTERNAL_API_KEY"].to_s

    unless internal_api_key.present? && ActiveSupport::SecurityUtils.secure_compare(api_key, internal_api_key)
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end