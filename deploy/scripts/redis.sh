#!/usr/bin/env bash

echo
echo "###########################################################"
echo
echo ">>> Installing Redis"

# Add repository
sudo apt-add-repository ppa:rwky/redis -y

# Install Redis
# -qq implies -y --force-yes
sudo apt-get install -qq redis-server

# Redis Configuration
sudo mkdir -p /etc/redis/conf.d

# transaction journaling - config is written, only enabled if persistence is requested
cat << EOF | sudo tee /etc/redis/conf.d/journaling.conf
appendonly yes
appendfsync everysec
EOF

# Persistence
if [[ ! -z $1 && $1 == true ]]; then
    echo
    echo "###########################################################"
    echo
    echo ">>> Enabling Redis Persistence"

    # add the config to the redis config includes
    if ! cat /etc/redis/redis.conf | grep -q "journaling.conf"; then
        sudo echo "include /etc/redis/conf.d/journaling.conf" >> /etc/redis/redis.conf
    fi

    # schedule background append rewriting
    if ! crontab -l | grep -q "redis-cli bgrewriteaof"; then
        line="*/5 * * * * /usr/bin/redis-cli bgrewriteaof > /dev/null 2>&1"
        (sudo crontab -l; echo "$line" ) | sudo crontab -
    fi
fi # persistent

sudo service redis-server restart

# Check if it is up & running
redis-cli -v

echo