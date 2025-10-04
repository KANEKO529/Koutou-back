# config/initializers/header_sanitizer.rb
class HeaderSanitizer
    def initialize(app) = @app = app
  
    def call(env)
      status, headers, body = @app.call(env)
  
      req_id = env['action_dispatch.request_id'] || env['HTTP_X_REQUEST_ID']
      fixes = []
  
      # 直接書き換えせずに収集
      headers.each do |k, v|
        # Set-Cookie は複数行（Array）を許容する
        next if k.to_s.casecmp('Set-Cookie').zero?
  
        new_key = k.is_a?(String) ? k : k.to_s
        new_val =
          if v.is_a?(Array)
            Rails.logger.error "Header array detected: #{new_key}=#{v.inspect} — coercing to string req_id=#{req_id}"
            v.join(', ')
          elsif v.is_a?(String)
            v
          else
            Rails.logger.error "Header non-string: #{new_key}=#{v.inspect} (#{v.class}) — coercing req_id=#{req_id}"
            v.to_s
          end
  
        # 変更が必要なら後で反映
        fixes << [k, new_key, new_val] if (!k.is_a?(String)) || (v != new_val)
      end
  
      # まとめて反映（キーの正規化も）
      fixes.each do |old_key, new_key, new_val|
        headers.delete(old_key) unless old_key == new_key
        headers[new_key] = new_val
      end
  
      [status, headers, body]
    end
  end
  
  # Rack::Cors や Session の“後ろ”に差す
  Rails.application.config.middleware.insert_after Rack::Cors, HeaderSanitizer
  # Rack::Cors の位置が不明なら最下流寄りに：
  # Rails.application.config.middleware.use HeaderSanitizer
  