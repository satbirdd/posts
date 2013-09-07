set :application, "neza"
set :repository,  "/home/robin/works/posts/"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, "root"
set :password, "porcorosso"
set :server_address, "192.168.2.122"
set :servers, [server_address]
set :deploy_to, "/var/www/#{ application }/"


set :rvm_path, "/usr/local/rvm"
set :rvm_bin_path, "/usr/local/rvm/bin"
set :rvm_ruby_string, 'ruby-1.9.3'


role :web, server_address                          # Your HTTP server, Apache/etc
role :app, server_address                          # This may be the same as your `Web` server
role :db,  server_address, :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :update_code, :roles => [:app, :db, :web] do
    on_rollback { delete release_path, :recursive => true }

    username = user || ENV['USER']
    servers.each do |server|
      `rsync -avz -e ssh "./" "#{username}@#{server}:#{release_path}" --exclude "_darcs" --exclude ".svn" --exclude "log"`
    end

    # run <<-CMD
    #   rm -rf #{release_path}/log &&
    #   rm -rf #{release_path}/public/system &&
    #   rm -rf #{release_path}/public/files &&
    #   ln -nfs #{shared_path}/log #{release_path}/log &&
    #   ln -nfs #{shared_path}/files #{release_path}/public/files &&
    #   ln -nfs #{shared_path}/system #{release_path}/public/system
    # CMD
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
    # run "killall nginx"
    run "/opt/nginx/sbin/nginx"
  end
end