# 🚀 Deploy CasaDF - Guia Rápido para Hoje

## ⚡ Deploy em 10 Minutos

Este guia vai te ajudar a colocar o sistema CasaDF em produção **hoje mesmo**.

---

## 📋 Pré-requisitos

Você precisa de:
- ✅ Servidor Linux (Ubuntu 22.04 recomendado)
- ✅ Docker e Docker Compose instalados
- ✅ Domínio configurado (opcional, pode usar IP)
- ✅ Credenciais Manus OAuth

---

## 🎯 Opção 1: Deploy Rápido com Docker (RECOMENDADO)

### Passo 1: Fazer Upload do Sistema

```bash
# No seu computador local, extraia o ZIP e faça upload para o servidor
scp -r casadf-sistema/ usuario@seu-servidor:/home/usuario/
```

Ou clone do GitHub:

```bash
ssh usuario@seu-servidor
git clone https://github.com/vml-arquivos/casadf-sistema.git
cd casadf-sistema
```

### Passo 2: Configurar Variáveis de Ambiente

```bash
cd casadf-sistema
cp .env.example .env
nano .env
```

**Configuração mínima necessária:**

```env
# PostgreSQL (deixe os padrões ou customize)
DATABASE_URL=postgres://casadf_user:SuaSenhaSegura123@db:5432/casadf_db
PGUSER=casadf_user
PGPASSWORD=SuaSenhaSegura123
PGDATABASE=casadf_db

# Aplicação
NODE_ENV=production
PORT=3000
SITE_URL=http://seu-dominio.com  # ou http://seu-ip:3000

# JWT (GERE UMA CHAVE SEGURA!)
JWT_SECRET=$(openssl rand -base64 32)

# Manus OAuth (OBRIGATÓRIO)
VITE_APP_ID=seu-app-id-aqui
OAUTH_SERVER_URL=https://oauth.manus.im
VITE_OAUTH_PORTAL_URL=https://oauth.manus.im
OWNER_OPEN_ID=seu-open-id-aqui
OWNER_NAME=Seu Nome
```

**Gerar JWT_SECRET seguro:**

```bash
openssl rand -base64 32
# Copie o resultado e cole no .env
```

### Passo 3: Iniciar o Sistema

```bash
# Dar permissão de execução aos scripts
chmod +x deploy.sh build.sh

# Executar deploy
./deploy.sh
```

Ou manualmente:

```bash
# Subir banco de dados
docker compose up -d db

# Aguardar banco inicializar (30 segundos)
sleep 30

# Verificar se banco está pronto
docker compose logs db

# Subir aplicação
docker compose up -d --build app

# Verificar logs
docker compose logs -f app
```

### Passo 4: Aplicar Migrations

```bash
# Entrar no container da aplicação
docker compose exec app sh

# Dentro do container
pnpm db:push

# Sair
exit
```

### Passo 5: Verificar Funcionamento

```bash
# Verificar saúde do sistema
curl http://localhost:3000/health

# Deve retornar: {"status":"ok","timestamp":"..."}
```

### Passo 6: Acessar o Sistema

Abra no navegador:
- **Local**: http://localhost:3000
- **Servidor**: http://seu-ip:3000
- **Domínio**: http://seu-dominio.com:3000

---

## 🎯 Opção 2: Deploy Sem Docker

### Passo 1: Instalar Node.js e pnpm

```bash
# Instalar Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar pnpm
npm install -g pnpm
```

### Passo 2: Instalar PostgreSQL

```bash
# Instalar PostgreSQL 16
sudo apt install -y postgresql-16 postgresql-contrib

# Criar banco e usuário
sudo -u postgres psql
```

No PostgreSQL:

```sql
CREATE DATABASE casadf_db;
CREATE USER casadf_user WITH PASSWORD 'SuaSenhaSegura123';
GRANT ALL PRIVILEGES ON DATABASE casadf_db TO casadf_user;
\q
```

### Passo 3: Configurar e Iniciar

```bash
cd casadf-sistema

# Instalar dependências
pnpm install

# Configurar .env
cp .env.example .env
nano .env
# Ajuste DATABASE_URL para: postgres://casadf_user:SuaSenhaSegura123@localhost:5432/casadf_db

# Aplicar migrations
pnpm db:push

# Build
pnpm build

# Iniciar
pnpm start
```

---

## 🌐 Configurar Nginx (Proxy Reverso)

### Instalar Nginx

