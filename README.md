# Instruções para uso do Dockerfile WordPress no Coolify

Este pacote contém um Dockerfile para WordPress com PHP 8.2, Nginx, OPcache, e suporte para conexão com MariaDB e Redis externos, otimizado para ambiente de produção no Coolify.

## Conteúdo do pacote

- `Dockerfile`: Configuração principal com PHP 8.2, Nginx e extensões necessárias
- `nginx.conf`: Configuração global do Nginx
- `default.conf`: Configuração do servidor virtual Nginx para WordPress
- `supervisord.conf`: Configuração do Supervisor para gerenciar serviços
- `entrypoint.sh`: Script de inicialização para configurar o ambiente

## Importante: Serviços Externos

Esta configuração foi otimizada para usar **serviços externos** de banco de dados e cache:

- **MariaDB/MySQL**: Deve ser configurado como serviço separado
- **Redis**: Deve ser configurado como serviço separado (opcional)

## Como usar no Coolify

1. Faça upload do diretório contendo estes arquivos para seu repositório Git
2. No Coolify, crie uma nova implantação do tipo "Docker" para o WordPress
3. Crie serviços separados para MariaDB e Redis (opcional)
4. Configure as seguintes variáveis de ambiente no serviço WordPress:
   - `MYSQL_HOST`: Hostname do serviço MariaDB (ex: db)
   - `MYSQL_DATABASE`: Nome do banco de dados (ex: wordpress)
   - `MYSQL_USER`: Usuário do banco de dados (ex: wordpress)
   - `MYSQL_PASSWORD`: Senha do banco de dados
   - `REDIS_HOST`: Hostname do serviço Redis (opcional)
   - `REDIS_PORT`: Porta do serviço Redis (opcional, padrão: 6379)

5. Defina a porta de publicação como 80
6. Inicie a implantação

## Configuração de Serviços Externos no Coolify

### MariaDB
```yaml
# Exemplo de configuração para MariaDB no Coolify
services:
  db:
    image: mariadb:10.6
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
    volumes:
      - mariadb_data:/var/lib/mysql
```

### Redis (opcional)
```yaml
# Exemplo de configuração para Redis no Coolify
services:
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
```

## Persistência de dados

Para garantir a persistência dos dados, configure volumes no Coolify:

- `/var/www/html`: Arquivos do WordPress

## Segurança

Por padrão, o Dockerfile configura senhas básicas para desenvolvimento. Para ambiente de produção, é altamente recomendável:

1. Usar senhas fortes nas variáveis de ambiente
2. Configurar HTTPS/SSL no Coolify
3. Considerar a implementação de um Web Application Firewall (WAF)
4. Limitar o acesso aos serviços de banco de dados e cache apenas ao container WordPress

## Otimização

O Dockerfile já inclui otimizações para produção:

- OPcache configurado para melhor desempenho
- Suporte a Redis para cache de objetos (quando configurado)
- Compressão Gzip ativada
- Cache de arquivos estáticos configurado

## Solução de problemas

Se encontrar problemas durante a implantação:

1. Verifique os logs do contêiner no Coolify
2. Certifique-se de que todas as portas necessárias estão acessíveis
3. Verifique se os volumes foram configurados corretamente
4. Confirme que as variáveis de ambiente estão configuradas corretamente
5. Verifique a conectividade entre os serviços (WordPress, MariaDB, Redis)

Para suporte adicional, consulte a documentação do Coolify ou entre em contato com o suporte.
