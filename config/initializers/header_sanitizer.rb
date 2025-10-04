# config/initializers/header_sanitizer.rb
class HeaderSanitizer
    def initialize(app) = @app = app
  
    def call(env)
      status, headers, body = @app.call(env)
  
      headers.each do |k, v|
        next if k == 'Set-Cookie' # ここだけは複数行扱いが特殊なのでスキップ
        if v.is_a?(Array)
          Rails.logger.error "Header array detected: #{k}=#{v.inspect} — coercing to string"
          headers[k] = v.join(', ')
        elsif !v.is_a?(String)
          Rails.logger.error "Header non-string: #{k}=#{v.inspect} (#{v.class}) — coercing"
          headers[k] = v.to_s
        end
      end
  
      [status, headers, body]
    end
  end
  
  Rails.application.config.middleware.insert_after Rack::Cors, HeaderSanitizer
  