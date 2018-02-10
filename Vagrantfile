$script = <<SCRIPT
yum install -y git ruby19* rubygems19*
alternatives --set ruby /usr/bin/ruby1.9

yum install -y autoconf automake libtool
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
