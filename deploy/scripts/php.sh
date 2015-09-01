#!/usr/bin/env bash

PHP_TIMEZONE=$1
if [[ -z $PHP_TIMEZONE || $PHP_TIMEZONE =~ false ]]; then
    PHP_TIMEZONE=""
fi

PHP_VERSION=$2
if [[ -z $PHP_VERSION || ! $PHP_VERSION =~ ^5\.[5|6]$ ]]; then
    PHP_VERSION="5.5"
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]; then
    # Get the long version output
    PHP_INSTALLED_VERSION=`php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1`
    # Get the actual version as desired
    PHP_INSTALLED_VERSION=${PHP_INSTALLED_VERSION:15:3}

    if [[ $PHP_INSTALLED_VERSION == "5.6" || $PHP_VERSION == "5.5" ]]; then
        echo
        echo "###########################################################"
        echo
        echo ">>> Uninstalling PHP $PHP_INSTALLED_VERSION"
        sudo apt-get install -y ppa-purge
        sudo ppa-purge ppa:ondrej/php5-5.6
        sudo apt-get update && sudo apt-get -y upgrade
        sudo apt-get autoremove -y
        sudo apt-get autoclean
        PHP_VERSION="5.5"
        echo
    fi
fi


echo
echo "###########################################################"
echo
echo ">>> Installing PHP $PHP_VERSION"

if [[ $PHP_VERSION == "5.6" ]]; then
    sudo apt-get update && sudo apt-get install -y python-software-properties

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
    
    # Add repo for PHP 5.6
    sudo add-apt-repository -y ppa:ondrej/php5-5.6
    
    sudo apt-key update
    sudo apt-get update && sudo apt-get -y upgrade
fi

# Install PHP
# -qq implies -y --force-yes
sudo apt-get install -qq php5 php5-dev php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl php5-gd php5-gmp php5-mcrypt php5-memcache php5-memcached php5-imagick php5-intl php5-xdebug php5-json php-apc php-pear

# Make backups to the originals
if [[ ! -f /etc/php5/fpm/pool.d/www.conf.backup ]]; then
    cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf.backup
fi
if [[ ! -f /etc/php5/fpm/php.ini.backup ]]; then
    cp /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.backup
fi
if [[ ! -f /etc/php5/cli/php.ini.backup ]]; then
    cp /etc/php5/cli/php.ini /etc/php5/cli/php.ini.backup
fi

# Set PHP FPM to listen on TCP instead of Socket
sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php5/fpm/pool.d/www.conf

# Set PHP FPM allowed clients IP address
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php5/fpm/pool.d/www.conf

# Set run-as user for PHP5-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf

sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

# APC Config
cat > $(find /etc/php5 -name apcu.ini) << EOF
extension=apcu.so

apc.enabled = 1
apc.shm_size = 128M
apc.max_file_size = 1M
apc.mmap_file_mask = /dev/zero
apc.enable_cli = 1
EOF

# Xdebug Config
cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_handler="dbgp"
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=0
xdebug.show_exception_trace=0

; var_dump display
xdebug.var_display_max_depth=20
xdebug.var_display_max_children=256
xdebug.var_display_max_data=10240
EOF

# Fix mcrypt extension issue
php5enmod mcrypt

# PHP Language Options
sudo sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php5/fpm/php.ini
sudo sed -i "s/short_open_tag = .*/short_open_tag = Off/" /etc/php5/cli/php.ini

# PHP Resource Limits
sudo sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php5/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = -1/" /etc/php5/cli/php.ini

# PHP Data Handling
sudo sed -i "s/post_max_size = .*/post_max_size = 16M/" /etc/php5/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = 8M/" /etc/php5/cli/php.ini

# PHP Error Reporting Config
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_DEPRECATED/" /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sudo sed -i "s/html_errors = .*/html_errors = On/" /etc/php5/fpm/php.ini

# PHP File Uploads
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /etc/php5/fpm/php.ini

# PHP Date Timezone
if [[ $PHP_TIMEZONE == "" ]]; then
    sudo sed -i "s/.*date.timezone =.*/;date.timezone =/" /etc/php5/fpm/php.ini
    sudo sed -i "s/.*date.timezone =.*/;date.timezone =/" /etc/php5/cli/php.ini
else
    sudo sed -i "s/.*date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/fpm/php.ini
    sudo sed -i "s/.*date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/cli/php.ini
fi

# PHP Session
sudo sed -i "s/session.gc_maxlifetime = .*/session.gc_maxlifetime = 14400/" /etc/php5/fpm/php.ini
sudo sed -i "s/.*session.entropy_length = .*/session.entropy_length = 0/" /etc/php5/fpm/php.ini

sudo service php5-fpm restart

# Check if it is up & running
php -v

echo