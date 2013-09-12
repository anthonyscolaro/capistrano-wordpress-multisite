capistrano-wordpress-multisite
==============================

WordPress Multisite deployment

This is the first time I've used github for anything so let me know if I should have set something up differently...

I've been meaning to write up a generic version of a deployment recipe I've been adding onto for some time.  At the time of writing this, I'm using a variation of it for each of the three WordPress Multisites that I manage.

You can use this to:

1. Deploy Wordpress core files, themes and plugins to multiple environments (I'm using only production and staging)
2. Rsync shared data from production to staging or staging to local development
3. Pulldown mysql database from production to staging or staging to local development

I've set it up so that the local developer can only grab shared files and database from staging for security purposes.  This is because I'm not always developing from a static IP address and like to restrict access to the production sever.  The staging server is only used by developers with no public host.