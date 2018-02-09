$script = <<SCRIPT
yum install -y git ruby23* rubygems23*
alternatives --set ruby /usr/bin/ruby2.3 

yum install -y ImageMagick-devel mysql-devel postgresql-devel sqlite-devel
gem install bundler

cd /vagrant/
bundle update
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box         = "mvbcoding/awslinux"
  config.ssh.insert_key = false
  config.vm.provision "shell", inline: $script

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end
end
