#!/bin/bash


# We need to create nagios user and nagcmd group.
sudo useradd nagios

# Then we need to add the user “nagios” to the group:
sudo groupadd nagcmd
sudo usermod -aG nagcmd nagios

# Update your package lists to ensure you can download the latest
sudo apt update 

# Then we need to install the required packages:
cd
sudo apt-get install wget libapache2-mod-php build-essential openssl libssl-dev unzip apache2 libgd-dev -y

# Download Nagios
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz

# Uncompress the Nagios archive:
tar -zvxf nagios-4.4.6.tar.gz

# Execute the configure script:
cd nagios-4.4.6/
./configure --with-nagios-group=nagios --with-command-group=nagcmd

# Compile Nagios with this command:
make all

# Now run the other make commands to install Nagios init scripts, configuration files, and set permissions:
sudo make install
sudo make install-commandmode
sudo make install-init
sudo make install-config

# We will use Apache2 to serve Nagios' GUI
sudo cp sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf

# Add the web server user “www-data” to the “nagcmd” group:
sudo usermod -G nagcmd www-data

# go back to home dir
cd

# Download Nagios Plugins source:
wget http://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz

# Uncompress the Nagios-Plugins:
tar -vxzf nagios-plugins-2.3.3.tar.gz

# Now run the other make commands to install Nagios init scripts, configuration files, and set permissions:
cd nagios-plugins-2.3.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl

# now install nagios-plugin
make
sudo make install 

# Installing NRPE on Server
cd
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.2/nrpe-4.0.2.tar.gz

# Uncompress NRPE:
tar -xvzf nrpe-4.0.2.tar.gz

# Change to the extracted directory:
cd nrpe-4.0.2

# Configure the NRPE plugin:
./configure

# Then build and install NRPE (check_nrpe) plugin:
make check_nrpe
sudo make install-plugin

# Configure Nagios
sudo sed -i  '/^#cfg_dir=\/usr\/local\/nagios\/etc\/servers/s/^#//' /usr/local/nagios/etc/nagios.cfg

# Now create the directory which will store the configuration files:
sudo mkdir /usr/local/nagios/etc/servers

# Add “check_npre” in Nagios

sudo echo "define command{
	command_name check_nrpe
	command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
	}
" >> /usr/local/nagios/etc/objects/commands.cfg

# Enable the Apache rewrite and cgi modules with the a2enmod
sudo a2enmod rewrite
sudo a2enmod cgi

# set htpasswd for secure url  manully
echo "set password for htpasswdd manully -> "
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users admin

sudo ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/

# Add “nagios” service

sudo touch /etc/systemd/system/nagios.service
sudo chmod o+w /etc/systemd/system/nagios.service

echo "[Unit]
Description=Nagios
BindTo=network.target
[Install]
WantedBy=multi-user.target
[Service]
Type=simple
User=nagios
Group=nagios
ExecStart=/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg" >> /etc/systemd/system/nagios.service
sudo chmod o-w /etc/systemd/system/nagios.service

sudo systemctl enable /etc/systemd/system/nagios.service
sudo systemctl start nagios
sudo systemctl restart apache2

# or on container /etc/init.d/nagios restart

# done 
