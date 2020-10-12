# Nagios_Ubuntu
Installation of nagions server and nagios-plugins, nrpe and host installation etc.

Monitoring and Logging


Install and configure Nagios Server
Install nagios addon's and pluginsPrivate LimitedWhat’s Nagios?
- Nagios, now known as Nagios Core
- Written in: C
- Stable release: 4.3.2 / May 9, 2017
- Original author(s): Ethan Galstad
- Initial release: March 14, 1999
- It is a free and open source computer-software application that
monitors systems, networks and infrastructure
2What’s NRPE?
- Nagios Remote Plugin Executor (NRPE)
- NRPE allows you to remotely execute Nagios plugins on other
Linux/Unix machines
- This allows you to monitor remote machine metrics (disk usage, CPU
load, etc.)
- NRPE can also communicate with some of the Windows agent addons,
so you can execute scripts and check metrics on remote Windows
machines as well
- Nagios periodically polls the agent on remote system using the
check_nrpe plugin
3How it works?
4What’s NSClient++?
- This program is mainly used to monitor Windows machines.
- Being installed on a remote system NSClient++ listens to port TCP
12489
- The Nagios plugin that is used to collect information from this addon
is called check_nt.
5Install Nagios
..to be continued
We need to create nagios user and nagcmd group.
 sudo useradd nagios
 sudo groupadd nagcmd
Then we need to add the user “nagios” to the group:

6
sudo usermod -a -G nagcmd nagiosInstall Nagios
..to be continued
Update your package lists to ensure you can download the latest
versions of the required packages:

sudo apt-get update
Then we need to install the required packages:
sudo apt-get install wget libapache2-mod-php build-essential libgd2-
xpm-dev openssl libssl-dev unzip apache2
7Install Nagios
..to be continued
Download Nagios

wget -c
https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.
3.4.tar.gz
Uncompress the Nagios archive:
 tar zxf nagios-4.3.4.tar.gz
 cd nagios-4.3.4
Execute the configure script:

8
./configure --with-nagios-group=nagios --with-command-
group=nagcmdInstall Nagios
..to be continued
Compile Nagios with this command:

make all
Now run the other make commands to install Nagios init scripts, configuration
files, and set permissions:
 sudo make install
 sudo make install-commandmode
 sudo make install-init
 sudo make install-config
We will use Apache2 to serve Nagios' GUI

9
cp sample-config/httpd.conf /etc/apache2/sites-available/nagios.confInstall Nagios
Add the web server user “www-data” to the “nagcmd” group:

10
sudo usermod -G nagcmd www-dataInstall Nagios plugins
..to be continued
Download Nagios Plugins source:

wget -c
http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
Uncompress source and change to the extracted directory:
11
 tar vxzf nagios-plugins-2.2.1.tar.gz
 cd nagios-plugins-2.2.1Install Nagios plugins
Configure Nagios Plugins:

./configure --with-nagios-user=nagios --with-nagios-group=nagios
--with-openssl
Lets compile and install the plugins
12
 make
 make installInstalling NRPE on Server
..to be continued
Download NRPE source

wget
https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-
3.2.1/nrpe-3.2.1.tar.gz
Uncompress NRPE:

tar zxf nrpe-3.2.1.tar.gz
Change to the extracted directory:

13
cd nrpe-3.2.1Configure NRPE on Server
Configure the NRPE plugin:

./configure
Then build and install NRPE (check_nrpe) plugin:
14
 make check_nrpe
 sudo make install-pluginConfigure Nagios
Open the main Nagios configuration file in your text editor
(/usr/local/nagios/etc/nagios.cfg) and uncomment below line:

cfg_dir=/usr/local/nagios/etc/servers
Now create the directory which will store the configuration files:

15
sudo mkdir /usr/local/nagios/etc/serversAdd “check_npre” in Nagios
Next, add check_npre command in file,
/usr/local/nagios/etc/objects/commands.cfg
define command{
command_name check_nrpe
command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
16Configuring Apache
Enable the Apache rewrite and cgi modules with the a2enmod
command:
 sudo a2enmod rewrite
 sudo a2enmod cgi
 sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

17
sudo ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-
enabled/Add “nagios” service

vim /etc/systemd/system/nagios.service
[Unit]
Description=Nagios
BindTo=network.target
[Install]
WantedBy=multi-user.target
[Service]
Type=simple
User=nagios
Group=nagios
ExecStart=/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg


sudo systemctl enable /etc/systemd/system/nagios.service
sudo systemctl start nagios or on container /etc/init.d/nagios
restart
18Congratulations !!
Nagios server is Installed and Configured.
Lets add a host now.
19Install NRPE on a Host
..to be continued
Create a "nagios" which we will use to run nrpe agent:

useradd nagios
Update the package sources and install the required packages:


20
sudo apt-get update
sudo apt-get install openssl build-essential libgd2-xpm-dev libssl-
devInstall NRPE on a Host
..to be continued
Download Nagios plugins:

wget -c
http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
Uncompress Nagios plugin and change to the uncompressed directory:
21
 tar zxf nagios-plugins-2.2.1.tar.gz
 cd nagios-plugins-2.2.1Install NRPE on a Host
..to be continued
Configure Nagios plugins:

./configure --with-nagios-user=nagios --with-nagios-group=nagios
--with-openssl
Compile and install Nagios plugins:
22
 make
 make installInstall NRPE on a Host
..to be continued
Download and uncompress NRPE source:

wget
https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.
2.1.tar.gz
 tar zxvf nrpe-3.2.1.tar.gz
 cd nrpe-3.2.1
Configure, compile and install Nagios plugins:

23
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-
group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
 make all
 sudo make install
 sudo make install-config
 sudo make install-initInstall NRPE on a Host
Now, we need to allow Nagios server to connect with NRPE in file
/usr/local/nagios/etc/nrpe.cfg:

allowed_hosts=127.0.0.1,<my_nagios_server_ip_address>
Now start the service:
24
 systemctl start nrpe.service
 systemctl status nrpe.serviceThank you.
25
