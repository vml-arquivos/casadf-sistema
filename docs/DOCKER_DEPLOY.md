# 🐳 Deploy com Docker - Corretor das Mansões

Guia completo para fazer deploy da aplicação usando Docker e Docker Compose.

## 📋 Pré-requisitos

- Docker 20.10+ instalado
- Docker Compose 2.0+ instalado
- 2GB de RAM disponível
- 10GB de espaço em disco

### Instalar Docker

#### Linux (Ubuntu/Debian)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### macOS
```bash
brew install --cask docker
```

#### Windows
Baixe e instale o [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Instalar Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 🚀 Deploy Rápido

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/corretordasmansoes.git
cd corretordasmansoes
```

### 2. Configure as Variáveis de Ambiente

```bash
# Copie o template
cp .env.example .env

# Edite com seus valores
nano .env
```

**Variáveis obrigatórias:**
- `DATABASE_URL`
- `JWT_SECRET` (gere com: `openssl rand -base64 32`)
- `VITE_APP_ID`
- `OAUTH_SERVER_URL`
- Veja [ENV_VARIABLES.md](./ENV_VARIABLES.md) para lista completa

### 3. Execute o Deploy

```bash
# Opção 1: Usando script automatizado
./deploy.sh

# Opção 2: Manualmente
docker-compose up -d
```

### 4. Acesse a Aplicação

- **Aplicação:** http://localhost:3000
- **phpMyAdmin:** http://localhost:8080 (se habilitado)

## 📦 Estrutura dos Containers

### Serviços

1. **app** - Aplicação web (Frontend + Backend)
   - Porta: 3000
   - Imagem: Custom build
   - Health check: `/health`

2. **db** - Banco de dados MySQL 8.0
   - Porta: 3306
   - Volume: `mysql_data`
   - Health check: mysqladmin ping

3. **phpmyadmin** (opcional) - Interface web para MySQL
   - Porta: 8080
   - Profile: `dev`

## 🔧 Comandos Úteis

### Gerenciamento de Containers

```bash
# Iniciar todos os serviços
docker-compose up -d

# Parar todos os serviços
docker-compose down

# Reiniciar serviços
docker-compose restart

# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f app
docker-compose logs -f db
```

### Build e Rebuild

```bash
# Build sem cache
docker-compose build --no-cache

# Rebuild e reiniciar
docker-compose up -d --build

# Rebuild apenas um serviço
docker-compose build app
```

### Banco de Dados

```bash
# Executar migrations
docker-compose exec app pnpm db:push

# Backup do banco
docker-compose exec db mysqldump -u corretor -p corretordasmansoes > backup.sql

# Restaurar backup
docker-compose exec -T db mysql -u corretor -p corretordasmansoes < backup.sql

# Acessar MySQL CLI
docker-compose exec db mysql -u corretor -p
```

### Limpeza

```bash
# Remover containers e volumes
docker-compose down -v

# Remover imagens não utilizadas
docker image prune -a

# Limpar tudo (cuidado!)
docker system prune -a --volumes
```

## 🔍 Troubleshooting

### Container não inicia

```bash
# Ver logs detalhados
docker-compose logs app

# Verificar configuração
docker-compose config

# Reiniciar do zero
docker-compose down -v
docker-compose up -d
```

### Erro de conexão com banco de dados

```bash
# Verificar se banco está rodando
docker-compose ps db

# Ver logs do banco
docker-compose logs db

# Testar conexão
docker-compose exec app ping db
```

### Aplicação não responde

```bash
# Verificar health check
docker-compose ps

# Entrar no container
docker-compose exec app sh

# Verificar variáveis de ambiente
docker-compose exec app env
```

### Porta já em uso

```bash
# Mudar porta no docker-compose.yml
# De: "3000:3000"
# Para: "8000:3000"

# Ou parar processo que está usando a porta
sudo lsof -i :3000
sudo kill -9 <PID>
```

## 🌐 Deploy em Produção

### Servidor VPS/Cloud

1. **Conecte ao servidor:**
```bash
ssh user@seu-servidor.com
```

2. **Clone e configure:**
```bash
git clone https://github.com/seu-usuario/corretordasmansoes.git
cd corretordasmansoes
cp .env.example .env
nano .env  # Configure variáveis
```

3. **Execute deploy:**
```bash
./deploy.sh
```

4. **Configure proxy reverso (Nginx):**
```nginx
server {
    listen 80;
    server_name corretordasmansoes.com.br;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

5. **Configure SSL (Let's Encrypt):**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d corretordasmansoes.com.br
```

### AWS ECS

1. **Build e push para ECR:**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker build -t corretordasmansoes .
docker tag corretordasmansoes:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/corretordasmansoes:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/corretordasmansoes:latest
```

2. **Crie task definition e service no ECS**

### Google Cloud Run

```bash
# Build e deploy
gcloud builds submit --tag gcr.io/PROJECT-ID/corretordasmansoes
gcloud run deploy corretordasmansoes \
  --image gcr.io/PROJECT-ID/corretordasmansoes \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Azure Container Instances

```bash
# Build e push
az acr build --registry <registry-name> --image corretordasmansoes .

# Deploy
az container create \
  --resource-group myResourceGroup \
  --name corretordasmansoes \
  --image <registry-name>.azurecr.io/corretordasmansoes \
  --dns-name-label corretordasmansoes \
  --ports 3000
```

## 🔐 Segurança

### Checklist de Segurança

- [ ] Alterar senhas padrão do MySQL
- [ ] Gerar JWT_SECRET forte
- [ ] Configurar HTTPS/SSL
- [ ] Configurar firewall (apenas portas 80, 443)
- [ ] Desabilitar phpMyAdmin em produção
- [ ] Usar secrets manager para credenciais
- [ ] Configurar backup automático do banco
- [ ] Monitorar logs de segurança
- [ ] Atualizar imagens Docker regularmente

### Variáveis Sensíveis

**NUNCA** commite no Git:
- `.env`
- Senhas
- API keys
- Tokens

Use secrets managers:
- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- HashiCorp Vault

## 📊 Monitoramento

### Health Checks

```bash
# Verificar saúde da aplicação
curl http://localhost:3000/health

# Verificar banco de dados
docker-compose exec db mysqladmin ping -h localhost -u root -p
```

### Logs

```bash
# Logs em tempo real
docker-compose logs -f --tail=100

# Exportar logs
docker-compose logs > logs.txt
```

### Métricas

Configure ferramentas de monitoramento:
- Prometheus + Grafana
- DataDog
- New Relic
- AWS CloudWatch

## 🔄 Atualizações

### Atualizar Aplicação

```bash
# Pull última versão
git pull origin main

# Rebuild e restart
docker-compose up -d --build

# Executar migrations
docker-compose exec app pnpm db:push
```

### Rollback

```bash
# Voltar para versão anterior
git checkout <commit-hash>
docker-compose up -d --build
```

## 📚 Recursos Adicionais

- [Documentação Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [MySQL Docker](https://hub.docker.com/_/mysql)
- [Guia de Deploy Geral](./DEPLOY.md)
- [Variáveis de Ambiente](./ENV_VARIABLES.md)

## 🆘 Suporte

- **Issues:** https://github.com/seu-usuario/corretordasmansoes/issues
- **Email:** suporte@corretordasmansoes.com.br
- **Documentação:** https://docs.corretordasmansoes.com.br
