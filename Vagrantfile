$script = <<SCRIPT
yum install -y git ruby19* rubygems19*
alternatives --set ruby /usr/bin/ruby1.9

yum install -y autoconf automake libtool
yum install -y ImageMagick-devel mysql-devel postgresql-devel sqlite-devel
yum install -y postgresql postgresql-server

sudo service postgresql initdb
sudo service postgresql start

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'tree';"

sudo echo "" > /var/lib/pgsql9/data/pg_hba.conf
sudo echo "local   all             all                                     md5" >> /var/lib/pgsql9/data/pg_hba.conf
sudo echo "host    all             all             127.0.0.1/32            md5" >> /var/lib/pgsql9/data/pg_hba.conf
sudo echo "host    all             all             ::1/128                 md5" >> /var/lib/pgsql9/data/pg_hba.conf

sudo service postgresql restart

sudo gem update --system 1.8.30
gem install bundler
gem install ZenTest

cd /vagrant/
/usr/local/bin/bundle update
/usr/local/bin/bundle install
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box         = "mvbcoding/awslinux"
  config.ssh.insert_key = false
  config.vm.provision "shell", inline: $script

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end
end
