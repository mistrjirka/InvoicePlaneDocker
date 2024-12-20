# Use the official PHP image with Apache
FROM php:8.1-apache

# Install necessary packages and PHP extensions
RUN apt-get update && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        unzip \
        wget && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd mysqli zip && \
    a2enmod rewrite && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the ServerName to your desired domain
RUN echo "ServerName solar.local" >> /etc/apache2/apache2.conf

# Set the working directory
WORKDIR /var/www/html

# Download and extract InvoicePlane
RUN wget -O InvoicePlane.zip https://invoiceplane.com/download/v1.6.1 && \
    unzip InvoicePlane.zip && \
    mv ip/* . && \
    rm -rf ip InvoicePlane.zip && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Ensure ipconfig.php exists
RUN cp ipconfig.php.example ipconfig.php
RUN chown www-data:www-data ipconfig.php && chmod 666 ipconfig.php
# Dynamically update ipconfig.php to your desired URL
RUN sed -i "s|IP_URL=|IP_URL=http://solar.local:8888/|g" ipconfig.php && \
    sed -i "s|DB_HOSTNAME=|DB_HOSTNAME=db|g" ipconfig.php && \
    sed -i "s|DB_USERNAME=|DB_USERNAME=invoiceuser|g" ipconfig.php && \
    sed -i "s|DB_PASSWORD=|DB_PASSWORD=securepassword|g" ipconfig.php && \
    sed -i "s|DB_DATABASE=|DB_DATABASE=invoiceplane|g" ipconfig.php && \
    sed -i "s|DB_PORT=|DB_PORT=3306|g" ipconfig.php 
#    sed -i "s|SETUP_COMPLETED=false|SETUP_COMPLETED=true|g" ipconfig.php

