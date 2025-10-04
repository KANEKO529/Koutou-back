Rails.application.config.middleware.insert_before 0, Rack::Cors do
  frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")

  Rails.logger.info "=== CORS Configuration ==="
  Rails.logger.info "CORS_ORIGINS_FRONTEND: #{frontend_origin}"
  Rails.logger.info "Rails Environment: #{Rails.env}"
  Rails.logger.info "=========================="
  allow do
    origins frontend_origin

    # 認証系（Cookie/資格情報を送る）
    # resource "/api/v1/auth/*",
    #   headers: %w[authorization content-type],
    #   methods: %i[get post delete options head],
    #   expose:  %w[Authorization],
    #   credentials: true,
    #   max_age: 600

    debug: true, logger: -> { Rails.logger } do
      resource "/api/v1/auth/*",
        headers: %w[authorization content-type x-csrf-token],
        methods: %i[get post delete options head],
        credentials: true,
        max_age: 600
    end

    # 管理系（トークンだけで運用するなら credentials: false のままでOK）
    resource "/api/v1/admin/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 600

    # 公開系（将来カスタムヘッダを入れても落ちないよう options を許可）
    resource "/api/v1/public/*",
      headers: %w[authorization content-type],
      methods: %i[get options head],
      expose:  %w[Authorization],
      credentials: false,
      max_age: 600

    # その他API（必要なものを列挙／あるいは最後にまとめて /api/v1/* を用意）
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