#!/bin/bash
set -e

# Configurar WordPress se necessário
configure_wordpress() {
    if [ ! -f "/var/www/html/wp-config.php" ]; then
        echo "Configurando WordPress..."
        cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
        
        # Configurar conexão com banco de dados
        sed -i "s/database_name_here/${MYSQL_DATABASE:-wordpress}/g" /var/www/html/wp-config.php
        sed -i "s/username_here/${MYSQL_USER:-wordpress}/g" /var/www/html/wp-config.php
        sed -i "s/password_here/${MYSQL_PASSWORD:-wordpress_password}/g" /var/www/html/wp-config.php
        sed -i "s/localhost/${MYSQL_HOST:-db}/g" /var/www/html/wp-config.php
        
        # Adicionar suporte ao Redis se configurado
        if [ ! -z "$REDIS_HOST" ]; then
            cat >> /var/www/html/wp-config.php << EOF

/* Redis settings */
define('WP_CACHE', true);
define('WP_REDIS_HOST', '${REDIS_HOST}');
define('WP_REDIS_PORT', ${REDIS_PORT:-6379});
EOF
        fi
        
        # Gerar chaves de segurança
        curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php
        
        # Definir permissões corretas
        chown -R www-data:www-data /var/www/html
        chmod -R 755 /var/www/html
    fi
}

# Executar inicializações
configure_wordpress

# Criar diretórios necessários
mkdir -p /var/log/supervisor

# Executar comando fornecido
exec "$@"
