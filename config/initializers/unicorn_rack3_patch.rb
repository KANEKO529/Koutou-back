# config/initializers/unicorn_rack3_patch.rb
# Rack 3 でヘッダ値(Array)を返すケースに対応するため、Unicorn のヘッダ書き出しをパッチ
if defined?(Unicorn)
    Rails.logger.info "[UnicornRack3Patch] applying to unicorn #{defined?(Unicorn::Const) ? Unicorn::Const::UNICORN_VERSION : '(unknown)'}"
  
    module Unicorn::HttpResponse
      STATUS_CODES = defined?(Rack::Utils::HTTP_STATUS_CODES) ?
                     Rack::Utils::HTTP_STATUS_CODES : {}
  
      def err_response(code, response_start_sent)
        "#{response_start_sent ? '' : 'HTTP/1.1 '}" \
          "#{code} #{STATUS_CODES[code]}\r\n\r\n"
      end
  
      # Rack 3: ヘッダ値が Array の場合は各行に展開
      # Rack 2: "\n" 区切りの複数値にも対応
      def http_response_write(socket, status, headers, body,
                              req = Unicorn::HttpRequest.new)
        hijack = nil
  
        if headers
          code  = status.to_i
          msg   = STATUS_CODES[code]
          start = req.response_start_sent ? ''.freeze : 'HTTP/1.1 '.freeze
          buf   = "#{start}#{msg ? "#{code} #{msg}" : status}\r\n" \
                  "Date: #{httpdate}\r\n" \
                  "Connection: close\r\n"
  
          headers.each do |key, value|
            case key
            when %r{\A(?:Date|Connection)\z}i
              next
            when 'rack.hijack'
              hijack = value
            else
              case value
              when Array         # ★ Rack 3 でここが来る
                value.each { |v| buf << "#{key}: #{v}\r\n" }
              when /\n/          # Rack 2 の複数行
                value.split(/\n+/).each { |v| buf << "#{key}: #{v}\r\n" }
              else
                buf << "#{key}: #{value}\r\n"
              end
            end
          end
  
          socket.write(buf << "\r\n".freeze)
        end
  
        if hijack
          req.hijacked!
          hijack.call(socket)
        else
          body.each { |chunk| socket.write(chunk) }
        end
      end
    end
  end
  