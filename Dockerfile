# Dockerfile para WordPress com PHP 8.2, Nginx, MariaDB, OPcache, Redis
# Otimizado para ambiente de produção e uso no Coolify

# Estágio de construção para PHP e Nginx
FROM php:8.2-fpm-alpine AS php-base

# Instalação de dependências e extensões PHP
RUN apk add --no-cache \
    nginx \
    mariadb mariadb-client \
    redis \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev \
    libmemcached-dev \
    openssl-dev \
    supervisor \
    bash \
    nano \
    git \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    opcache \
    intl \
    mbstring \
    xml \
    zip \
    exif \
    bcmath \
    soap \
    calendar \
    sockets

# Instalação do Redis para PHP
RUN pecl install redis \
    && docker-php-ext-enable redis

# Configuração do OPcache para ambiente de produção
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.jit=1255'; \
    echo 'opcache.jit_buffer_size=128M'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Configuração do PHP para produção
RUN { \
    echo 'memory_limit=256M'; \
    echo 'upload_max_filesize=64M'; \
    echo 'post_max_size=64M'; \
    echo 'max_execution_time=300'; \
    echo 'max_input_vars=3000'; \
    echo 'date.timezone=UTC'; \
    } > /usr/local/etc/php/conf.d/wordpress-recommended.ini

# Configuração do Nginx
RUN mkdir -p /run/nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Instalação do WordPress
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && rm latest.tar.gz \
    && mv wordpress/* . \
    && rmdir wordpress \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configuração do MariaDB
RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld \
    && mkdir -p /var/lib/mysql \
    && chown -R mysql:mysql /var/lib/mysql

# Configuração do Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configuração do Redis
RUN mkdir -p /var/lib/redis \
    && chown -R redis:redis /var/lib/redis

# Script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
