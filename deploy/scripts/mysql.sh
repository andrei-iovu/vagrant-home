#!/usr/bin/env bash

MYSQL_VERSION=$1
if [[ -z $MYSQL_VERSION || ! $MYSQL_VERSION =~ ^5\.[5|6]$ ]]; then
    MYSQL_VERSION="5.5"
fi

MYSQL_PASSWORD=$2
if [[ -z $MYSQL_PASSWORD ]]; then
    MYSQL_PASSWORD="root"
fi

MYSQL_ENABLE_REMOTE=$3
if [[ -z $MYSQL_ENABLE_REMOTE || ! $MYSQL_ENABLE_REMOTE =~ true ]]; then
    MYSQL_ENABLE_REMOTE=false
fi

echo
echo "###########################################################"
echo
echo ">>> Installing MySQL Server $MYSQL_VERSION"

mysql_package=mysql-server

if [[ $MYSQL_VERSION == "5.6" ]]; then
    # Add repo for MySQL 5.6
    sudo add-apt-repository -y ppa:ondrej/mysql-5.6

    # Update Again
    sudo apt-get update

    # Change package
    mysql_package=mysql-server-5.6
fi

# Install MySQL without password prompt
# Set username to 'root' and password to $MYSQL_PASSWORD
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"

# Install MySQL Server
# -qq implies -y --force-yes
sudo apt-get install -qq $mysql_package

# Make MySQL connectable from outside world without SSH tunnel
if [[ $MYSQL_ENABLE_REMOTE =~ true ]]; then
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    MYSQL=`which mysql`

    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -uroot -p$MYSQL_PASSWORD -e "$SQL"

    service mysql restart
fi

# Check if it is up & running
mysqld --version

echo
