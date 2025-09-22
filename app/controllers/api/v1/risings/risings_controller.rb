class Api::V1::Risings::RisingsController < ApplicationController
    before_action :set_rising_information, only: [:show, :update, :destroy, :toggle_display]
  
    # GET /api/v1/risings
    def index
      # @rising_informations = RisingInformation.includes(:item).all
      @rising_informations = RisingInformation.all

      render json: {
        status: 'success',
        data: @rising_informations.map do |rising|
          rising_data(rising)
        end
      }
    end
  
    # GET /api/v1/risings/:id
    def show
      render json: {
        status: 'success',
        data: rising_data(@rising_information)
      }
    end
  
    # POST /api/v1/risings
    def create
      @rising_information = RisingInformation.new(rising_params)
      
      if @rising_information.save
        render json: {
          status: 'success',
          message: '高騰情報が正常に作成されました',
          data: rising_data(@rising_information)
        }, status: :created
      else
        render json: {
          status: 'error',
          message: '高騰情報の作成に失敗しました',
          errors: @rising_information.errors,
          model_exists: defined?(RisingInformation),
          table_exists: RisingInformation.connection.table_exists?('rising_informations'),

        }, status: :unprocessable_entity
      end
    end

    # PUT /api/v1/risings/:id
    def update
      if @rising_information.update(rising_params)
        render json: {
          status: 'success',
          message: '高騰情報が正常に更新されました',
          data: rising_data(@rising_information)
        }
      else
        render json: {
          status: 'error',
          message: '高騰情報の更新に失敗しました',
          errors: @rising_information.errors
        }, status: :unprocessable_entity
      end
    end
  
    # DELETE /api/v1/risings/:id
    def destroy
      @rising_information.destroy
      render json: {
        status: 'success',
        message: '高騰情報が正常に削除されました'
      }
    end

    def toggle_display
      if @rising_information.update(is_displayed: !@rising_information.is_displayed)
        render json: {
          status: 'success',
          message: "高騰商品情報を#{@rising_information.is_displayed ? '表示' : '非表示'}にしました",
          data: rising_data(@rising_information)
        }
      else
        render json: {
          status: 'error',
          message: '表示状態の変更に失敗しました',
          errors: @rising_information.errors
        }, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_rising_information
      @rising_information = RisingInformation.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {
        status: 'error',
        message: '高騰情報が見つかりません'
      }, status: :not_found
    end
  
    def rising_params
      Rails.logger.debug "Received params: #{params.inspect}"

      params.require(:rising_information).permit(
        :item_id,
        :market_price,
        :description,
        :appreciation_rate,
        :is_displayed,
        :created_by_user_id
      )
    end
  
    def rising_data(rising)
      {
        id: rising.id,
        item_id: rising.item_id,
        item_name: rising.item&.item_name,
        model_number: rising.item&.model_number,
        regular_price: rising.item&.regular_price,
        market_price: rising.market_price,
        description: rising.description,
        appreciation_rate: rising.appreciation_rate,
        is_displayed: rising.is_displayed,
        created_by_user_id: rising.created_by_user_id,
        created_at: rising.created_at,
        updated_at: rising.updated_at
      }
    end
  end
