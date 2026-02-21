# #config/unicorn.rb

# #ワーカーの数
# $worker  = 1
# #何秒経過すればワーカーを削除するのかを決める
# $timeout = 30
# #自分のアプリケーション名、currentがつくことに注意。
# $app_dir = "/var/www/mywebapp/KotoApp/current"
# $shared_dir = "/var/www/mywebapp/KotoApp/shared"   # ← 追加
# #リクエストを受け取るポート番号を指定。後述
# $listen  = File.expand_path 'tmp/sockets/unicorn.sock', $shared_dir
# #PIDの管理ファイルディレクトリ
# $pid     = File.expand_path 'tmp/pids/unicorn.pid', $shared_dir
# #エラーログを吐き出すファイルのディレクトリ
# # $std_log = File.expand_path 'log/unicorn.log', $app_dir
# $stderr_path File.expand_path("log/unicorn.log", shared_dir)
# $stdout_path File.expand_path("log/unicorn.log", shared_dir)

# # 上記で設定したものが適応されるよう定義
# worker_processes  $worker
# working_directory $app_dir
# stderr_path $std_log
# stdout_path $std_log
# timeout $timeout
# listen  $listen
# pid $pid
# # ★ メモリ1GBでは preload_app は false
# preload_app false

# #fork前に行うことを定義
# before_fork do |server, worker|
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
#   old_pid = "#{server.config[:pid]}.oldbin"
#   if old_pid != server.pid
#     begin
#       Process.kill "QUIT", File.read(old_pid).to_i
#     rescue Errno::ENOENT, Errno::ESRCH
#     end
#   end
# end

# #fork後に行うことを定義
# after_fork do |server, worker|
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
# end
# config/unicorn.rb

# ワーカーの数
$worker  = 1

# 何秒経過すればワーカーを削除するのか
$timeout = 30

# 自分のアプリケーション名、current がつくことに注意
$app_dir    = "/var/www/App/kotoapp/backend/current"
$shared_dir = "/var/www/App/kotoapp/backend/shared"

# ソケット
$listen  = File.expand_path("tmp/sockets/unicorn.sock", $shared_dir)

# PID
$pid     = File.expand_path("tmp/pids/unicorn.pid", $shared_dir)

# ログ出力先
$std_log = File.expand_path("log/unicorn.log", $shared_dir)

# 上記で設定したものが適用されるよう定義
worker_processes  $worker
working_directory $app_dir

stderr_path $std_log
stdout_path $std_log

timeout $timeout
listen  $listen
pid     $pid

# ★ メモリ 1GB なので preload_app は false 推奨
preload_app false

# fork 前
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      Process.kill "QUIT", File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

# fork 後
after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
