# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.0"


plugins = [
    'vagrant-hostsupdater',
    'vagrant-env',
    'vagrant-vbguest',
]
plugins.each do |plugin|
    if !Vagrant.has_plugin?(plugin)
        system("vagrant plugin install #{plugin}")
    end
end

####################################################################################################
### Get Parameters from file

require "yaml"
require "erb"

# ruby does not do a 'deep' merge of hashes, so we need a helper
public
def deep_merge!(other_hash)
  merge!(other_hash) do |key, oldval, newval|
    oldval.class == self.class ? oldval.deep_merge!(newval) : newval
  end
end

# Load configuration from file
here = File.dirname(__FILE__)

# Get Production settings
_config = YAML.load(File.open(File.join(here, "deploy/vagrant_config.yaml"), File::RDONLY).read)

# Merge Production with Dev settings
# WARNING: All Dev blocks will overwrite the Production blocks
begin
    _config.deep_merge!(YAML.load(File.open(File.join(here, "deploy/vagrant_config_dev.yaml"), File::RDONLY).read))
rescue Errno::ENOENT # No vagrantconfig_local.yaml found -- that's OK; just use the defaults.
end

# Use this variable for accessing the settings
CONF = _config

### END Get Parameters from file
####################################################################################################



####################################################################################################
### Setting some defaults

## Database Configuration Defaults
CONF['mysql']['install'] = CONF['mysql']['install'] ||= false
CONF['mariadb']['install'] = CONF['mariadb']['install'] ||= false
# Only one server should be active
if CONF['mysql']['install'] != false and CONF['mariadb']['install'] != false
  CONF['mysql']['install'] = false
end

CONF['mongo']['install'] = CONF['mongo']['install'] ||= false


## In-Memory Stores Defaults
CONF['redis']['install'] = CONF['redis']['install'] ||= false


## Utility (queue)
CONF['beanstalkd']['install'] = CONF['beanstalkd']['install'] ||= true
CONF['rabbitmq']['install'] = CONF['rabbitmq']['install'] ||= true


## Additional Languages
# NodeJs needs to be treated differently for defaults
CONF['nodejs']['install'] = CONF['nodejs']['install'] ||= false
# Special care about the `packages` parameter that should be (converted to) an array
temp = Array.try_convert(CONF['nodejs']['packages'])
CONF['nodejs']['packages'] = temp ||= []


## Tools
CONF['composer']['install'] = CONF['composer']['install'] ||= true
# Special care about the `packages` parameter that should be (converted to) an array
temp = Array.try_convert(CONF['composer']['packages'])
CONF['composer']['packages'] = temp ||= []

