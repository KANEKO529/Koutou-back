# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
# use HeaderSanitizer   # ← これで確実に入る
Rails.application.load_server
