class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def authenticate_request
    # セッションベースの軽量チェック
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      return if @current_user
    end

    # セッションがない場合は、AuthController#verifyのロジックを呼び出し
    perform_jwt_authentication
  end

  def perform_jwt_authentication
    auth_header = request.headers['Authorization']
    jwt_token = auth_header&.split(' ')&.last
    
    unless jwt_token
      render json: { error: 'Authorization token missing' }, status: :unauthorized
      return
    end

    begin
      decoded_token = verify_clerk_token(jwt_token)
      @current_user_clerk_id = decoded_token['sub']
      
      @current_user = User.find_by(clerk_user_id: @current_user_clerk_id)
      
      unless @current_user
        render json: { error: 'User not found' }, status: :not_found
        return
      end

      # セッションも作成（verifyと同じ処理）
      session[:user_id] = @current_user.id
      session[:role] = @current_user.role

      puts "✅ Create Rails session: #{session[:user_id]}, #{session[:role]}"
      
    rescue => e
      Rails.logger.error "Authentication failed: #{e.message}"
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def verify_clerk_token(token)
    sdk = Clerk::SDK.new
    sdk.verify_token(token)
  end

  def current_user
    @current_user
  end

  def current_user_clerk_id
    @current_user_clerk_id
  end
end