set :application, "projectassistant"
default_run_options[:pty] = true

set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :scm, :subversion
set :normalize_asset_timestamps, false

namespace(:symlink) do
  task :wpconfig, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/../../shared/system/wp-config.php #{release_path}/public/wp-config.php
    CMD
  end
#  task :htaccess, :roles => :app do
#    run <<-CMD
#      ln -nfs #{release_path}/../../shared/.htaccess #{release_path}/public/.htaccess
#    CMD
#  end
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
#after "symlink:wpconfig", "symlink:htaccess"
after "symlink:wpconfig", "symlink:uploads"
after "symlink:uploads", "symlink:blogsdir"
after "symlink:blogsdir", "symlink:timcache"
after "symlink:timcache", "symlink:w3cache"
after "symlink:w3cache", "symlink:w3config"
after "symlink:w3config", "symlink:nginxconfig"

namespace :nginx do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "/etc/init.d/nginx #{action.to_s}", :via => run_method
    end
  end
end

namespace :permissions do
  task :ownership, :roles => :app do
    run <<-CMD
      chown -R 04639-ssh:www-data /var/www/createmyid
    CMD
  end
  task :file, :roles => :app do
    run <<-CMD
      find /var/www/createmyid/web/ -type f -exec chmod 664 {} ';'
    CMD
  end
    task :directory, :roles => :app do
    run <<-CMD
      find /var/www/createmyid/web/ -type d -exec chmod 775 {} ';'
    CMD
  end
end

after "deploy:w3cache", "nginx:permissions"

# if you want to clean up old releases on each deploy uncomment this:

#after "deploy:restart", "deploy:cleanup"
#after "deploy:cleanup", "nginx:reload"
