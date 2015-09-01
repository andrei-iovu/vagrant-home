#!/usr/bin/env bash

echo
echo "###########################################################"
echo
echo ">>> Installing Memcached"

# Install Memcached
# -qq implies -y --force-yes
sudo apt-get install -qq memcached

# Create Memcached daemons
echo "-m 64 -p 11211 -u memcache -c 2048 -d" > /etc/memcached_default.conf

sudo /etc/init.d/memcached restart

# Check if all daemons are up & running
sudo netstat -tap | grep memcached

echo