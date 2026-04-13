FROM php:8.3-fpm

LABEL maintainer="Pavlo Vavilov"

ENV USER_UID 1000
ENV USER_NAME app
ENV USER_HOME /home/app

WORKDIR /var/www/html

ADD .docker/supervisor/supervisord.conf /etc/supervisor/conf.d/


RUN apt-get update && apt-get install -y \
        libpq-dev \
        libonig-dev \
        libzip-dev \
        unzip \
        supervisor \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo

# PHP-SPX

ADD .docker/php/php-spx.ini /usr/local/etc/php/conf.d/

RUN apt-get install -y \
    git \
    zlib1g-dev \
    && git clone https://github.com/NoiseByNorthwest/php-spx.git /php-spx \
    && cd /php-spx \
    && git checkout v0.4.22 \
    && phpize \
    && ./configure \
    && make \
    && make install

# END PHP-SPX

CMD ["/bin/bash", "-c", "/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
