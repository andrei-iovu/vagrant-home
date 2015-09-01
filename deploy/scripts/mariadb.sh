#!/usr/bin/env bash

MARIADB_VERSION=$1
if [[ -z $MARIADB_VERSION || ! $MARIADB_VERSION =~ ^10\.0$ ]]; then
    MARIADB_VERSION="10.0"
fi

MARIADB_PASSWORD=$2
if [[ -z $MARIADB_PASSWORD ]]; then
    MARIADB_PASSWORD="root"
fi

MARIADB_ENABLE_REMOTE=$3
if [[ -z $MARIADB_ENABLE_REMOTE || ! MARIADB_ENABLE_REMOTE =~ true ]]; then
    MARIADB_ENABLE_REMOTE=false
fi

echo
echo "###########################################################"
echo
echo ">>> Installing MariaDB $MARIADB_VERSION"

# Import repo key
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

# Add repo for MariaDB
sudo add-apt-repository -y "deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main"

# Update
sudo apt-get update

# Install MariaDB without password prompt
# Set username to 'root' and password to $MARIADB_PASSWORD
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $MARIADB_PASSWORD"
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $MARIADB_PASSWORD"

# Install MariaDB
# -qq implies -y --force-yes
sudo apt-get install -qq mariadb-server

# Make Maria connectable from outside world without SSH tunnel
if [[ $MARIADB_ENABLE_REMOTE =~ true ]]; then
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    MYSQL=`which mysql`

    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$MARIADB_PASSWORD' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -uroot -p$MARIADB_PASSWORD -e "$SQL"

    service mysql restart
fi

# Check if it is up & running
mysqld --version

echo