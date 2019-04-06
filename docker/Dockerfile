FROM php:7.1-apache

RUN apt-get update 
RUN apt-get install vim libpng-dev zip zlib1g-dev g++ libicu-dev -y

# enable url rewrite
RUN a2enmod rewrite

RUN docker-php-ext-install mysqli
# RUN docker-php-ext-install mysql #only php<7
RUN docker-php-ext-install zip
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install gd
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# RUN pear install HTTP_Session2-0.7.3

# apt-get install software-properties-common
# add-apt-repository ppa:ondrej/php

# apt-get update
# apt-get install php5-mysql