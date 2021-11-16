# Amazon linux 2-flask-uwsgi-nginx
Create docker image using AWS Linux 2 base image to run Python 3.8, Flask REST API application on uwsgi and Nginx.
# Description
This sample is to create your own Docker image that will be based on Amazon linux 2 base image and will run Python 3.8 based Flask Web application using uwsgi and nginx in single container.
Components Involved are as follows:
    Amazon Linus 2 - Base image
    
    Nginx - Web server, reverse proxy to uwsgi 
    
    uwsgi - App Server - to host Flask application
    
    Flask - Popular framework to create web application/ REST API
    
    Python 3.8 - Language to write Web Application/ REST API.
    
I won't be going in to details about uwsgi configurations as a part of this post. The objective is to run all in one container on Amazon linux 2.
# General Instructions
This repository has Dockerfile, script to do the initial setup and sample application.
Repository has -
  script - This folder has setup.sh script which does all the installation work.
  src - This folder has sample python flask application source code, templates folder to store html templates for applicaiton, system folder to store uwsgi configuration, nginx    configuration and ini files required to run application.
  Dockerfile - Docker file to create our image from Amazon linux 2 base image and make it ready to host our application.
We will see significance of each component in following sections.
# Dockerfile
Use Amazon linux 2 as a base image

    FROM amazonlinux

Copy script folder to container. This folder has setup.sh file which will do all the software installation work and setup work. There are lot of steps in order to get it ready to host the web application that is the reason I kept it in a separate file. It is also easy to run the setup file manually inside container using Docker desktop. This helps us to troubleshoot any issue.

    COPY script /script

Copy application related files and folder to /var/www location. Ths also has various config files to configure nginx, uwsgi and supervisord.

    COPY src/ /var/www/

Give execute permission.

    RUN chmod +x /script/setup.sh

Run the bash script. We will see the details in sections below.

    RUN yes | bash /script/setup.sh

Expose port

    EXPOSE 80

Run supervisord to launch uwsgi and nginx.

    CMD ["/usr/local/bin/supervisord","-c","/etc/supervisord.conf","-n"]

# script/setup.sh
This file is used to install all the components to run the application.

#!/bin/bash

Update system

    yum update -y
    
Install Nginx on Amazon linux 2

    amazon-linux-extras install nginx1 -y

Install components required to install uwsgi

    yum groupinstall "Development Tools" -y
    amazon-linux-extras install epel -y
    
Install Python 3.8

    amazon-linux-extras install python3.8 -y
    yum install python38-devel -y

Install supervisor. It will be used to run nginx and uwsgi and keep it running.

    pip3.8 install supervisor

Generate supervisord configuration

    echo_supervisord_conf > /etc/supervisord.conf

Modify supervisord.conf file to make it a foreground process so that container will not exit. It will keep running the uwsgi and nginx.

    sed -i 's/nodaemon=false/nodaemon=true/g' /etc/supervisord.conf
    
Add include statement to supervisord.conf file to include ini files which will have configuration for programs to run.
    sed -i -e '$a[include]' /etc/supervisord.conf
    sed -i -e '$afiles = supervisord.d/*.ini' /etc/supervisord.conf
    
Make directory called supervisord.d which will have links to external ini files.
    mkdir /etc/supervisord.d

Install requirements as per the requirements.txt in order to run our application. This will install Flask, uwsgi and other components. please refer the file for details.

    pip3.8 install -r /var/www/requirements.txt

We are keeping nginx configuration in external file and that file will be include in main nginx.conf file. This approach will make our nginx configuration easy to maintain.
  
    ln -s /var/www/system/hello_flask_nginx.conf /etc/nginx/conf.d/hello_flask_nginx.conf

Create link to program file that will be include in supervisord.conf file. This also will make configuration maintainance easy.

    ln -s /var/www/system/programs.ini /etc/supervisord.d/programs.ini

# src/system/hello_flask_nginx.conf
    This is the nginx configuration file that will be included in the main nginx.conf. This filw will have nginx settings required to run our application.
# src/system/hello_flask_uwsgi.ini
    This file has configurations required for uwsgi app server. This file is reffered in programs.ini. And used while launching uwsgi process.
# src/system/programs.ini
    This file is included in supervisord.conf file. It has information about which programs to launch using supervisord. This launches uwsgi and nginx.
 
# Building Docker Image
Copy the repository in local folder. Go to folder and run following command. No need to mention docker file name as it is in same folder.
    
    docker build -t myapp .

Launch container

    docker run -p 80:80 -t -d myapp

Test it in browser

    http://localhost
    http://localhost/hello/World
