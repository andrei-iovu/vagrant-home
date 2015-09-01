#!/usr/bin/env bash

TIMEZONE=$2
if [[ -z $TIMEZONE || $TIMEZONE =~ false ]]; then
    TIMEZONE="Europe/Bucharest"
fi

echo
echo "###########################################################"
echo
echo ">>> Installing Base Packages"


# Update
sudo apt-get update && sudo apt-get -y upgrade

### Install base packages ###

# -qq implies -y --force-yes
sudo apt-get install -qq curl unzip git git-core ack-grep software-properties-common build-essential byobu colordiff dstat htop imagemagick iotop mc multitail traceroute zip make dos2unix

# Install The SSH Server
sudo apt-get install -qq ssh openssh-server

# Synchronize the System Clock
sudo apt-get install -qq ntp ntpdate

### END Install base packages ###



### Setting up Swap ###

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $1 && ! $1 =~ false && $1 =~ ^[0-9]*$ ]]; then

    echo
    echo "###########################################################"
    echo
    echo ">>> Setting up Swap ($1 MB)"

    # Create the Swap file
    fallocate -l $1M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

    echo
fi

# Enable case sensitivity
shopt -u nocasematch

### END Setting up Swap ###

### Setting Timezone ###
echo
echo "###########################################################"
echo
echo ">>> Setting Timezone & Locale to $TIMEZONE"
echo $TIMEZONE > /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
echo
### END Setting Timezone ###