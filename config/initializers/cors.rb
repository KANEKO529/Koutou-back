# Rails.application.config.middleware.insert_before 0, Rack::Cors do

#   frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")


#   Rails.logger.info "=== CORS Configuration ==="
#   Rails.logger.info "CORS_ORIGINS_FRONTEND: #{ENV.fetch("CORS_ORIGINS_FRONTEND")}"
#   Rails.logger.info "CORS_ORIGINS_BACKEND: #{ENV.fetch("CORS_ORIGINS_API")}"
  
#   Rails.logger.info "Rails Environment: #{Rails.env}"
#   Rails.logger.info "=========================="


#   allow do
#     # origins "https://f25b-125-15-25-100.ngrok-free.app"#frontend
#     origins frontend_origin
    
#     resource '/api/*',
#       headers: :any,
#       # expose: ['Authorization', 'Content-Type'],
#       expose: ['ngrok-skip-browser-warning'],
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#       # credentials: true
#   end
# end
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")

  # ログはフェッチ済みの値を使う（ENV.fetch 連発で例外を避ける）
  Rails.logger.info "=== CORS Configuration ==="
  Rails.logger.info "CORS_ORIGINS_FRONTEND: #{frontend_origin}"
  Rails.logger.info "CORS_ORIGINS_API: #{ENV['CORS_ORIGINS_API']}"  # 参照だけにする
  Rails.logger.info "Rails Environment: #{Rails.env}"
  Rails.logger.info "=========================="

  allow do
    origins frontend_origin

    resource "/api/*",
      # 本番は明示列挙か :any のどちらか。ngrok ヘッダは不要なので削除。
      headers: :any,  # もしくは %w[Authorization Content-Type X-Requested-With]
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      # クッキー/セッションを使うなら true（SameSite=None; Secure も忘れずに）
      credentials: false,
      # JS から読みたいレスポンスヘッダ（必要最小限）
      expose: %w[Authorization],
      max_age: 86400
  end
end
