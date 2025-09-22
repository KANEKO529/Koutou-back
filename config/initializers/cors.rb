# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "*"

#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do

  frontend_origin = ENV.fetch("CORS_ORIGINS_FRONTEND", "http://localhost:3000")


  Rails.logger.info "=== CORS Configuration ==="
  Rails.logger.info "CORS_ORIGINS_FRONTEND: #{ENV.fetch("CORS_ORIGINS_FRONTEND")}"
  Rails.logger.info "CORS_ORIGINS_BACKEND: #{ENV.fetch("CORS_ORIGINS_API")}"
  
  Rails.logger.info "Rails Environment: #{Rails.env}"
  Rails.logger.info "=========================="


  allow do
    # origins "https://f25b-125-15-25-100.ngrok-free.app"#frontend
    origins frontend_origin
    
    resource '/api/*',
      headers: :any,
      # expose: ['Authorization', 'Content-Type'],
      expose: ['ngrok-skip-browser-warning'],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
      # credentials: true
  end
end