```bash
sudo apt update
sudo apt install -y nginx
```

### Criar Configuração

```bash
sudo nano /etc/nginx/sites-available/casadf
```

Cole:

```nginx
server {
    listen 80;
    server_name seu-dominio.com;  # ou seu IP

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

### Ativar e Reiniciar

```bash
sudo ln -s /etc/nginx/sites-available/casadf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

Agora acesse: http://seu-dominio.com (sem porta 3000)

---

## 🔒 Configurar SSL/HTTPS (Certbot)

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com

# Renovação automática já está configurada
```

Acesse: https://seu-dominio.com

---

## 📊 Comandos Úteis

### Verificar Status

```bash
# Status dos containers
docker compose ps

# Logs em tempo real
docker compose logs -f

# Logs apenas da aplicação
docker compose logs -f app

# Logs apenas do banco
docker compose logs -f db
```

### Reiniciar Sistema

```bash
# Reiniciar apenas a aplicação
docker compose restart app

# Reiniciar tudo
docker compose restart

# Rebuild completo
docker compose down
docker compose up -d --build
```

### Backup do Banco

```bash
# Backup
docker compose exec db pg_dump -U casadf_user casadf_db > backup_$(date +%Y%m%d).sql

# Restaurar
docker compose exec -T db psql -U casadf_user casadf_db < backup_20251202.sql
```

### Atualizar Sistema

```bash
# Puxar atualizações do GitHub
git pull origin main

# Rebuild e reiniciar
docker compose up -d --build
```

---

## 🐛 Troubleshooting

### Erro: "Port 3000 already in use"

```bash
# Verificar o que está usando a porta
sudo lsof -i :3000

# Matar processo
sudo kill -9 PID

# Ou mudar porta no .env
PORT=3001
```

### Erro: "Database connection failed"

```bash
# Verificar se banco está rodando
docker compose ps db

# Ver logs do banco
docker compose logs db

# Recriar banco
docker compose down -v
docker compose up -d db
sleep 30
docker compose exec app pnpm db:push
```

### Erro: "Permission denied"

```bash
# Dar permissões corretas
sudo chown -R $USER:$USER casadf-sistema
chmod +x deploy.sh build.sh
```

### Sistema não carrega no navegador

```bash
# Verificar se aplicação está rodando
curl http://localhost:3000/health

# Verificar logs
docker compose logs app

# Verificar firewall
sudo ufw status
sudo ufw allow 3000
```

---

## ✅ Checklist de Deploy

Antes de considerar o deploy completo, verifique:

- [ ] Banco de dados PostgreSQL rodando
- [ ] Migrations aplicadas (`pnpm db:push`)
- [ ] Aplicação iniciada e rodando
- [ ] Endpoint `/health` retornando OK
- [ ] Consegue acessar no navegador
- [ ] Login OAuth funcionando
- [ ] Nginx configurado (se aplicável)
- [ ] SSL/HTTPS configurado (se aplicável)
- [ ] Backup configurado
- [ ] Variáveis de ambiente de produção configuradas
- [ ] JWT_SECRET gerado e seguro
- [ ] Firewall configurado

---

## 🎯 Próximos Passos Após Deploy

1. **Criar primeiro usuário admin**
   - Acesse o sistema
   - Faça login com Manus OAuth
   - Configure seu OWNER_OPEN_ID no .env

2. **Popular banco com dados iniciais**
   ```bash
   docker compose exec app node seed.mjs
   ```

3. **Configurar backup automático**
   ```bash
   # Adicionar ao crontab
   crontab -e
   
   # Backup diário às 3h da manhã
   0 3 * * * cd /home/usuario/casadf-sistema && docker compose exec db pg_dump -U casadf_user casadf_db > /backups/casadf_$(date +\%Y\%m\%d).sql
   ```

4. **Monitoramento**
   - Configure alertas de uptime
   - Monitore logs regularmente
   - Configure analytics

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs: `docker compose logs -f`
2. Consulte a documentação completa em `DEPLOY.md`
3. Verifique variáveis de ambiente no `.env`
4. Abra uma issue no GitHub

---

## 🎉 Pronto!

Se tudo funcionou, você agora tem o sistema CasaDF rodando em produção!

**Acesse**: http://seu-dominio.com  
**Health Check**: http://seu-dominio.com/health  
**Admin**: Faça login com Manus OAuth

**Boa sorte com seu sistema imobiliário!** 🏠🚀
