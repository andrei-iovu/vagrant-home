#!/usr/bin/env bash

SYNCED_FOLDER="$1"
TOOLS_ROOT_PATH="$2"
CONF_ROOT_PATH="$3"

# Web interfaces to access and admin memcache
echo
echo "###########################################################"
echo
echo ">>> Installing PHP tools"

# Test if Nginx is installed
nginx -v > /dev/null 2>&1
NGINX_IS_INSTALLED=$?

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

# Make it accesible from web
if [[ $NGINX_IS_INSTALLED -eq 0 && $PHP_IS_INSTALLED -eq 0 ]]; then
    echo
    echo "###########################################################"
    echo
    echo ">>> Installing phpMemcachedAdmin and Memcache web apps"

    php_memcached_admin="phpMemcachedAdmin-1.2.2-r262.tar.gz"
    cd /tmp
    wget http://phpmemcacheadmin.googlecode.com/files/$php_memcached_admin

    mkdir -p /usr/share/nginx/html/phpmemcachedadmin
    tar -xvzf $php_memcached_admin -C /usr/share/nginx/html/phpmemcachedadmin/
    cp $SYNCED_FOLDER/$CONF_ROOT_PATH/phpmemcachedadmin/Memcache.php /usr/share/nginx/html/phpmemcachedadmin/Config/Memcache.php

    chmod 0777 /usr/share/nginx/html/phpmemcachedadmin/Config/Memcache.php
    chmod 0777 /usr/share/nginx/html/phpmemcachedadmin/Temp/

    rm -rf $php_memcached_admin

    # memcache
    cp $SYNCED_FOLDER/$TOOLS_ROOT_PATH/memcache.php /usr/share/nginx/html/

    echo
    echo "Access:"
    echo "   http://your_ip/phpmemcachedadmin | http://your_ip/memcache.php"
    echo "or, if you add 'your_ip vagrant' in your hosts file:"
    echo "   http://vagrant/phpmemcachedadmin | http://vagrant/memcache.php"
    echo

    echo
    echo "###########################################################"
    echo
    echo ">>> Installing phpinfo"
    cp $SYNCED_FOLDER/$TOOLS_ROOT_PATH/phpinfo.php /usr/share/nginx/html/

    echo
    echo "Access:"
    echo "   http://your_ip/phpinfo.php"
    echo "or, if you add 'your_ip vagrant' in your hosts file:"
    echo "   http://vagrant/phpinfo.php"
    echo

    echo
    echo "###########################################################"
    echo
    echo ">>> Installing apc"
    cp $SYNCED_FOLDER/$TOOLS_ROOT_PATH/apc.php /usr/share/nginx/html/

    echo
    echo "Access:"
    echo "   http://your_ip/apc.php"
    echo "or, if you add 'your_ip vagrant' in your hosts file:"
    echo "   http://vagrant/apc.php"
    echo

    echo
    echo "###########################################################"
    echo
    echo ">>> Installing opcache"
    cp $SYNCED_FOLDER/$TOOLS_ROOT_PATH/ocp.php /usr/share/nginx/html/

    echo
    echo "Access:"
    echo "   http://your_ip/ocp.php"
    echo "or, if you add 'your_ip vagrant' in your hosts file:"
    echo "   http://vagrant/ocp.php"
    echo
fi