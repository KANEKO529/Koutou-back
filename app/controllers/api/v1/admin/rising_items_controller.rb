class Api::V1::Admin::RisingItemsController < ApplicationController
#   protect_from_forgery with: :null_session
before_action :set_rising_information, only: [:show, :update, :destroy]  # この行を追加

    # GET /api/v1/admin/rising-items
    def index
      @rising_items = RisingInformation.displayed
                                      .by_appreciation_rate

      # キーワード検索（includesの前に適用）
      if params[:keyword].present?
        @rising_items = @rising_items.search_by_keyword(params[:keyword])
      end
      
      # includesは最後に適用
      @rising_items = @rising_items.includes(:item)
      
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

    # GET /api/v1/rising-items/:id
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

    # POST /api/v1/admin/rising-items
    def create

        # 1. 重複チェック（force_createがない場合のみ）
        unless params[:force_create] == true

            candidates = find_duplicate_candidates(item_params)
            
            if candidates.any?
                return render json: {
                    status: 'duplicates_found',
                    message: '類似する商品が見つかりました',
                    candidates: candidates.map { |item| candidate_data(item) },
                    original_data: {
                        item: item_params,
                        rising_information: rising_params
                    },
                    force_create_hint: 'force_create: true を追加して再送信すると強制作成できます'
                }, status: :conflict  # 409 Conflict
            end
        end

        # 重複チェック通過or強制実行
        ActiveRecord::Base.transaction do
            # 1. Itemの作成または取得

            @item = Item.new(item_params)

            # @item.saveが失敗した時のみ ActiveRecord::RecordInvalid例外を発生させる
            # (例: id=5)
            raise ActiveRecord::RecordInvalid.new(@item) unless @item.save
            
            # 2. RisingInformationの作成
            # bulidメソッドがItemレコードのidを外部キーとして自動設定し、レコード作成
            @rising_information = @item.rising_informations.build(rising_params)

            raise ActiveRecord::RecordInvalid.new(@rising_information) unless @rising_information.save
            
            render json: {
                status: 'success',
                message: '高騰商品情報が正常に作成されました',
                data: rising_item_data(@rising_information)
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

    # PUT /api/v1/admin/rising-items/:id
    def update
        ActiveRecord::Base.transaction do
        # 1. Itemの更新
        @item = @rising_information.item
        raise ActiveRecord::RecordInvalid.new(@item) unless @item.update(item_params)
        
        # 2. RisingInformationの更新
        raise ActiveRecord::RecordInvalid.new(@rising_information) unless @rising_information.update(rising_params)
        
        render json: {
            status: 'success',
            message: '高騰商品情報が正常に更新されました',
            data: rising_item_data(@rising_information)
        }
        end

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

    def destroy
        ActiveRecord::Base.transaction do
          @item = @rising_information.item
          
          # RisingInformationを削除
          @rising_information.destroy!
          
          # 関連するRisingInformationが他にない場合、Itemも削除
          if @item.rising_informations.empty?
            @item.destroy!
          end
          
          render json: {
            status: 'success',
            message: '高騰商品情報が正常に削除されました'
          }, status: :ok
        end
      
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

    def find_duplicate_candidates(params)
        candidates = []
        
        # 1. 型番での完全一致したら候補として返す
        if params[:model_number].present?
            exact_match = Item.where(model_number: params[:model_number])
            candidates.concat(exact_match.to_a)
        end
        
        # 2. 商品名の類似度チェック（ILIKE使用）
        if params[:item_name].present?
            keywords = extract_keywords(params[:item_name])
    
            case keywords.size
            when 0
              # キーワードなし → 何もしない
            when 1
              # 1語のみ → そのまま検索
              query = Item.where("item_name ILIKE ?", "%#{keywords[0]}%")
              query = query.where(release_date: params[:release_date]) if params[:release_date].present?
              candidates.concat(query.limit(5).to_a)
            else
              # 2語以上 → 2語の組み合わせで検索
              keywords.combination(2).each do |kw1, kw2|
                query = Item.where("item_name ILIKE ? AND item_name ILIKE ?", "%#{kw1}%", "%#{kw2}%")
                query = query.where(release_date: params[:release_date]) if params[:release_date].present?
                candidates.concat(query.limit(3).to_a)
              end
            end
        end
        # candidates内の重複を削除
        candidates.uniq
    end

    def candidate_data(item)
        {
          id: item.id,
          item_name: item.item_name,
          model_number: item.model_number,
          regular_price: item.regular_price,
          release_date: item.release_date,
        }
    end

    def set_rising_information
        @rising_information = RisingInformation.includes(:item).find(params[:id])
        rescue ActiveRecord::RecordNotFound
            render json: {
            status: 'error',
            message: '高騰商品情報が見つかりません'
            }, status: :not_found
    end

    def extract_keywords(item_name)
        return [] if item_name.blank?
        
        item_name.split(/[\s　・]/)  # 正規表現で半角スペース、全角スペース、中点で文字列を分割
                 .select { |word| word.length > 1 } #文字数が2字以上
                 .reject { |word| %w[カード ゲーム 限定 版 セット].include?(word) }
                 .first(3)  # 最大3キーワード
    end
      
    # def calculate_similarity_score(item)
    #     # 簡易的な類似度スコア（実際の用途に応じて調整）
    #     100
    # end

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
    
    def rising_params
        params.require(:rising_information).permit(
          :market_price,
          :description,
          :appreciation_rate,
          :is_displayed,
          :created_by_user_id
        )
    end
    
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
        created_by_user_id: rising.created_by_user_id,
        
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