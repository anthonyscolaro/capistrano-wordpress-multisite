#/bin/sh

APP=""
APP_DIR=/var/www/

echo "Create symlinks after svn checkout"
echo "=================================="
echo "link db-config.php"
      ln -nfs $APP_DIR/$APP/shared/wp-config.php $APP_DIR/$APP/public/wp-config.php
echo "link .htaccess"
      ln -nfs $APP_DIR/$APP/shared/.htaccess $APP_DIR/$APP/public/.htaccess
echo  "link sitemap.xml"
      ln -nfs $APP_DIR/$APP/shared/sitemap.xml $APP_DIR/$APP/public/sitemap.xml
echo "link robots"
      ln -nfs $APP_DIR/$APP/shared/robots.txt $APP_DIR/$APP/public/robots.txt
echo "link uploads"
      ln -nfs $APP_DIR/$APP/shared/uploads/ $APP_DIR/$APP/public/wp-content/uploads
echo "link blog.dir"
      ln -nfs $APP_DIR/$APP/shared/blogs.dir/ $APP_DIR/$APP/public/wp-content/blogs.dir
echo "link cache"
      ln -nfs $APP_DIR/$APP/shared/cache/ $APP_DIR/$APP/public/wp-content/themes/root/assets/cache
