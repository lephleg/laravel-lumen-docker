#######################################################################
#            Laravel/Lumen 5.8 Application - Dockerfile v0.5          #
#######################################################################

#------------- Setup Environment -------------------------------------------------------------

# Pull base image
FROM ubuntu:16.04

# Install common tools 
RUN apt-get update
RUN apt-get install -y wget curl nano htop git unzip bzip2 software-properties-common locales

# Set evn var to enable xterm terminal
ENV TERM=xterm

# Set working directory
WORKDIR /var/www/html

# Set up locales 
# RUN locale-gen 

#------------- Application Specific Stuff ----------------------------------------------------

# Install PHP
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt-get install -y \
    php7.2-fpm \ 
    php7.2-common \ 
    php7.2-curl \ 
    php7.2-mysql \ 
    php7.2-mbstring \ 
    php7.2-json \
    php7.2-xml \
    php7.2-bcmath

# Install NPM and Node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs 

#------------- FPM & Nginx configuration ----------------------------------------------------

# Config fpm to use TCP instead of unix socket
ADD resources/www.conf /etc/php/7.2/fpm/pool.d/www.conf
RUN mkdir -p /var/run/php

# Install Nginx
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y nginx

ADD resources/default /etc/nginx/sites-enabled/
ADD resources/nginx.conf /etc/nginx/

#------------- Composer & laravel configuration ----------------------------------------------------

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#------------- Supervisor Process Manager ----------------------------------------------------

# Install supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
ADD resources/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#------------- Container Config ---------------------------------------------------------------

# Expose port 80
EXPOSE 80

# Set supervisor to manage container processes
ENTRYPOINT ["/usr/bin/supervisord"]
