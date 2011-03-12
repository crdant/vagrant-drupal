project_name = "Drupal Site"
project = "site"

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "maverick64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port "http", 80, 6840

  # Enable and configure the puppet provisioner
  config.vm.provision :puppet do |puppet|
    # for debug, uncomment
    # puppet.options = "--verbose --debug"
    # for verbose, uncomment
    # puppet.options = "--verbose"
    puppet.module_path = "puppet/modules"
    puppet.manifests_path = "puppet/manifests"
  end

  # mount my project directory in someplace approximating where I'd unpack
  # the tarball/clone/checkout in production
  # config.vm.project_directory = "/var/www/#{project}"
  
  # adjust the VM configuration for easier operation and so that the name
  # makes sense in the Virtual Box GUI
  config.vm.customize do |vm|
    vm.memory_size = 1024
    vm.name = "#{project_name} Development Instance"
  end
  
  # set up the IP address for host-only networking, be sure to put this one
  # in your hosts file as well to match the hostname you select for your server
  # NB: the vagrant docs use 33.33.33.0/24 and says it's "reliable", but it's 
  # also a routable network and not one reserved for private networks.
  config.vm.network("172.27.33.4")
  
end
