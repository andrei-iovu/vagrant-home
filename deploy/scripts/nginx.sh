#!/usr/bin/env bash

SYNCED_FOLDER="$1"
HELPERS_ROOT_PATH="$2"
CONF_ROOT_PATH="$3"

echo
echo "###########################################################"
echo
echo ">>> Installing Nginx"

# Add repo for latest stable nginx
sudo add-apt-repository -y ppa:nginx/stable

# Update Again
sudo apt-get update

# Install Nginx
# -qq implies -y --force-yes
sudo apt-get install -qq nginx

# Make backups to the originals
if [[ ! -f /etc/nginx/nginx.conf.backup ]]; then
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
fi
if [[ ! -f /etc/nginx/default.backup ]]; then
    cp /etc/nginx/sites-available/default /etc/nginx/default.backup
fi

# Replace the original with a premade conf file based on Production
cp $SYNCED_FOLDER/$CONF_ROOT_PATH/nginx/nginx.conf /etc/nginx/nginx.conf
dos2unix /etc/nginx/nginx.conf

# Replace the default vhost
cp $SYNCED_FOLDER/$CONF_ROOT_PATH/nginx/default /etc/nginx/sites-available/default
dos2unix /etc/nginx/sites-available/default

# Template files for virtual hosts from backup
cp $SYNCED_FOLDER/$CONF_ROOT_PATH/nginx/snippets/* /etc/nginx/snippets
dos2unix /etc/nginx/snippets/*

# Update log rotation script
sed -i -e 's/weekly/daily/' /etc/logrotate.d/nginx

# Turn off sendfile to be more compatible with Windows, which can't use NFS
sed -i 's/sendfile on;/sendfile off;/' /etc/nginx/nginx.conf

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

# Add vagrant user to www-data group
usermod -a -G www-data vagrant

sed -i 's/keepalive_timeout .*/keepalive_timeout 900;/' /etc/nginx/nginx.conf
sed -i 's/keepalive_requests .*/keepalive_requests 900;/' /etc/nginx/nginx.conf

# Nginx enabling and disabling virtual hosts
echo
echo "###########################################################"
echo
echo ">>> Installing Nginx helpers: ngxen ngxdis"

sudo cp $SYNCED_FOLDER/$HELPERS_ROOT_PATH/ngxen.sh /tmp/ngxen
sudo cp $SYNCED_FOLDER/$HELPERS_ROOT_PATH/ngxdis.sh /tmp/ngxdis
cd /tmp
sudo dos2unix ngxen ngxdis
sudo chmod guo+x ngxen ngxdis
sudo mv ngxen ngxdis /usr/local/bin

sudo service nginx restart

# Check if it is up & running
nginx -v

echo