### END Setting some defaults
####################################################################################################


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  #config.vm.box = "base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
    
  config.ssh.insert_key = CONF['box']['insert_key']
    
  config.vm.provider :virtualbox do |vb|
    ################################################################################################
    ### Don't touch the following settings!

    # Prevent VMs running on Ubuntu to lose internet connection
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    vb.customize ["setextradata", :id, "--VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance), then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    ### END Don't touch the following settings!
    ################################################################################################
  end
    
  # Instanta principala (default)
  config.vm.define "web", primary: true do |web|
    ################################################################################################
    ### Don't touch the following settings!
    web.vm.box = CONF['box']['type']
    web.vm.hostname = CONF['server_web']['hostname']

    web.vm.provider :virtualbox do |vb|
        vb.gui = CONF['box']['gui']
        vb.name = CONF['box_web']['name']
        vb.memory = CONF['server']['memory']
        vb.cpus = CONF['server']['cpus']
    end

    web.vm.network :public_network, ip: CONF['box_web']['ip']
    web.vm.synced_folder ".", CONF['box']['synced_folder'], :mount_options => ["dmode=777","fmode=766"]
      
    ### END Don't touch the following settings!
    ################################################################################################
      
      
    ################################################################################################
    ### Base Items

    # Provision Base Packages
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base.sh", args: ["#{CONF['server']['swap']}", "#{CONF['server']['timezone']}"]

    # optimize base box
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base_box_optimizations.sh", privileged: true

    # Provision PHP
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php.sh", args: ["#{CONF['php']['timezone']}", "#{CONF['php']['version']}"]

    ### END Base Items
    ################################################################################################


    ################################################################################################
    ### Web Servers

    # Provision Nginx Base
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/nginx.sh", args: [CONF['box']['synced_folder'], CONF['deploy_path']['helpers'], CONF['deploy_path']['conf']]

    ### END Web Servers
    ################################################################################################


    ################################################################################################
    ### Databases

    # Provision MongoDB
    if CONF['mongo']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/mongodb.sh", args: ["#{CONF['mongo']['enable_remote']}", "#{CONF['mongo']['version']}"]
    end

    ### END Databases
    ################################################################################################


    ################################################################################################
    ### In-Memory Stores

    # Provision Memcached
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/memcached.sh"

    # Provision Redis (without journaling and persistence)
    if CONF['redis']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/redis.sh", args: "#{CONF['redis']['persistent']}"
    end

    ### END In-Memory Stores
    ################################################################################################


    ################################################################################################
    ### Utility (queue)

    # Provision Beanstalkd
    if CONF['beanstalkd']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/beanstalkd.sh"
    end

    # Provision RabbitMQ
    if CONF['rabbitmq']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/rabbitmq.sh", args: ["#{CONF['rabbitmq']['user']}", "#{CONF['rabbitmq']['password']}"]
    end

    ### END Utility (queue)
    ################################################################################################


    ################################################################################################
    ### Additional Languages

    # Provision Nodejs
    if CONF['nodejs']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/nodejs.sh", privileged: false, args: CONF['nodejs']['packages'].unshift("#{CONF['nodejs']['version']}", CONF['box']['synced_folder'], CONF['deploy_path']['helpers'])
    end

    ### END Additional Languages
    ################################################################################################


    ################################################################################################
    ### Tools

    # Provision Composer
    if CONF['composer']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/composer.sh", privileged: false, args: CONF['composer']['packages'].join(" ")
    end

    # Provision PHP tools
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php_tools.sh", args: [CONF['box']['synced_folder'], CONF['deploy_path']['tools'], CONF['deploy_path']['conf']]

    ### END Tools
    ################################################################################################

    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/lossless_images.sh"    
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/vhosts.sh", args: [CONF['box']['synced_folder'], CONF['deploy_path']['vhosts']]
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/status_servicii.sh", privileged: false, args: [CONF['box']['synced_folder'], CONF['deploy_path']['scripts']]
  end

  ##################################################################################################


  # Instanta secundara (DB)
  config.vm.define "db", autostart: CONF['box_db']['autostart'] do |db|
    ################################################################################################
    ### Don't touch the following settings!
      
    db.vm.box = CONF['box']['type']
    db.vm.hostname = CONF['server_db']['hostname']

    db.vm.provider :virtualbox do |vb|
        vb.gui = CONF['box']['gui']
        vb.name = CONF['box_db']['name']
        vb.memory = CONF['server']['memory']
        vb.cpus = CONF['server']['cpus']
    end

    db.vm.network :public_network, ip: CONF['box_db']['ip']
    db.vm.synced_folder ".", CONF['box']['synced_folder'], :mount_options => ["dmode=777","fmode=766"]
      
    ### END Don't touch the following settings!
    ################################################################################################
      
      
    ################################################################################################
    ### Base Items

    # Provision Base Packages
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base.sh", args: ["#{CONF['server']['swap']}", "#{CONF['server']['timezone']}"]

    # optimize base box
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base_box_optimizations.sh", privileged: true
	
	# Provision PHP
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php.sh", args: ["#{CONF['php']['timezone']}", "#{CONF['php']['version']}"]

    ### END Base Items
    ################################################################################################


    ################################################################################################
    ### Web Servers

    # Provision Nginx Base
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/nginx.sh", args: [CONF['box']['synced_folder'], CONF['deploy_path']['helpers'], CONF['deploy_path']['conf']]

    ### END Web Servers
    ################################################################################################


    ################################################################################################
    ### Databases

    # Provision MySQL
    if CONF['mysql']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/mysql.sh", args: ["#{CONF['mysql']['version']}", "#{CONF['mysql_root']['password']}", "#{CONF['mysql']['enable_remote']}"]
    end

    # Provision MariaDB
    if CONF['mariadb']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/mariadb.sh", args: ["#{CONF['mariadb']['version']}", "#{CONF['mysql_root']['password']}", "#{CONF['mariadb']['enable_remote']}"]
    end

    ### END Databases
    ################################################################################################
	
	
	################################################################################################
    ### Tools

    # Provision PhpMyAdmin
    if CONF['mysql']['install'] == true || CONF['mariadb']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/phpmyadmin.sh", args: ["#{CONF['mysql_root']['password']}", CONF['box']['synced_folder'], CONF['deploy_path']['conf']]
    end

    # Provision PHP tools
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php_tools.sh", args: [CONF['box']['synced_folder'], CONF['deploy_path']['tools'], CONF['deploy_path']['conf']]

    ### END Tools
    ################################################################################################
	
	db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/status_servicii.sh", privileged: false, args: [CONF['box']['synced_folder'], CONF['deploy_path']['scripts']]
  end

end
