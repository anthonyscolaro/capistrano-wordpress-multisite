server '', :app, :db, :web, :primary => true
set :repository,  "https://"
set :application, ""
set :deploy_to, "/var/www/#{application}/web/"
set :user, ""
set :port, 00
set :use_sudo, false
default_run_options[:pty] = true

# Local Development ===============================================================================================
set :local_user, ""
set :local_host, ""
set :local_port, ""
set :local_shared, ""
set :staging_shared, ""

desc "Pull down Staging DB into Local Development DB"
task :importdbrj do
  
  filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql"
  dbuser = "" #Staging
  dbhost = "" 
  dbpassword = ""
  application_db = ""
  local_db_host = ""
  local_db_user = ""
  local_db_password = ""
  local_db = ""
  
  
  on_rollback do
    delete "/tmp/#{filename}"
    delete "/tmp/#{filename}.gz"
  end
  
  cmd = "mysqldump --opt --compress -u #{dbuser} --password=#{dbpassword} 
   --host=#{dbhost} #{application_db} > /tmp/#{filename}"
  puts "Dumping remote database"
  run(cmd) do |channel, stream, data|
    puts data
  end
  
  # compress the file on the server
  puts "Compressing remote data"
  run "gzip -9 /tmp/#{filename}"
  puts "Fetching remote data"
  get "/tmp/#{filename}.gz", "dump.sql.gz"
  
  # build the import command
  # no --password= needed if password is nil.
  if local_db_password.nil?
    cmd = "mysql -u#{local_db_user} #{local_db} < dump.sql"
  else
    cmd = "mysql -u#{local_db_user} -p#{local_db_password} #{local_db} < dump.sql"
  end
  
  # unzip the file. Can't use exec() for some reason so backticks will do
  puts "Uncompressing dump"
  `gzip -d dump.sql.gz`
  puts "Executing : #{cmd}"
  `#{cmd}`
  puts "Cleaning up"
  `rm -f dump.sql`
  
end

desc "Load production shared/ into local server"
task :rsyncsharedlocal, :roles => :app do
  run <<-CMD
    rsync -e "ssh -p #{local_port}" -avz --progress --exclude log/ --exclude wp-config.php --exclude shared/cache/ #{staging_shared} #{local_user}@#{local_host}:#{local_shared}
  CMD
end
