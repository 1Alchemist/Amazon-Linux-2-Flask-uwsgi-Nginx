#!/bin/bash
## Run this script using yes | bash scriptname

echo -e "\e[0;32m Executing: update -y\e[0m"
yum update -y

echo -e "\e[0;32m Executing: nginx1\e[0m"
amazon-linux-extras install nginx1 -y

echo -e "\e[0;32m Executing: Development Tools\e[0m"
yum groupinstall "Development Tools" -y 

echo -e "\e[0;32m Executing: epel\e[0m"
amazon-linux-extras install epel -y

echo -e "\e[0;32m Executing: python38\e[0m"
amazon-linux-extras install python3.8 -y

echo -e "\e[0;32m Executing: python38-devel\e[0m"
yum install python38-devel -y

echo -e "\e[0;32m Executing: supervisor\e[0m"
pip3.8 install supervisor

echo -e "\e[0;32m Create supervisord.conf file\e[0m"
echo_supervisord_conf > /etc/supervisord.conf

echo -e "\e[0;32m update supervisord.conf\e[0m"
sed -i 's/nodaemon=false/nodaemon=true/g' /etc/supervisord.conf
sed -i -e '$a[include]' /etc/supervisord.conf
sed -i -e '$afiles = supervisord.d/*.ini' /etc/supervisord.conf
mkdir /etc/supervisord.d

echo -e "\e[0;32m install requirements\e[0m"
pip3.8 install -r /var/www/requirements.txt

echo -e "\e[0;32m create link to conf files\e[0m"
ln -s /var/www/system/hello_flask_nginx.conf /etc/nginx/conf.d/hello_flask_nginx.conf
# Create link to myprog
ln -s /var/www/system/programs.ini /etc/supervisord.d/programs.ini