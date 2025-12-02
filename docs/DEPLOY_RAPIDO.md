# 🚀 Guia Rápido de Deploy - CasaDF

Deploy automatizado para Google Cloud VM **casadf-sistema-v2**

## 📋 Informações da VM

- **Nome**: casadf-sistema-v2
- **Zona**: southamerica-east1-b (São Paulo)
- **IP Externo**: 34.151.248.227
- **Tipo**: e2-medium (2 vCPUs, 4 GB RAM)
- **SO**: Ubuntu
- **Disco**: 20 GB SSD

## ⚡ Deploy em 3 Passos

### Opção 1: Deploy Automatizado (Recomendado)

Execute do seu computador local:

```bash
# 1. Configure o arquivo .env
cp .env.example .env
nano .env  # Preencha com valores reais

# 2. Execute o script de deploy
./deploy-to-gcloud.sh
```

Pronto! O script fará tudo automaticamente:
- ✅ Configurar servidor
- ✅ Instalar Docker e Docker Compose
- ✅ Clonar repositório
- ✅ Copiar arquivo .env
- ✅ Executar deploy
- ✅ Verificar status

### Opção 2: Deploy Manual

#### Passo 1: Conectar à VM

```bash
# Via gcloud CLI
gcloud compute ssh ubuntu@casadf-sistema-v2 --zone=southamerica-east1-b

# Ou via script
./connect-vm.sh

# Ou via SSH direto
ssh ubuntu@34.151.248.227
```

#### Passo 2: Configurar VM (primeira vez)

```bash
# Baixar e executar script de setup
curl -fsSL https://raw.githubusercontent.com/vml-arquivos/casadf-sistema/main/setup-vm.sh | bash

# Ou se já clonou o repo
cd ~/casadf-sistema
./setup-vm.sh

# IMPORTANTE: Fazer logout e login novamente
exit
# Conecte novamente
```

#### Passo 3: Configurar Variáveis

```bash
cd ~/casadf-sistema
cp .env.example .env
nano .env  # Preencha com valores reais
```

**Variáveis Obrigatórias:**

```env
# Banco de Dados
MYSQL_ROOT_PASSWORD=SUA_SENHA_ROOT_FORTE
MYSQL_PASSWORD=SUA_SENHA_USUARIO_FORTE

# JWT Secret (gerar com: openssl rand -base64 32)
JWT_SECRET=SUA_CHAVE_JWT_GERADA

# Manus OAuth
VITE_APP_ID=seu_app_id
OWNER_OPEN_ID=seu_owner_open_id
OWNER_NAME=CasaDF Imóveis

# Manus Forge API
BUILT_IN_FORGE_API_KEY=sua_chave_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_frontend
```

#### Passo 4: Executar Deploy

```bash
./deploy.sh
```

## 🌐 Acessar Aplicação

Após o deploy:

- **Aplicação**: http://34.151.248.227:3000
- **phpMyAdmin** (dev): http://34.151.248.227:8080

## 📝 Comandos Úteis

### Conectar à VM

```bash
# Via script
./connect-vm.sh

# Via gcloud
gcloud compute ssh ubuntu@casadf-sistema-v2 --zone=southamerica-east1-b

# Via SSH
ssh ubuntu@34.151.248.227
```

### Gerenciar Aplicação

```bash
# Ver status
cd ~/casadf-sistema
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs de um serviço
docker-compose logs -f app
docker-compose logs -f db

# Reiniciar
docker-compose restart

# Parar
docker-compose down

# Rebuild e reiniciar
docker-compose up -d --build
```

### Atualizar Aplicação

```bash
cd ~/casadf-sistema
git pull origin main
docker-compose up -d --build
```

### Backup do Banco

```bash
# Criar backup
docker-compose exec db mysqldump -u casadf -p casadf > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker-compose exec -T db mysql -u casadf -p casadf < backup_20231201.sql
```

## 🔒 Configurar HTTPS (Opcional)

### 1. Configurar Domínio

Aponte seu domínio para o IP: **34.151.248.227**

### 2. Instalar Nginx

```bash
sudo apt install nginx -y
```

### 3. Configurar Nginx

```bash
sudo nano /etc/nginx/sites-available/casadf
```

Adicione:

```nginx
server {
    listen 80;
    server_name seu-dominio.com.br;

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

Ativar:

```bash
sudo ln -s /etc/nginx/sites-available/casadf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Instalar SSL (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d seu-dominio.com.br
```

Pronto! Acesse via HTTPS: https://seu-dominio.com.br

## 🆘 Troubleshooting

### Container não inicia

```bash
docker-compose logs app
docker-compose down -v
docker-compose up -d
```

### Erro de conexão com banco

```bash
docker-compose logs db
docker-compose restart db
```

### Aplicação não responde

```bash
# Verificar se está rodando
docker-compose ps

# Verificar logs
docker-compose logs -f app

# Reiniciar
docker-compose restart app
```

### Sem espaço em disco

```bash
# Ver uso
df -h

# Limpar Docker
docker system prune -a --volumes
```

### Porta em uso

```bash
# Ver o que está usando a porta
sudo lsof -i :3000

# Matar processo
sudo kill -9 PID
```

## 📊 Monitoramento

### Ver uso de recursos

```bash
# CPU e memória
htop

# Docker stats
docker stats

# Espaço em disco
df -h

# Memória
free -h
```

### Health Check

```bash
# Testar aplicação
curl http://localhost:3000/health

# Testar banco
docker-compose exec db mysqladmin ping -h localhost -u root -p
```

## 🔄 Backup Automático

### Criar script de backup

```bash
nano ~/backup-casadf.sh
```

Adicione:

```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do banco
cd ~/casadf-sistema
docker-compose exec -T db mysqldump -u casadf -p$MYSQL_PASSWORD casadf > $BACKUP_DIR/db_$DATE.sql

# Backup dos arquivos
tar -czf $BACKUP_DIR/files_$DATE.tar.gz storage/

# Manter apenas últimos 7 dias
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup concluído: $DATE"
```

Tornar executável:

```bash
chmod +x ~/backup-casadf.sh
```

### Agendar backup diário

```bash
crontab -e
```

Adicione:

```
0 3 * * * /home/ubuntu/backup-casadf.sh >> /home/ubuntu/backup.log 2>&1
```

## 📞 Suporte

- **Repositório**: https://github.com/vml-arquivos/casadf-sistema
- **Issues**: https://github.com/vml-arquivos/casadf-sistema/issues
- **Documentação Completa**: Ver arquivos .md no repositório

## ✅ Checklist de Deploy

- [ ] VM criada e rodando
- [ ] Firewall configurado (portas 80, 443, 3000)
- [ ] Docker e Docker Compose instalados
- [ ] Repositório clonado
- [ ] Arquivo .env configurado
- [ ] Senhas padrão alteradas
- [ ] JWT_SECRET gerado
- [ ] Deploy executado com sucesso
- [ ] Aplicação acessível via IP
- [ ] Banco de dados funcionando
- [ ] Backup configurado
- [ ] HTTPS configurado (opcional)
- [ ] Domínio apontado (opcional)

---

**VM**: casadf-sistema-v2  
**IP**: 34.151.248.227  
**Zona**: southamerica-east1-b  
**Status**: ✅ Pronto para Deploy
