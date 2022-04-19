# config valid for current version and patch releases of Capistrano
lock '~> 3.17.0'

set :application, 'rsmile'
set :repo_url, 'git@github.com:DukeMobileTech/rsmile.git'
set :use_sudo, false
set :deploy_via, :copy
set :pty, false
set :format, :airbrussh
set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto
set :keep_releases, 5
set :linked_files, %w[config/database.yml config/master.key]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/packs .bundle node_modules]
set :linked_dirs, fetch(:linked_dirs) + %w[storage]
set :bundle_binstubs, nil
set :rvm_ruby_version, '3.0.2'
set :passenger_restart_with_touch, true

before 'deploy:assets:precompile', 'deploy:yarn_install'
namespace :deploy do
  desc 'Run rake yarn install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
