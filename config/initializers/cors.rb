Rails.application.config.middleware.insert_before 0, Rack::Cors do
  frontend_origin_koto =
    ENV.fetch("CORS_ORIGINS_FRONTEND_KOTO", "http://localhost:3010")

  frontend_origin_dschecker =
    ENV.fetch("CORS_ORIGINS_FRONTEND_DSCHECKER", "http://localhost:3000")

  Rails.logger.info "=== CORS Configuration ==="
  Rails.logger.info "CORS_ORIGINS_FRONTEND_KOTO: #{frontend_origin_koto}"
  Rails.logger.info "CORS_ORIGINS_FRONTEND_DSCHECKER: #{frontend_origin_dschecker}"
  Rails.logger.info "Rails Environment: #{Rails.env}"
  Rails.logger.info "=========================="

  allow do
    origins frontend_origin_koto, frontend_origin_dschecker

    resource "/api/v1/auth/*",
      headers: %w[authorization content-type],
      methods: %i[get post delete options head],
      expose: %w[Authorization],
      credentials: true,
      max_age: 600

    resource "/api/v1/admin/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      credentials: false,
      max_age: 600

    resource "/api/v1/public/*",
      headers: %w[authorization content-type],
      methods: %i[get options head],
      expose: %w[Authorization],
      credentials: false,
      max_age: 600

    resource "/api/v1/risings/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      credentials: false,
      max_age: 600

    resource "/api/v1/items/*",
      headers: %w[authorization content-type],
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      credentials: false,
      max_age: 600
  end
end