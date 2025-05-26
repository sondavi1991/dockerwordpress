#!/bin/bash
set -e

# Função para inicializar o banco de dados MariaDB
initialize_mariadb() {
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Inicializando MariaDB..."
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
        
        # Iniciar MariaDB temporariamente para configuração
        mysqld_safe --user=mysql --datadir=/var/lib/mysql &
        MYSQL_PID=$!
        
        # Aguardar MariaDB iniciar
        until mysqladmin ping -s; do
            echo "Aguardando MariaDB iniciar..."
            sleep 1
        done
        
        # Configurar MariaDB
        mysql -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        mysql -e "CREATE USER IF NOT EXISTS 'wordpress'@'localhost' IDENTIFIED BY 'wordpress_password';"
        mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
        
        # Parar MariaDB temporário
        kill $MYSQL_PID
        wait $MYSQL_PID || true
    fi
}

# Configurar WordPress se necessário
configure_wordpress() {
    if [ ! -f "/var/www/html/wp-config.php" ]; then
        echo "Configurando WordPress..."
        cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
        
        # Configurar conexão com banco de dados
        sed -i "s/database_name_here/wordpress/g" /var/www/html/wp-config.php
        sed -i "s/username_here/wordpress/g" /var/www/html/wp-config.php
        sed -i "s/password_here/wordpress_password/g" /var/www/html/wp-config.php
        
        # Adicionar suporte ao Redis
        cat >> /var/www/html/wp-config.php << 'EOF'

/* Redis settings */
define('WP_CACHE', true);
define('WP_REDIS_HOST', '127.0.0.1');
define('WP_REDIS_PORT', 6379);

/* Unique Authentication Keys and Salts */
EOF
        
        # Gerar chaves de segurança
        curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php
        
        # Definir permissões corretas
        chown -R www-data:www-data /var/www/html
        chmod -R 755 /var/www/html
    fi
}

# Executar inicializações
initialize_mariadb
configure_wordpress

# Executar comando fornecido
exec "$@"
