require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true

    # セッション機能を有効化（以下を追加）
    config.middleware.use ActionDispatch::Cookies

    config.middleware.use ActionDispatch::Session::CookieStore,
      key: '_backend_session',
      expire_after: 3.days,
      domain: '.kotojoho.com',  # ← サブドメイン共通
      secure: true,             # ← HTTPSのみ
      same_site: :none,         # ← クロスオリジンXHRでも送れる
      httponly: true            # ← JS から読ませない（推奨）
  end
end
