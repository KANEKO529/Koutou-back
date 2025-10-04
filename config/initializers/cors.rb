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
# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")

#   Rails.logger.info "=== CORS Configuration ==="
#   Rails.logger.info "CORS_ORIGINS_FRONTEND: #{frontend_origin}"
#   Rails.logger.info "Rails Environment: #{Rails.env}"
#   Rails.logger.info "=========================="

#   allow do
#     origins frontend_origin
#     resource "/api/*",
#       headers: :any,                               # 必要なら %w[Authorization Content-Type]
#       methods: %i[get post put patch delete options head],
#       expose:  %w[Authorization],                  # フロントで読む必要があるヘッダだけ
#       credentials: true
#   end
# end
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")

  Rails.logger.info "=== CORS Configuration ==="
  Rails.logger.info "CORS_ORIGINS_FRONTEND: #{frontend_origin}"
  Rails.logger.info "Rails Environment: #{Rails.env}"
  Rails.logger.info "=========================="

  allow do
    # セッションを使う API（cookie 同送）
    resource "/api/v1/auth/*",
      headers: :any,
      methods: %i[get post delete options head],
      expose:  %w[Authorization],
      credentials: true,
      max_age: 7200

    # それ以外（cookie 不要）
    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 7200
  end
end