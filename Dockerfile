# Dockerfile para WordPress com PHP 8.2, Nginx, OPcache, Redis
# Otimizado para ambiente de produção e uso no Coolify

# Imagem base PHP 8.2 com FPM
FROM php:8.2-fpm-alpine

# Instalação de dependências essenciais
RUN apk update && apk upgrade && \
    apk add --no-cache \
    nginx \
    supervisor \
    bash \
    nano \
    git \
    zip \
    unzip \
    curl

# Instalação de dependências para extensões PHP
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    linux-headers

# Instalação do MariaDB client (sem o servidor)
RUN apk add --no-cache mariadb-client

# Instalação do Redis client (sem o servidor)
RUN apk add --no-cache redis

# Configuração e instalação das extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
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
    sockets

# Instalação da extensão Redis para PHP
RUN pecl install redis && \
    docker-php-ext-enable redis

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

# Configuração do Supervisor
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
