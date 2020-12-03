FROM php:7.2-apache

MAINTAINER juliano.buzanello@engesoftware.com.br

COPY ./oracle/. /tmp/.

ENV LD_LIBRARY_PATH /usr/local/instantclient

RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        git \
        unzip \
        libbz2-dev \
        libzip-dev \
        zip \
        libaio-dev \
        libxml2-dev \
        libpng-dev \
        libxrender1 \
        libfontconfig1 \
        ldap-utils \
        libldap2-dev \
    && apt-get clean -y

RUN unzip -o /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    unzip -o /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    unzip -o /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
    ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so && \
    ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'export ORACLE_HOME="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'umask 002' >> /root/.bashrc && \
    docker-php-ext-configure oci8 -with-oci8=instantclient,/usr/local/instantclient && \
    docker-php-ext-install oci8

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chmod +x /usr/local/bin/composer
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install soap zip bz2 bcmath gd intl ldap
RUN pecl install xdebug docker-php-ext-enable xdebug

RUN echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo 'xdebug.remote_handler=dbgp' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo 'xdebug.remote_port =9000' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo 'xdebug.remote_autostart=1' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo 'xdebug.idekey=PHPSTORM' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN a2enmod rewrite && service apache2 stop
