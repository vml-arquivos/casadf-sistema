# 🌐 Deploy no Google Cloud VM - CasaDF

Guia completo e passo a passo para fazer deploy do sistema CasaDF em uma VM do Google Cloud Platform.

## 📋 Pré-requisitos

- Conta no Google Cloud Platform
- Projeto criado no GCP
- Faturamento habilitado
- `gcloud` CLI instalado (opcional, pode usar Cloud Shell)

## 🚀 Passo 1: Criar VM no Google Cloud

### Via Console Web

1. Acesse [Google Cloud Console](https://console.cloud.google.com)
2. Navegue para **Compute Engine** → **VM instances**
3. Clique em **CREATE INSTANCE**
4. Configure a instância:

```
Nome: casadf-sistema
Região: us-central1 (ou mais próxima do Brasil: southamerica-east1)
Zona: us-central1-a

Tipo de máquina:
  - Série: E2
  - Tipo: e2-medium (2 vCPU, 4 GB RAM)
  - Para produção: e2-standard-2 (2 vCPU, 8 GB RAM)

Disco de inicialização:
  - Sistema operacional: Ubuntu
  - Versão: Ubuntu 22.04 LTS
  - Tipo de disco: SSD persistente
  - Tamanho: 30 GB (mínimo 20 GB)

Firewall:
  ✅ Permitir tráfego HTTP
  ✅ Permitir tráfego HTTPS
```

5. Clique em **CREATE**

### Via gcloud CLI

```bash
gcloud compute instances create casadf-sistema \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=30GB \
  --boot-disk-type=pd-ssd \
  --tags=http-server,https-server
```

## 🔧 Passo 2: Configurar Firewall

### Via Console Web

1. Navegue para **VPC Network** → **Firewall**
2. Clique em **CREATE FIREWALL RULE**

**Regra HTTP:**
```
Nome: allow-http
Destinos: Specified target tags
Tags de destino: http-server
Filtros de origem: 0.0.0.0/0
Protocolos e portas: tcp:80
```

**Regra HTTPS:**
```
Nome: allow-https
Destinos: Specified target tags
Tags de destino: https-server
Filtros de origem: 0.0.0.0/0
Protocolos e portas: tcp:443
```

**Regra Aplicação (porta 3000):**
```
Nome: allow-app-3000
Destinos: Specified target tags
Tags de destino: http-server
Filtros de origem: 0.0.0.0/0
Protocolos e portas: tcp:3000
```

### Via gcloud CLI

```bash
# HTTP
gcloud compute firewall-rules create allow-http \
  --allow tcp:80 \
  --target-tags http-server \
  --source-ranges 0.0.0.0/0

# HTTPS
gcloud compute firewall-rules create allow-https \
  --allow tcp:443 \
  --target-tags https-server \
  --source-ranges 0.0.0.0/0

# Aplicação
gcloud compute firewall-rules create allow-app-3000 \
  --allow tcp:3000 \
  --target-tags http-server \
  --source-ranges 0.0.0.0/0
```

## 🔌 Passo 3: Conectar à VM

### Via Console Web (SSH Browser)

1. Vá para **Compute Engine** → **VM instances**
2. Clique em **SSH** ao lado da instância

### Via gcloud CLI

```bash
gcloud compute ssh casadf-sistema --zone=us-central1-a
```

### Via SSH tradicional

```bash
ssh -i ~/.ssh/google_compute_engine usuario@IP_EXTERNO
```

## 📦 Passo 4: Instalar Docker e Docker Compose

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker --version
docker-compose --version

# IMPORTANTE: Fazer logout e login novamente para aplicar grupo docker
exit
# Conecte novamente via SSH
```

## 📥 Passo 5: Clonar Repositório

```bash
# Instalar Git (se necessário)
sudo apt install git -y

# Clonar repositório
git clone https://github.com/vml-arquivos/casadf-sistema.git
cd casadf-sistema
```

## ⚙️ Passo 6: Configurar Variáveis de Ambiente

```bash
# Copiar template
cp .env.example .env

# Editar com nano
nano .env

# Ou com vim
vim .env
```

### Variáveis Obrigatórias

```env
# Banco de Dados
DATABASE_URL=mysql://casadf:SENHA_FORTE_AQUI@db:3306/casadf
MYSQL_ROOT_PASSWORD=SENHA_ROOT_FORTE_AQUI
MYSQL_PASSWORD=SENHA_FORTE_AQUI

# JWT Secret (gerar com: openssl rand -base64 32)
JWT_SECRET=sua_chave_jwt_gerada

# Manus OAuth
VITE_APP_ID=seu_app_id
OAUTH_SERVER_URL=https://api.manus.im
VITE_OAUTH_PORTAL_URL=https://auth.manus.im

# Owner
OWNER_OPEN_ID=seu_owner_open_id
OWNER_NAME=CasaDF Imóveis

# Manus Forge API
BUILT_IN_FORGE_API_KEY=sua_chave_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_frontend

# App Info
VITE_APP_TITLE=CasaDF - Sistema Imobiliário
```

### Gerar JWT Secret

```bash
openssl rand -base64 32
```

## 🚀 Passo 7: Executar Deploy

```bash
# Executar script de deploy
./deploy.sh

# Ou manualmente
docker-compose up -d
```

## ✅ Passo 8: Verificar Deploy

```bash
# Ver status dos containers
docker-compose ps

# Ver logs
docker-compose logs -f

# Verificar aplicação
curl http://localhost:3000/health

# Obter IP externo da VM
curl -4 ifconfig.me
```

Acesse: `http://SEU_IP_EXTERNO:3000`

## 🌐 Passo 9: Configurar Nginx (Proxy Reverso)

### Instalar Nginx

```bash
sudo apt install nginx -y
```

### Configurar Site

```bash
sudo nano /etc/nginx/sites-available/casadf
```

Adicione:

```nginx
server {
    listen 80;
    server_name SEU_DOMINIO.com.br;  # ou IP externo

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Ativar Site

```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/casadf /etc/nginx/sites-enabled/

# Remover site padrão
sudo rm /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

Agora acesse: `http://SEU_DOMINIO.com.br` ou `http://SEU_IP_EXTERNO`

## 🔒 Passo 10: Configurar SSL com Let's Encrypt

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obter certificado SSL
sudo certbot --nginx -d SEU_DOMINIO.com.br

# Renovação automática já está configurada
# Testar renovação
sudo certbot renew --dry-run
```

Agora acesse: `https://SEU_DOMINIO.com.br`

## 📊 Comandos Úteis

### Docker

```bash
# Ver logs
docker-compose logs -f

# Reiniciar serviços
docker-compose restart

# Parar serviços
docker-compose down

# Rebuild
docker-compose up -d --build

# Limpar tudo
docker-compose down -v
docker system prune -a
```

### Banco de Dados

```bash
# Backup
docker-compose exec db mysqldump -u casadf -p casadf > backup.sql

# Restaurar
docker-compose exec -T db mysql -u casadf -p casadf < backup.sql

# Acessar MySQL
docker-compose exec db mysql -u casadf -p
```

### Sistema

```bash
# Ver uso de disco
df -h

# Ver uso de memória
free -h

# Ver processos
htop

# Ver logs do sistema
sudo journalctl -xe
```

## 🔄 Atualizar Aplicação

```bash
# Entrar no diretório
cd ~/casadf-sistema

# Pull das atualizações
git pull origin main

# Rebuild e restart
docker-compose up -d --build

# Ver logs
docker-compose logs -f
```

## 🛡️ Segurança

### Checklist de Segurança

- [ ] Alterar senhas padrão do MySQL
- [ ] Gerar JWT_SECRET forte
- [ ] Configurar HTTPS/SSL
- [ ] Configurar firewall (apenas portas necessárias)
- [ ] Desabilitar phpMyAdmin em produção
- [ ] Configurar backup automático
- [ ] Monitorar logs de segurança
- [ ] Atualizar sistema regularmente
- [ ] Usar SSH com chave ao invés de senha
- [ ] Configurar fail2ban

### Configurar Fail2ban

```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 💾 Backup Automático

### Script de Backup

```bash
# Criar script
nano ~/backup-casadf.sh
```

Adicione:

```bash
#!/bin/bash
BACKUP_DIR="/home/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do banco
docker-compose exec -T db mysqldump -u casadf -p$MYSQL_PASSWORD casadf > $BACKUP_DIR/db_$DATE.sql

# Backup dos arquivos
tar -czf $BACKUP_DIR/files_$DATE.tar.gz storage/

# Manter apenas últimos 7 dias
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup concluído: $DATE"
```

### Agendar Backup (Cron)

```bash
# Tornar executável
chmod +x ~/backup-casadf.sh

# Editar crontab
crontab -e

# Adicionar (backup diário às 3h)
0 3 * * * /home/$USER/backup-casadf.sh >> /home/$USER/backup.log 2>&1
```

## 📈 Monitoramento

### Logs em Tempo Real

```bash
# Todos os serviços
docker-compose logs -f

# Apenas app
docker-compose logs -f app

# Apenas banco
docker-compose logs -f db
```

### Verificar Saúde

```bash
# Health check
curl http://localhost:3000/health

# Status dos containers
docker-compose ps

# Uso de recursos
docker stats
```

## 🆘 Troubleshooting

### Container não inicia

```bash
docker-compose logs app
docker-compose config
docker-compose down -v && docker-compose up -d
```

### Erro de conexão com banco

```bash
docker-compose ps db
docker-compose logs db
docker-compose exec app ping db
```

### Porta em uso

```bash
sudo lsof -i :3000
sudo kill -9 PID
```

### Sem espaço em disco

```bash
df -h
docker system prune -a --volumes
```

## 📚 Recursos Adicionais

- [Documentação Google Cloud](https://cloud.google.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)

---

✅ Deploy concluído! Seu sistema CasaDF está rodando no Google Cloud.
