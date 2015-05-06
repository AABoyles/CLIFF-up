# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "6144"]
  end
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.provision "shell" do |s|
    s.path = "bootstrap.sh"
    s.privileged = false
  end
end

