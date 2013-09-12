server '', :app, :db, :web, :primary => true
set :repository,  "https://"
set :application, ""
set :deploy_to, "/var/www/#{application}/web/"
set :prod_shared, "/var/www/#{application}/shared/"
set :user, ""
set :port, 00


# STAGING ===============================================================================================
set :staging_service, ""
set :staging_shared, "/var/www/#{application}/shared/"


desc "Load production DB into Staging DB"
task :importdbstaging do
  
  filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql"
  dbuser = "" # Production
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

desc "Pulldown production shared data to staging server, exclude config and temporary files"
task :rsyncsharedstaging, :roles => :app do
  run <<-CMD
    rsync -avz --progress -e "ssh -p #{port}" --exclude 'gravity_forms*' --exclude 'mappress*' --exclude uploads/ --exclude cache/ --exclude log/ --exclude nginxcache/ --exclude system/ --exclude upgrade/ --exclude w3cache --exclude w3tc-config #{prod_shared} #{user}@#{staging_server}:#{staging_shared}
 CMD
end
