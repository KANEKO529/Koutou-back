Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      
      # Webhook用（認証をスキップするためAPIの外に配置）
      post 'webhooks', to: 'webhooks#clerk'

      namespace :auth do
        get 'me', to: 'auth#me'
        post 'verify', to: 'auth#verify'
        delete 'sign_out', to: 'auth#sign_out'
      end

        # 管理者用API
      namespace :admin do
        get 'rising-items', to: 'rising_items#index' # GET /api/v1/admin/rising-items
        get 'rising-items/:id', to: 'rising_items#show' # GET /api/v1/admin/rising-items/:id
        post 'rising-items', to: 'rising_items#create'# POST /api/v1/admin/rising-items/:id    
        put 'rising-items/:id', to: 'rising_items#update'# PUT /api/v1/admin/rising-items/:id

        # キーワード検索
        # get 'rising-items?keyword=', to: 'rising_items#index' # GET /api/v1/admin/rising-items

        # resources :users, only: [:index, :update] # 優先度低git push -u origin feature/ブランチ名

        resources :announcements, only: [:index, :show, :create, :update, :destroy]
        put 'announcements/:id/toggle-publish', to: 'announcements#toggle_publish'       # PUT /api/v1/risings/:id

        resources :tags, only: [:index, :show, :create, :update, :destroy]

      end

      namespace :items do
        resources :items, only: [:index, :show, :create, :update, :destroy]
      end

      namespace :risings do

        resources :risings, only: [:index, :show, :create, :update, :destroy]
        put ':id/toggle-display', to: 'risings#toggle_display'       # PUT /api/v1/risings/:id
      end

      namespace :public do
        get 'rising-items', to: 'rising_items#index'  # GET /api/v1/public/risings-items
        get 'rising-items/:id', to: 'rising_items#show' # GET /api/v1/public/risings-items/:id

        resources :announcements, only: [:index, :show]

      end

    end
  end

  # APIのルート確認用（開発環境のみ）
  if Rails.env.development?
    get '/api', to: proc { |env| [200, {'Content-Type' => 'application/json'}, [{ message: 'Rails API is running', version: 'v1' }.to_json]] }
  end
end