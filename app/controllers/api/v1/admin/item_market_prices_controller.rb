class Api::V1::Admin::ItemMarketPricesController < ApplicationController
    # 相場一覧
    def index
        market_prices = ItemMarketPrice.all
        render json: market_prices
    end

    # 特定商品の相場
    def show
        market_price = ItemMarketPrice.find(params[:id])
        render json: market_price
    end

    # 相場登録
    def create
        market_price = ItemMarketPrice.new(item_market_price_params)

        if market_price.save
            render json: market_price, status: :created
        else
            render json: { errors: market_price.errors }, status: :unprocessable_entity
        end
    end

    # 相場更新
    def update
        market_price = ItemMarketPrice.find(params[:id])

        if market_price.update(item_market_price_params)
            render json: market_price
        else
            render json: { errors: market_price.errors }, status: :unprocessable_entity
        end
    end

    # 削除
    def destroy
        market_price = ItemMarketPrice.find(params[:id])
        market_price.destroy
        head :no_content
    end

    private

    def item_market_price_params
    params.require(:item_market_price).permit(
        :item_id,
        :market_price,
        :recorded_at,
        :memo
    )
    end
end
