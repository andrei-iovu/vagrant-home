# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.0"

####################################################################################################
### Get Parameters from file

require "yaml"

# Get Production settings
_config = YAML.load(File.open(File.join(File.dirname(__FILE__), "deploy/vagrant_config.yaml"), File::RDONLY).read)

# Merge Production with Dev settings
# WARNING: All Dev blocks will overwrite the Production blocks
begin
    _config.merge!(YAML.load(File.open(File.join(File.dirname(__FILE__), "deploy/vagrant_config_dev.yaml"), File::RDONLY).read))
rescue Errno::ENOENT # No vagrantconfig_local.yaml found -- that's OK; just use the defaults.
end

# Use this variable for accessing the settings
CONF = _config

### END Get Parameters from file
####################################################################################################



####################################################################################################
### Setting some defaults

## Database Configuration Defaults
if CONF['mysql']['install'] != true and CONF['mysql']['install'] != false
  CONF['mysql']['install'] = false
end
if CONF['mariadb']['install'] != true and CONF['mariadb']['install'] != false
  CONF['mariadb']['install'] = false
end
# Only one server should be active
if CONF['mysql']['install'] != false and CONF['mariadb']['install'] != false
  CONF['mysql']['install'] = false
end

if CONF['mongo']['install'] != true and CONF['mongo']['install'] != false
  CONF['mongo']['install'] = false
end


## In-Memory Stores Defaults
if CONF['redis']['install'] != true and CONF['redis']['install'] != false
  CONF['redis']['install'] = false
end


## Utility (queue)
if CONF['beanstalkd']['install'] != true and CONF['beanstalkd']['install'] != false
  CONF['beanstalkd']['install'] = true
end
if CONF['rabbitmq']['install'] != true and CONF['rabbitmq']['install'] != false
  CONF['rabbitmq']['install'] = true
end


## Additional Languages
# NodeJs needs to be treated differently for defaults
if CONF['nodejs']['install'] != true and CONF['nodejs']['install'] != false
  CONF['nodejs']['install'] = false
end
# Special care about the `packages` parameter that should be (converted to) an array
unless defined? CONF['nodejs']['packages']
    CONF['nodejs']['packages'] = []
end
if CONF['nodejs']['packages'] = Array.try_convert(CONF['nodejs']['packages'])
    # We have array, nothing to do here
else
    CONF['nodejs']['packages'] = []
end


## Tools
if CONF['composer']['install'] != true and CONF['composer']['install'] != false
  CONF['composer']['install'] = true
end
# Special care about the `packages` parameter that should be (converted to) an array
unless defined? CONF['composer']['packages']
    CONF['composer']['packages'] = []
end
if CONF['composer']['packages'] = Array.try_convert(CONF['composer']['packages'])
    # We have array, nothing to do here
else
    CONF['composer']['packages'] = []
