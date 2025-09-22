Clerk.configure do |c|

  Rails.logger.info "=== Clerk Configuration ==="
  Rails.logger.info "CLERK_SECRET_KEY present: #{ENV['CLERK_SECRET_KEY']&.present?}"
  Rails.logger.info "CLERK_SECRET_KEY starts with: #{ENV['CLERK_SECRET_KEY']&.first(10)}..."
  Rails.logger.info "CLERK_PUBLISHABLE_KEY present: #{ENV['CLERK_PUBLISHABLE_KEY']&.present?}"
  Rails.logger.info "CLERK_PUBLISHABLE_KEY: #{ENV['CLERK_PUBLISHABLE_KEY']}"
  Rails.logger.info "==========================="


  c.secret_key = ENV["CLERK_SECRET_KEY"] # if omitted: ENV["CLERK_SECRET_KEY"] - API calls will fail if unset
  c.logger = Logger.new(STDOUT) # if omitted, no logging
end