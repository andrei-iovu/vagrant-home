#!/usr/bin/env bash

RABBITMQ_USER=$1
if [[ -z $RABBITMQ_USER ]]; then
    RABBITMQ_USER="user"
fi

RABBITMQ_PASSWORD=$2
if [[ -z $RABBITMQ_PASSWORD ]]; then
    RABBITMQ_PASSWORD="password"
fi

echo
echo "###########################################################"
echo
echo ">>> Installing RabbitMQ"

apt-get -y install erlang-nox
wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add rabbitmq-signing-key-public.asc
echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
apt-get update

# Install RabbitMQ
# -qq implies -y --force-yes
sudo apt-get install -qq rabbitmq-server

rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PASSWORD
rabbitmqctl set_permissions -p / $RABBITMQ_USER ".*" ".*" ".*"

echo