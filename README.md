capistrano-wordpress-multisite
==============================

WordPress Multisite Deployment

This is the first time I've used github for anything so let me know if I should have set something up differently...

I've been meaning to write up a generic version of a deployment recipe I've been adding onto for some time.  At the time of writing this, I'm using a variation of it for each of the three WordPress Multisites that I manage.

You can use this to:

1. Deploy Wordpress core files, themes and plugins to multiple environments (I'm using only production and staging)
2. Rsync shared data from production to staging or staging to local development
3. Pulldown the MySQL database from Production to Staging or from Staging to Local Development

I've set it up so that the local developer can only grab shared files and database from staging for security purposes.  This is because I'm not always developing from a static IP address and like to restrict access to the production sever.  The staging server is only used by developers with no public host.

deploy.rb
---------

The deploy.rb contains instructions for quite a few symlinks to be created.  This keeps certain plugin confurations and uploads out of the codebase. This was originally written for Apache but was later modified for NGINX and there is some evidence of Apache that needs to be better separated.

Replace your default deploy.rb file that is created after running 'capify .' with the deploy.rb located in my config file.  Edit the standard variables (application, stages, scm, user and group).  Read through each task as you may find that there are some extras that are applicable to your Multisite installation.

Once the symlinks are finished being created, we edit ownership and permissions before reloading NGINX.

production.rb
-------------

The recipe has 3 purposes, deploy to the production server, pulldown the database to the staging server or rsync shared data from production to staging.  

To deploy to production run
cap production deploy

To dump the production database, compress, sftp it to staging, decompress and import it into your staging database (whew), run
cap production importdbstaging

To rsync production shared data, excluding the wp-config.php and a couple other things, run 
cap production rsyncsharedstaging

staging.rb
----------

This recipe is almost exactly the same as production.rb except that instead of pushing data from production to staging, we are pushing it from staging to local development.

To deploy to staging run
cap staging deploy