# app/controllers/webhooks_controller.rb
class Api::V1::WebhooksController < ApplicationController
  
    def clerk
      puts "🔗 Webhook received from Clerk"
      
      begin
        # Webhookの署名検証
        payload = request.body.read
        sig_header = request.headers['svix-signature']
        
        unless verify_webhook_signature(payload, sig_header)
          puts "❌ Invalid webhook signature"
          render json: { error: 'Invalid signature' }, status: :unauthorized
          return
        end
  
        # イベントデータの解析
        event = JSON.parse(payload)
        puts "📨 Event type: #{event['type']}"
        puts "📋 Event data: #{event['data']}"
  
        case event['type']
        when 'user.created'
          handle_user_created(event['data'])
        when 'user.updated'
          handle_user_updated(event['data'])
        when 'user.deleted'
          handle_user_deleted(event['data'])
        else
          puts "⚠️ Unhandled event type: #{event['type']}"
        end
  
        render json: { message: 'Webhook processed successfully' }, status: :ok
      rescue => e
        puts "❌ Webhook processing failed: #{e.message}"
        puts "❌ Backtrace: #{e.backtrace.first(5)}"
        render json: { error: 'Webhook processing failed' }, status: :internal_server_error
      end
    end
  
    private
  
    def verify_webhook_signature(payload, sig_header)
      # Clerk Webhook秘密鍵での署名検証
      webhook_secret = ENV['CLERK_WEBHOOK_SIGNING_SECRET']
      
      unless webhook_secret
        puts "⚠️ CLERK_WEBHOOK_SECRET not set"
        return false
      end
  
      # Svixライブラリを使用した署名検証（推奨）
      require 'svix'
      
      wh = Svix::Webhook.new(webhook_secret)
      wh.verify(payload, {
        'svix-id' => request.headers['svix-id'],
        'svix-timestamp' => request.headers['svix-timestamp'],
        'svix-signature' => sig_header
      })
      
      true
    rescue => e
      puts "❌ Signature verification failed: #{e.message}"
      false
    end
  
    def handle_user_created(user_data)
      puts "👤 Creating new user from webhook..."
      
      user = User.create!(
        clerk_user_id: user_data['id'],
        email: extract_primary_email(user_data),
        user_name: extract_full_name(user_data),
        role: 'user'
      )
      
      puts "✅ User created: #{user.email}"
    rescue => e
      puts "❌ User creation failed: #{e.message}"
      raise e
    end
  
    def handle_user_updated(user_data)
      puts "📝 Updating user from webhook..."
      
      user = User.find_by(clerk_user_id: user_data['id'])
      
      if user
        user.update!(
          email: extract_primary_email(user_data),
          user_name: extract_full_name(user_data)
        )
        puts "✅ User updated: #{user.email}"
      else
        puts "⚠️ User not found for update: #{user_data['id']}"
      end
    rescue => e
      puts "❌ User update failed: #{e.message}"
      raise e
    end
  
    def handle_user_deleted(user_data)
      puts "🗑️ Deleting user from webhook..."
      
      user = User.find_by(clerk_user_id: user_data['id'])
      
      if user
        user.destroy!
        puts "✅ User deleted: #{user.email}"
      else
        puts "⚠️ User not found for deletion: #{user_data['id']}"
      end
    rescue => e
      puts "❌ User deletion failed: #{e.message}"
      raise e
    end
  
    def extract_primary_email(user_data)
      user_data['email_addresses']&.find { |email| email['id'] == user_data['primary_email_address_id'] }&.dig('email_address') ||
      user_data['email_addresses']&.first&.dig('email_address') ||
      "user_#{user_data['id']}@example.com"
    end
  
    def extract_full_name(user_data)
      first_name = user_data['first_name']
      last_name = user_data['last_name']
      
      if first_name && last_name
        "#{first_name} #{last_name}".strip
      elsif first_name
        first_name
      elsif last_name
        last_name
      else
        "User #{user_data['id'][0..7]}"
      end
    end
  end