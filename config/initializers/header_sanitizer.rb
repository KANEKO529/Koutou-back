# config/initializers/header_sanitizer.rb
class HeaderSanitizer
    def initialize(app) = @app = app
  
    def call(env)
      status, headers, body = @app.call(env)
  
      req_id = env['action_dispatch.request_id'] || env['HTTP_X_REQUEST_ID']
      fixes = []
  
      headers.each do |k, v|
        # 1) キーを文字列化（キーが Array/Symbol でも必ず String に）
        key = k.is_a?(String) ? k : k.to_s
        if k != key
          Rails.logger.error "[HS] non-string header key: #{k.inspect}(#{k.class}) -> #{key.inspect} req_id=#{req_id}"
          # キーだけ差し替える（値は一旦そのまま）
          fixes << [:key_only, k, key, v]
        end
  
        # 2) 値の正規化
        new_val =
          if key.casecmp('Set-Cookie').zero?
            if v.is_a?(Array)
              Rails.logger.error "[HS] array Set-Cookie(count=#{v.size}) -> join(\\n) req_id=#{req_id}"
              v.map(&:to_s).join("\n")
            else
              v.is_a?(String) ? v : v.to_s
            end
          else
            if v.is_a?(Array)
              Rails.logger.error "[HS] array header value: #{key}=#{v.inspect} -> join(', ') req_id=#{req_id}"
              v.join(', ')
            else
              v.is_a?(String) ? v : v.to_s
            end
          end
  
        if new_val != v
          fixes << [:val, (k == key ? key : k), key, new_val]
        end
      end
  
      # 3) まとめて反映（キー変更→値変更の順）
      fixes.each do |kind, old_key, new_key, new_val|
        headers.delete(old_key) unless old_key == new_key
        headers[new_key] = new_val
      end
  
      # （任意の一時デバッグ）型サマリ
      # Rails.logger.debug { "[HS] final header types: " + headers.map { |kk,vv| "#{kk.class}/#{vv.class}" }.join(', ') + " req_id=#{req_id}" }
  
      [status, headers, body]
    end
  end
  
  Rails.logger.info "[HeaderSanitizer] loaded"
  # スタック先頭に1回だけ（=返却時に最後に必ず走る）
  Rails.application.config.middleware.insert_before 0, HeaderSanitizer
  