# Instruções para uso do Dockerfile WordPress no Coolify

Este pacote contém um Dockerfile completo para WordPress com PHP 8.2, Nginx, MariaDB, OPcache, Redis e as principais extensões PHP, tudo em um único contêiner otimizado para ambiente de produção.

## Conteúdo do pacote

- `Dockerfile`: Configuração principal com todos os serviços
- `nginx.conf`: Configuração global do Nginx
- `default.conf`: Configuração do servidor virtual Nginx para WordPress
- `supervisord.conf`: Configuração do Supervisor para gerenciar múltiplos serviços
- `entrypoint.sh`: Script de inicialização para configurar o ambiente

## Como usar no Coolify

1. Faça upload do diretório contendo estes arquivos para seu repositório Git
2. No Coolify, crie uma nova implantação do tipo "Docker"
3. Selecione seu repositório Git contendo estes arquivos
4. Configure as seguintes variáveis de ambiente (opcional):
   - `MYSQL_ROOT_PASSWORD`: Senha do root do MariaDB (padrão: aleatória)
   - `MYSQL_DATABASE`: Nome do banco de dados (padrão: wordpress)
   - `MYSQL_USER`: Usuário do banco de dados (padrão: wordpress)
   - `MYSQL_PASSWORD`: Senha do banco de dados (padrão: wordpress_password)

5. Defina a porta de publicação como 80
6. Inicie a implantação

## Persistência de dados

Para garantir a persistência dos dados, configure volumes no Coolify:

- `/var/www/html`: Arquivos do WordPress
- `/var/lib/mysql`: Dados do MariaDB
- `/var/lib/redis`: Dados do Redis

## Segurança

Por padrão, o Dockerfile configura senhas básicas para desenvolvimento. Para ambiente de produção, é altamente recomendável:

1. Alterar as senhas padrão através das variáveis de ambiente
2. Configurar HTTPS/SSL no Coolify
3. Considerar a implementação de um Web Application Firewall (WAF)

## Otimização

O Dockerfile já inclui otimizações para produção:

- OPcache configurado para melhor desempenho
- Redis para cache de objetos
- Compressão Gzip ativada
- Cache de arquivos estáticos configurado

## Solução de problemas

Se encontrar problemas durante a implantação:

1. Verifique os logs do contêiner no Coolify
2. Certifique-se de que todas as portas necessárias estão acessíveis
3. Verifique se os volumes foram configurados corretamente

Para suporte adicional, consulte a documentação do Coolify ou entre em contato com o suporte.