end

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
    web.vm.box = CONF['box_web']['type']
    web.vm.hostname = CONF['server_web']['hostname']

    web.vm.provider :virtualbox do |vb|
        vb.gui = CONF['box_web']['gui']
        vb.name = CONF['box_web']['name']
        vb.memory = CONF['server_web']['memory']
        vb.cpus = CONF['server_web']['cpus']
    end

    web.vm.network :public_network, ip: CONF['box_web']['ip']
    web.vm.synced_folder ".", CONF['box_web']['synced_folder'], :mount_options => ["dmode=777","fmode=766"]
      
    ### END Don't touch the following settings!
    ################################################################################################
      
      
    ################################################################################################
    ### Base Items

    # Provision Base Packages
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base.sh", args: ["#{CONF['server_web']['swap']}", "#{CONF['server_web']['timezone']}"]

    # optimize base box
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base_box_optimizations.sh", privileged: true

    # Provision PHP
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php.sh", args: ["#{CONF['php']['timezone']}", "#{CONF['php']['version']}"]

    ### END Base Items
    ################################################################################################


    ################################################################################################
    ### Web Servers

    # Provision Nginx Base
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/nginx.sh", args: [CONF['box_web']['synced_folder'], CONF['deploy_path']['helpers'], CONF['deploy_path']['conf']]

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

    # Provision PhpMyAdmin
    if CONF['mysql']['install'] == true || CONF['mariadb']['install'] == true
      web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/phpmyadmin.sh", args: ["#{CONF['db_generic']['password']}", CONF['box_web']['synced_folder'], CONF['deploy_path']['conf']]
    end

    # Provision PHP tools
    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php_tools.sh", args: [CONF['box_web']['synced_folder'], CONF['deploy_path']['tools'], CONF['deploy_path']['conf']]

    ### END Tools
    ################################################################################################

    web.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/status_servicii.sh", privileged: false, args: [CONF['box_web']['synced_folder'], CONF['deploy_path']['scripts']]
  end

  ##################################################################################################


  # Instanta secundara (DB)
  config.vm.define "db", autostart: CONF['box_db']['autostart'] do |db|
    ################################################################################################
    ### Don't touch the following settings!
      
    db.vm.box = CONF['box_db']['type']
    db.vm.hostname = CONF['server_db']['hostname']

    db.vm.provider :virtualbox do |vb|
        vb.gui = CONF['box_db']['gui']
        vb.name = CONF['box_db']['name']
        vb.memory = CONF['server_db']['memory']
        vb.cpus = CONF['server_db']['cpus']
    end

    db.vm.network :public_network, ip: CONF['box_db']['ip']
    db.vm.synced_folder ".", CONF['box_db']['synced_folder'], :mount_options => ["dmode=777","fmode=766"]
      
    ### END Don't touch the following settings!
    ################################################################################################
      
      
    ################################################################################################
    ### Base Items

    # Provision Base Packages
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base.sh", args: ["#{CONF['server_db']['swap']}", "#{CONF['server_db']['timezone']}"]

    # optimize base box
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base_box_optimizations.sh", privileged: true
	
	# Provision PHP
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php.sh", args: ["#{CONF['php']['timezone']}", "#{CONF['php']['version']}"]

    ### END Base Items
    ################################################################################################


    ################################################################################################
    ### Web Servers

    # Provision Nginx Base
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/nginx.sh", args: [CONF['box_db']['synced_folder'], CONF['deploy_path']['helpers'], CONF['deploy_path']['conf']]

    ### END Web Servers
    ################################################################################################


    ################################################################################################
    ### Databases

    # Provision MySQL
    if CONF['mysql']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/mysql.sh", args: ["#{CONF['mysql']['version']}", "#{CONF['mysql']['password']}", "#{CONF['mysql']['enable_remote']}"]
    end

    # Provision MariaDB
    if CONF['mariadb']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/mariadb.sh", args: ["#{CONF['mariadb']['version']}", "#{CONF['mariadb']['password']}", "#{CONF['mariadb']['enable_remote']}"]
    end

    ### END Databases
    ################################################################################################
	
	
	################################################################################################
    ### Tools

    # Provision Composer
    if CONF['composer']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/composer.sh", privileged: false, args: CONF['composer']['packages'].join(" ")
    end

    # Provision PhpMyAdmin
    if CONF['mysql']['install'] == true || CONF['mariadb']['install'] == true
      db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/phpmyadmin.sh", args: ["#{CONF['db_generic']['password']}", CONF['box_db']['synced_folder'], CONF['deploy_path']['conf']]
    end

    # Provision PHP tools
    db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php_tools.sh", args: [CONF['box_db']['synced_folder'], CONF['deploy_path']['tools'], CONF['deploy_path']['conf']]

    ### END Tools
    ################################################################################################
	
	db.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/status_servicii.sh", privileged: false, args: [CONF['box_db']['synced_folder'], CONF['deploy_path']['scripts']]
  end


  ##################################################################################################
   

  # Instanta secundara (static)
  config.vm.define "static", autostart: CONF['box_static']['autostart'] do |static|
    ################################################################################################
    ### Don't touch the following settings!
      
    static.vm.box = CONF['box_static']['type']
    static.vm.hostname = CONF['server_static']['hostname']

    static.vm.provider :virtualbox do |vb|
        vb.gui = CONF['box_static']['gui']
        vb.name = CONF['box_static']['name']
        vb.memory = CONF['server_static']['memory']
        vb.cpus = CONF['server_static']['cpus']
    end

    static.vm.network :public_network, ip: CONF['box_static']['ip']
    static.vm.synced_folder ".", CONF['box_static']['synced_folder'], :mount_options => ["dmode=777","fmode=766"]
      
    ### END Don't touch the following settings!
    ################################################################################################
      
      
    ################################################################################################
    ### Base Items

    # Provision Base Packages
    static.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base.sh", args: ["#{CONF['server_static']['swap']}", "#{CONF['server_static']['timezone']}"]

    # optimize base box
    static.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/base_box_optimizations.sh", privileged: true

    # Provision PHP
    static.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/php.sh", args: ["#{CONF['php']['timezone']}", "#{CONF['php']['version']}"]

    ### END Base Items
    ################################################################################################


    ################################################################################################
    ### Web Servers

    # Provision Nginx Base
    static.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/nginx.sh", args: [CONF['box_static']['synced_folder'], CONF['deploy_path']['helpers'], CONF['deploy_path']['conf']]

    ### END Web Servers
    ################################################################################################


    ################################################################################################
    ### Tools

    # Provision Composer
    if CONF['composer']['install'] == true
      static.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/composer.sh", privileged: false, args: CONF['composer']['packages'].join(" ")
    end

    ### END Tools
    ################################################################################################
	
	static.vm.provision "shell", path: "#{CONF['deploy_path']['scripts']}/status_servicii.sh", privileged: false, args: [CONF['box_static']['synced_folder'], CONF['deploy_path']['scripts']]
  end  
end
