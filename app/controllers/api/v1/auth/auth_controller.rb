# app/controllers/api/v1/auth_controller.rb
class Api::V1::Auth::AuthController < ApplicationController

    before_action :authenticate_request, only: [:me, :sign_out]
  
    def verify
        # 抽出
        auth_header = request.headers['Authorization']
        puts "Authorization Header: #{auth_header}"

        jwt_token = auth_header&.split(' ')&.last
        puts "Extracted Token: #{jwt_token ? jwt_token[0..20] + '...' : 'nil'}"

        unless jwt_token
            puts "❌ No token found"
            render json: { error: 'Authorization token missing' }, status: :unauthorized
            return
        end

        begin
            @decoded_token = verify_clerk_token(jwt_token)
            @current_user_clerk_id = @decoded_token['sub']
            puts "✅ Token verified. Clerk ID: #{@current_user_clerk_id}"
            
            # 既存ユーザーの検索のみ（作成はしない）
            @current_user = User.find_by(clerk_user_id: @current_user_clerk_id)
            
            unless @current_user
                puts "❌ User not found in database: #{@current_user_clerk_id}"
                render json: { 
                  error: 'User not found. Please complete signup process.',
                  clerk_user_id: @current_user_clerk_id 
                }, status: :not_found
                return
            end
            
            puts "✅ User found: #{@current_user.email}"
      
            # セッション作成（変数名を修正）
            session[:user_id] = @current_user.id
            session[:role] = @current_user.role
            puts "✅ Session created for user ID: #{@current_user.id}"
            
            render json: { 
              status: 'success', 
              user: {
                id: @current_user.id,
                email: @current_user.email,
                name: @current_user.user_name,
                role: @current_user.role
              }
            }
            
        rescue => e
            Rails.logger.error "JWT verification failed: #{e.message}"
            render json: { error: 'Invalid token' }, status: 401
        end
    end

    def me
        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.user_name,
            role: current_user.role
          }
        }
    end

    def sign_out
      puts "🔓 Sign out requested for user: #{current_user.email}" # ✅ メソッド使用
      
      session.delete(:user_id)
      session.delete(:role)
      reset_session
      
      puts "✅ Rails session cleared"
      
      render json: { 
        status: 'success',
        message: 'Successfully signed out' 
      }
    rescue => e
      Rails.logger.error "Sign out failed: #{e.message}"
      render json: { 
        error: 'Sign out failed' 
      }, status: :internal_server_error
    end

    private

    def verify_clerk_token(token)
        puts "Verifying token with Clerk SDK..."
        sdk = Clerk::SDK.new
        
        decoded_payload = sdk.verify_token(token)
        puts "✅ Token decoded successfully"
        
        decoded_payload
    rescue => e
        puts "❌ Clerk SDK error: #{e.class} - #{e.message}"
        raise e
    end
end