#!/usr/bin/env bash

echo
echo "###########################################################"
echo
echo ">>> Installing Beanstalkd"

# Install Beanstalkd
# -qq implies -y --force-yes
sudo apt-get install -qq beanstalkd

# Set to start on system start
sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd

sudo service beanstalkd restart

# Check if it is up & running
beanstalkd -v

echo