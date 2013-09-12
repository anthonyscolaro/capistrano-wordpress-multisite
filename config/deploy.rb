set :application, ""
default_run_options[:pty] = true

set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :scm, :subversion
set :normalize_asset_timestamps, false

# for permissions tasks
set :user, ""
set :group, ""

namespace(:symlink) do
  task :wpconfig, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/system/wp-config.php #{release_path}/public/wp-config.php
    CMD
  end
  task :uploads, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/uploads #{release_path}/public/wp-content/uploads 
    CMD
  end
  task :blogsdir, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/blogs.dir #{release_path}/public/wp-content/blogs.dir 
    CMD
  end  
  task :timcache, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/cache #{release_path}/public/wp-content/themes/root/assets/cache
    CMD
  end   
  task :w3cache, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/w3cache #{release_path}/public/wp-content/cache
    CMD
  end
  task :w3config, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/w3tc-config #{release_path}/public/wp-content/w3tc-config
    CMD
  end
  task :nginxconfig, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/system/nginx.conf #{release_path}/public/nginx.conf
    CMD
  end
end

after "deploy:update_code", "symlink:wpconfig"
after "symlink:wpconfig", "symlink:uploads"
after "symlink:uploads", "symlink:blogsdir"
after "symlink:blogsdir", "symlink:timcache"
after "symlink:timcache", "symlink:w3cache"
after "symlink:w3cache", "symlink:w3config"
after "symlink:w3config", "symlink:nginxconfig"

namespace :permissions do
  task :ownership, :roles => :app do
    run <<-CMD
      chown -R #{user}:#{group} #{release_path}
    CMD
  end
  task :file, :roles => :app do
    run <<-CMD
      find #{release_path} -type f -exec chmod 664 {} ';'
    CMD
  end
    task :directory, :roles => :app do
    run <<-CMD
      find #{release_path} -type d -exec chmod 775 {} ';'
    CMD
  end
end

after "deploy:restart", "permissions:ownership"
after "permissions:ownership", "permissions:file"
after "permissions:file", "permissions:directory"

# if you want to restart/reload NGINX on each deploy

namespace :nginx do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} nginx"
    task action, :roles => :web do
      invoke_command "/etc/init.d/nginx #{action.to_s}", :via => run_method
    end
  end
end

after "deploy:restart", "nginx:reload"

# if you want to clean up old releases on each deploy uncomment this:
#after "deploy:restart", "deploy:cleanup"


# this was commented out after switching to nginx
#  task :htaccess, :roles => :app do
#    run <<-CMD
#      ln -nfs #{release_path}/../../shared/.htaccess #{release_path}/public/.htaccess
#    CMD
#  end
#after "symlink:wpconfig", "symlink:htaccess"
