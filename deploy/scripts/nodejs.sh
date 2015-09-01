#!/usr/bin/env bash

# Test if NodeJS is installed
node -v > /dev/null 2>&1
NODE_IS_INSTALLED=$?

# Contains all arguments that are passed
NODE_ARG=($@)

# Number of arguments that are given
NUMBER_OF_ARG=${#NODE_ARG[@]}

# Prepare the variables for installing specific Nodejs version and Global Node Packages
if [[ $NUMBER_OF_ARG -gt 3 ]]; then
    # Nodejs version, github url and Global Node Packages are given
    NODEJS_VERSION=${NODE_ARG[0]}
    SYNCED_FOLDER=${NODE_ARG[1]}
    HELPERS_ROOT_PATH=${NODE_ARG[2]}
    NODE_PACKAGES=${NODE_ARG[@]:3}
elif [[ $NUMBER_OF_ARG -eq 3 ]]; then
    # Only Nodejs version and github url are given
    NODEJS_VERSION=${NODE_ARG[0]}
    SYNCED_FOLDER=${NODE_ARG[1]}
    HELPERS_ROOT_PATH=${NODE_ARG[2]}
fi

if [[ -z $NODEJS_VERSION || ! $NODEJS_VERSION == "latest" ]]; then
    NODEJS_VERSION="latest"
fi

# True, if Node is not installed
if [[ $NODE_IS_INSTALLED -ne 0 ]]; then
    echo
    echo "###########################################################"
    echo
    echo ">>> Installing Node Version Manager"

    # Install NVM
    cp $SYNCED_FOLDER/$HELPERS_ROOT_PATH/nvm_install.sh /tmp/nvm_install.sh
    dos2unix /tmp/nvm_install.sh
    bash /tmp/nvm_install.sh
    rm -rf /tmp/nvm_install.sh

    # Re-source user profiles
    # if they exist
    if [[ -f "/home/vagrant/.profile" ]]; then
        . /home/vagrant/.profile
    fi

    echo
    echo "###########################################################"
    echo
    echo ">>> Installing Node.js version $NODEJS_VERSION"
    echo "    This will also be set as the default node version"

    # If set to latest, get the current node version from the home page
    if [[ $NODEJS_VERSION -eq "latest" ]]; then
        NODEJS_VERSION=`curl -L 'nodejs.org' | grep 'Current Version' | awk '{ print $4 }' | awk -F\< '{ print $1 }'`
    fi

    # Install Node
    nvm install $NODEJS_VERSION

    # Set a default node version and start using it
    nvm alias default $NODEJS_VERSION

    nvm use default

    echo
    echo "###########################################################"
    echo
    echo ">>> Starting to config Node.js"
    echo

    # Change where npm global packages are located
    npm config set prefix /home/vagrant/npm

    if [[ -f "/home/vagrant/.profile" ]]; then
        # Add new NPM Global Packages location to PATH (.profile)
        printf "\n# Add new NPM global packages location to PATH\n%s" 'export PATH=$PATH:~/npm/bin' >> /home/vagrant/.profile

        # Add new NPM root to NODE_PATH (.profile)
        printf "\n# Add the new NPM root to NODE_PATH\n%s" 'export NODE_PATH=$NODE_PATH:~/npm/lib/node_modules' >> /home/vagrant/.profile
    fi

fi

# Install (optional) Global Node Packages
if [[ ! -z $NODE_PACKAGES ]]; then
    echo
    echo "###########################################################"
    echo
    echo ">>> Start installing Global Node Packages"
    echo

    npm install -g ${NODE_PACKAGES[@]}
fi
