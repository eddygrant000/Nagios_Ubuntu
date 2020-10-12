#!/bin/bash

# Step 6 — Installing Nagios Plugins and NRPE Daemon on a Host

# Create a "nagios" which we will use to run nrpe agent:
sudo useradd nagios

# Update the package sources and install the required packages:
sudo apt update
sudo apt install autoconf gcc libmcrypt-dev make libssl-dev wget dc build-essential gettext openssl -y

# Download and uncompress NRPE source:
cd
wget http://www.nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar -xzvf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
make && sudo make install

cd
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz
tar -xzvf nrpe-4.0.3.tar.gz
cd nrpe-4.0.3/

# Configure, compile and install Nagios plugins:
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
sudo make install
sudo make install-config
sudo make install-init

read -p "Enter Private Ip of Nagios Server: " NAGIOS_SERVER_IP
sudo sed -i "/^allowed_hosts/c\allowed_hosts==127.0.0.1,::1,$NAGIOS_SERVER_IP" /usr/local/nagios/etc/nrpe.cfg
sudo systemctl enable nrpe.service
sudo systemctl start nrpe.service
sudo systemctl status nrpe.service
echo "expose 5666 port number"