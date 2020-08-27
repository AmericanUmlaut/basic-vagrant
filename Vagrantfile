# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://app.vagrantup.com/boxes/search.
  config.vm.box = "ubuntu/bionic64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.1"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./typo3", "/var/www/typo3", :owner => "www-data", :group => "www-data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 4
  end

  # Set the machine's hostname on boot
  config.vm.hostname="ENO-SITE"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    # Source our bash profile to give us access to functions that are defined there
    source /vagrant/sysfiles/home/vagrant/.bash_profile

    # Our code requires PHP >=7.2<=7.4, so we install 7.4 using a custom repository.
    # Ubuntu's repositories don't make anything newer than 7.0 available.
    install_package software-properties-common
    add-apt-repository -y ppa:ondrej/php
    apt-get update
    install_package php7.4
    install_package php7.4-curl
    install_package php7.4-dev
    install_package php7.4-gd
    install_package php7.4-imap
    install_package php7.4-intl
    install_package php7.4-mbstring
    install_package php7.4-mysqli
    install_package php7.4-soap
    install_package php7.4-xdebug
    install_package php7.4-xml
    install_package php7.4-zip
    install_package mysql-server
    install_package unzip # Makes Composer happy, otherwise it has to use PHP to decompress downloaded files
    install_package install_package imagemagick # Required by the TYPO3 introduction package

    echo "Installing Composer..."
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
    echo "Done installing Composer..."

    echo "Installing Composer dependencies..."
        cd /vagrant/typo3; su vagrant -c "composer install";
    echo "Done installing Composer dependencies"

    echo "Enabling required Apache modules..."
        a2enmod expires
        a2enmod headers
        a2enmod rewrite
    echo "Done enabling required Apache modules"

    # The set of privileges required by the TYPO3 db user is documented at
    # https://docs.typo3.org/m/typo3/guide-installation/10.4/en-us/In-depth/SystemRequirements/Index.html#required-database-privileges
    echo "Configuring typo3 database user"
        mysql -e "CREATE USER 'typo3'@'localhost' IDENTIFIED BY 'typo3';"
        mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, CREATE VIEW, SHOW VIEW, EXECUTE, CREATE ROUTINE, ALTER ROUTINE ON *.* TO 'typo3'@'localhost';"
        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"
    echo "Done configuring typo3 database user"

    echo "Setting permissions"
        chmod -R 777 /var/log/apache2
        chown -R www-data /vagrant/typo3
        chgrp -R www-data /vagrant/typo3
        usermod -a -G www-data vagrant
    echo "Done setting permissions"

    # Our convention is that any file under sysfiles/ corresponds to an equivalent location
    # under / within the Vagrant machine. We replace the equivalent file (or create a new one)
    # with a symlink pointing to the file in the repository - that way any change to the file
    # in the repo is instantly in effect in the VM. In some rare cases we may have to copy files
    # into place for various technical reasons, which is why we call replace_with_link() for
    # each file instead of just looping.
    echo "Symlinking files from sysfiles/ into place"
        replace_with_link /home/vagrant/.bash_profile
        replace_with_link /etc/php/7.4/mods-available/eno-site.ini
        replace_with_link /etc/apache2/sites-enabled/000-default.conf
    echo "Done symlinking sysfiles/"

    echo "Configuring PHP"
        ln -s /etc/php/7.4/mods-available/eno-site.ini /etc/php/7.4/apache2/conf.d/99-eno-site.ini
        ln -s /etc/php/7.4/mods-available/eno-site.ini /etc/php/7.4/cli/conf.d/99-eno-site.ini
    echo "Done configuring PHP"

    echo "Restarting services"
        systemctl restart apache2
    echo "Done restarting services"

    echo "Generating Typo3 project"
        cd /vagrant
        su vagrant -c "composer create-project typo3/cms-base-distribution typo3";
        cd typo3
        php vendor/bin/typo3cms install:setup
    echo "Done generating Typo3 project"


  SHELL

  config.vm.provision :shell, run: 'always', inline: <<-SHELL
      systemctl restart apache2
  SHELL
end
