#!/usr/bin/env bash

DB_PASSWORD=$1
if [[ -z $DB_PASSWORD ]]; then
    DB_PASSWORD="root"
fi

SYNCED_FOLDER="$2"
CONF_ROOT_PATH="$3"

echo
echo "###########################################################"
echo
echo ">>> Installing PhpMyAdmin"

# Settings
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DB_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DB_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DB_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

# Install phpMyAdmin
# -qq implies -y --force-yes
sudo apt-get -qq install phpmyadmin

# Test if Nginx is installed
nginx -v > /dev/null 2>&1
NGINX_IS_INSTALLED=$?

# Make it accesible from web
if [[ $NGINX_IS_INSTALLED -eq 0 && ! -L /usr/share/nginx/html/phpmyadmin ]]; then
    ln -s /usr/share/phpmyadmin/ /usr/share/nginx/html/phpmyadmin
fi

# Replace the config file
cp $SYNCED_FOLDER/$CONF_ROOT_PATH/phpmyadmin/config.inc.php /usr/share/phpmyadmin/

echo
echo "Access:"
echo "   http://your_ip/phpmyadmin"
echo "or, if you add 'your_ip vagrant' in your hosts file:"
echo "   http://vagrant/phpmyadmin"
echo

echo