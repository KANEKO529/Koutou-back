# # lib/capistrano/tasks/unicorn.rb
# #unicornのpidファイル、設定ファイルのディレクトリを指定
# namespace :unicorn do
#     task :environment do
#       set :unicorn_pid,    "#{current_path}/tmp/pids/unicorn.pid"
#       set :unicorn_config, "#{current_path}/config/unicorn/production.rb"
#     end
  
#   #unicornをスタートさせるメソッド
#     def start_unicorn
#       within current_path do
#         execute :bundle, :exec, :unicorn, "-c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
#       end
#     end
  
#   #unicornを停止させるメソッド
#     def stop_unicorn
#       execute :kill, "-s QUIT $(< #{fetch(:unicorn_pid)})"
#     end
  
#   #unicornを再起動するメソッド
#     def reload_unicorn
#       execute :kill, "-s USR2 $(< #{fetch(:unicorn_pid)})"
#     end
  
#   #unicronを強制終了するメソッド
#     def force_stop_unicorn
#       execute :kill, "$(< #{fetch(:unicorn_pid)})"
#     end
  
#   #unicornをスタートさせるtask
#     desc "Start unicorn server"
#     task start: :environment do
#       on roles(:app) do
#         start_unicorn
#       end
#     end
  
#   #unicornを停止させるtask
#     desc "Stop unicorn server gracefully"
#     task stop: :environment do
#       on roles(:app) do
#         stop_unicorn
#       end
#     end
  
#   #既にunicornが起動している場合再起動を、まだの場合起動を行うtask
#     desc "Restart unicorn server gracefully"
#     task restart: :environment do
#       on roles(:app) do
#         if test("[ -f #{fetch(:unicorn_pid)} ]")
#           reload_unicorn
#         else
#           start_unicorn
#         end
#       end
#     end
  
#   #unicornを強制終了させるtask
#     desc "Stop unicorn server immediately"
#     task force_stop: :environment do
#       on roles(:app) do
#         force_stop_unicorn
#       end
#     end
#   end

# lib/capistrano/tasks/unicorn.rb
namespace :unicorn do
    task :environment do
      set :unicorn_pid,    "#{shared_path}/tmp/pids/unicorn.pid"
      set :unicorn_oldpid, "#{shared_path}/tmp/pids/unicorn.pid.oldbin"
      set :unicorn_config, "#{current_path}/config/unicorn.rb" # 例: config/unicorn.rb
    end
  
    task :prepare_dirs do
      on roles(:app) do
        execute :mkdir, "-p", "#{shared_path}/tmp/pids", "#{shared_path}/tmp/sockets", "#{shared_path}/log"
      end
    end
  
    def start_unicorn
      within current_path do
        execute :bundle, :exec, :unicorn,
                "-c", fetch(:unicorn_config),
                "-E", fetch(:rails_env),
                "-D"
      end
    end
  
    def stop_unicorn
      on roles(:app) do
        if test("[ -s #{fetch(:unicorn_pid)} ]")
          execute :kill, "-s", "QUIT", "`cat #{fetch(:unicorn_pid)}`"
        end
      end
    end
  
    # ゼロダウンタイム再起動: 新マスター起動(USR2) => 旧マスター終了(QUIT)
    def reload_unicorn
      on roles(:app) do
        if test("[ -s #{fetch(:unicorn_pid)} ]")
          execute :kill, "-s", "USR2", "`cat #{fetch(:unicorn_pid)}`"
          # 新マスターが立ち上がるまで少し待つ（環境に合わせて調整）
          sleep 2
          if test("[ -s #{fetch(:unicorn_oldpid)} ]")
            execute :kill, "-s", "QUIT", "`cat #{fetch(:unicorn_oldpid)}`"
          end
        else
          start_unicorn
        end
      end
    end
  
    def force_stop_unicorn
      on roles(:app) do
        if test("[ -s #{fetch(:unicorn_pid)} ]")
          execute :kill, "-s", "TERM", "`cat #{fetch(:unicorn_pid)}`"
        end
      end
    end
  
    desc "Start unicorn server"
    task start: [:environment, :prepare_dirs] do
      on roles(:app) { start_unicorn }
    end
  
    desc "Stop unicorn server gracefully"
    task stop: :environment do
      stop_unicorn
    end
  
    desc "Restart unicorn server (zero-downtime)"
    task restart: [:environment, :prepare_dirs] do
      reload_unicorn
    end
  
    desc "Stop unicorn server immediately"
    task force_stop: :environment do
      force_stop_unicorn
    end
  end
  
  # デプロイ後に再起動したい場合
  after "deploy:publishing", "unicorn:restart"
  