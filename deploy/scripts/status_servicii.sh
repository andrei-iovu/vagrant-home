#!/bin/sh

echo
echo "###########################################################"
echo
echo ">>> Status final servicii"

echo
echo ">> PHP:"
echo
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]; then
    php -v
    sudo netstat -tap | grep php
else
    echo "PHP nu este instalat!"
fi
echo

echo
echo ">> NGINX:"
echo
nginx -v > /dev/null 2>&1
NGINX_IS_INSTALLED=$?
if [ $NGINX_IS_INSTALLED -eq 0 ]; then
    nginx -v
    sudo netstat -tap | grep nginx
else
    echo "NGINX nu este instalat!"
fi
echo

echo
echo ">> MYSQL / MARIADB (OPTIONAL):"
echo
mysqld --version > /dev/null 2>&1
MYSQL_IS_INSTALLED=$?
if [ $MYSQL_IS_INSTALLED -eq 0 ]; then
    mysqld --version
    sudo netstat -tap | grep mysql
else
    echo "MYSQL / MARIADB nu este instalat!"
fi
echo

echo
echo ">> MONGO (OPTIONAL):"
echo
mongod --version > /dev/null 2>&1
MONGO_IS_INSTALLED=$?
if [ $MONGO_IS_INSTALLED -eq 0 ]; then
    mongod --version
    sudo netstat -tap | grep mongo
else
    echo "MONGO nu este instalat!"
fi
echo

echo
echo ">> REDIS (OPTIONAL):"
echo
redis-cli -v > /dev/null 2>&1
REDIS_IS_INSTALLED=$?
if [ $REDIS_IS_INSTALLED -eq 0 ]; then
    redis-cli -v
    sudo netstat -tap | grep redis
else
    echo "REDIS nu este instalat!"
fi
echo

echo
echo ">> NODEJS (OPTIONAL):"
echo
node -v > /dev/null 2>&1
NODEJS_IS_INSTALLED=$?
if [ $NODEJS_IS_INSTALLED -eq 0 ]; then
    node -v
    sudo netstat -tap | grep node
else
    echo "NODEJS nu este instalat!"
fi
echo

echo
echo ">> MEMCACHE:"
echo
sudo netstat -tap | grep memcached > /dev/null 2>&1
MEMCACHE_IS_INSTALLED=$?
if [ $MEMCACHE_IS_INSTALLED -eq 0 ]; then
    sudo netstat -tap | grep memcached
else
    echo "Memcached nu este instalat!"
fi
echo

echo
echo ">> BEANSTALKD (OPTIONAL):"
echo
beanstalkd -v > /dev/null 2>&1
BEANSTALKD_IS_INSTALLED=$?
if [ $BEANSTALKD_IS_INSTALLED -eq 0 ]; then
    beanstalkd -v
	sudo netstat -tap | grep beanstalkd
else
    echo "Beanstalkd nu este instalat!"
fi
echo

echo
echo ">> COMPOSER:"
echo
composer -V > /dev/null 2>&1
COMPOSER_IS_INSTALLED=$?
if [ $COMPOSER_IS_INSTALLED -eq 0 ]; then
    composer -V
else
    echo "Composer nu este instalat!"
fi
echo

SYNCED_FOLDER="$1"
SCRIPTS_ROOT_PATH="$2"
if [[ -z $SYNCED_FOLDER || $SYNCED_FOLDER == "" || -z $SCRIPTS_ROOT_PATH || $SCRIPTS_ROOT_PATH == "" ]]; then
    exit
else
    echo
    echo "###########################################################"
    echo
    echo ">>> Copy of status_servicii.sh to $HOME"
    cp $SYNCED_FOLDER/$SCRIPTS_ROOT_PATH/status_servicii.sh $HOME/status_servicii.sh
    dos2unix $HOME/status_servicii.sh
fi