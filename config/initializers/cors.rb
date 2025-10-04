# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors,
  debug: true,
  logger: -> { Rails.logger } do

  frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")
  # 複数許可したいときは:
  # frontend_origins = frontend_origin.split(/\s*,\s*/)
  # origins(*frontend_origins) を使う

  Rails.logger.info "=== CORS Configuration ==="
  Rails.logger.info "CORS_ORIGINS_FRONTEND: #{frontend_origin}"
  Rails.logger.info "Rails Environment: #{Rails.env}"
  Rails.logger.info "=========================="

  allow do
    origins frontend_origin

    # 認証系（Cookie/資格情報を送る）
    resource "/api/v1/auth/*",
      headers: %w[authorization content-type],
      methods: %i[get post delete options head],
      expose:  %w[Authorization],
      credentials: true,
      max_age: 600

    # 管理系
    resource "/api/v1/admin/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 600

    # 公開系
    resource "/api/v1/public/*",
      headers: %w[authorization content-type],
      methods: %i[get options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 600

    # その他
    resource "/api/v1/risings/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 600

    resource "/api/v1/items/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 600
  end
end
