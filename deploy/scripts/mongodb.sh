#!/usr/bin/env bash

MONGO_ENABLE_REMOTE=$1
if [[ -z $MONGO_ENABLE_REMOTE || ! $MONGO_ENABLE_REMOTE =~ true ]]; then
    MONGO_ENABLE_REMOTE=false
fi

MONGO_VERSION=$2
if [[ -z $MONGO_VERSION || ! $MONGO_VERSION =~ ^[23]{1}$ ]]; then
    MONGO_VERSION="2"
fi

echo
echo "###########################################################"
echo
echo ">>> Installing MongoDB $MONGO_VERSION"

# Get key and add to sources
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
if [[ $MONGO_VERSION == "3" ]]; then
    echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
else
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
fi

# Update
sudo apt-get update

# Install MongoDB
# -qq implies -y --force-yes
sudo apt-get install -qq mongodb-org

# Make MongoDB connectable from outside world without SSH tunnel
if [[ $MONGO_ENABLE_REMOTE =~ true ]]; then
    # enable remote access
    # setting the mongodb bind_ip to allow connections from everywhere
    sed -i "s/bind_ip = .*/bind_ip = 0.0.0.0/" /etc/mongod.conf
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]; then
    # install dependencies
    sudo apt-get -y install php-pear php5-dev

    # install php extencion
    echo "no" > answers.txt
    sudo pecl install mongo < answers.txt
    rm answers.txt

    # add extencion file and restart service
    echo 'extension=mongo.so' | sudo tee /etc/php5/mods-available/mongo.ini

    if [[ ! -L /etc/php5/fpm/conf.d/mongo.ini ]]; then
        ln -s /etc/php5/mods-available/mongo.ini /etc/php5/fpm/conf.d/mongo.ini
    fi
    if [[ ! -L /etc/php5/cli/conf.d/mongo.ini ]]; then
        ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/mongo.ini
    fi
    sudo service php5-fpm restart
fi

# Check if it is up & running
sudo netstat -tap | grep mongod

echo