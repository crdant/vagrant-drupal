project_name = "Drupal Foundation"
project = "foundation"

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "maverick64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://flyingmist.net-vagrant-boxes.s3.amazonaws.com/maverick64.box"

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
  
end
