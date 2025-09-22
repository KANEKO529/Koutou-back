# class User < ApplicationRecord
#     validates :clerk_user_id, presence: true, uniqueness: true
#     validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
#     validates :role, presence: true, inclusion: { in: %w[user admin moderator] }
#     validates :user_name, presence: true
    
#     # roleをenumで管理
#     enum role: { user: 'user', admin: 'admin', moderator: 'moderator' }
# end
# app/models/user.rb
class User < ApplicationRecord
    validates :clerk_user_id, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :user_name, presence: true
    
    # Rails 8での正しいenum定義
    enum :role, { user: 'user', admin: 'admin', moderator: 'moderator' }, default: 'user'
    
    # または数値ベースの場合（推奨）
    # enum :role, { user: 0, admin: 1, moderator: 2 }, default: :user
  end