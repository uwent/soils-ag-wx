# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
branch = ENV['BRANCH'] || 'master'

set :application, 'soils_ag_wx'
set :repo_url, 'https://github.com/uwent/soils-ag-wx.git'

set :branch, branch

# set :deploy_to, '/var/www/my_app'
set :deploy_to, "/home/deploy/soils_ag_wx"
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

# rbenv
set :deploy_user, 'deploy'
set :rbenv_type, :user
set :rbenv_ruby, '2.7.2'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :publishing, :restart
  after :finishing, 'deploy:cleanup'

end
