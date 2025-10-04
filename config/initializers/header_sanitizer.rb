# 最後にレスポンスを検品するため、一番先頭に置く（= 返却時に最後に実行）
class HeaderSanitizer
    def initialize(app) = @app = app
  
    def call(env)
      status, headers, body = @app.call(env)
  
      req_id = env['action_dispatch.request_id'] || env['HTTP_X_REQUEST_ID']
      fixes = []
  
      headers.each do |k, v|
        key = k.is_a?(String) ? k : k.to_s
  
        if key.casecmp('Set-Cookie').zero?
          # Set-Cookie が Array のままだと Unicorn が死ぬので、\n で 1 文字列に
          if v.is_a?(Array)
            Rails.logger.error "Header array detected: Set-Cookie(count=#{v.size}) — join(\\n) req_id=#{req_id}"
            fixes << [k, key, v.map(&:to_s).join("\n")]
          elsif !v.is_a?(String)
            Rails.logger.error "Header non-string: Set-Cookie=#{v.inspect}(#{v.class}) — to_s req_id=#{req_id}"
            fixes << [k, key, v.to_s]
          end
          next
        end
  
        if v.is_a?(Array)
          Rails.logger.error "Header array detected: #{key}=#{v.inspect} — join(', ') req_id=#{req_id}"
          fixes << [k, key, v.join(', ')]
        elsif !v.is_a?(String)
          Rails.logger.error "Header non-string: #{key}=#{v.inspect}(#{v.class}) — to_s req_id=#{req_id}"
          fixes << [k, key, v.to_s]
        end
      end
  
      fixes.each do |old_key, new_key, new_val|
        headers.delete(old_key) unless old_key == new_key
        headers[new_key] = new_val
      end
  
      [status, headers, body]
    end
  end
  
  # ✅ 二重登録しない。ここだけ残す
  Rails.logger.info "[HeaderSanitizer] loaded"
  Rails.application.config.middleware.insert_before 0, HeaderSanitizer
  