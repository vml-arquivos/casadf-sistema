# 🚀 DEPLOY CASADF - EXECUTAR AGORA

## ⚡ Comandos para Copiar e Colar na VM

### 1️⃣ Conectar na VM

```bash
ssh usuario@34.39.247.210
```

### 2️⃣ Clonar Repositório (se ainda não tem)

```bash
cd ~
git clone https://github.com/vml-arquivos/casadf-sistema.git
cd casadf-sistema
```

**OU atualizar se já tem**:

```bash
cd ~/casadf-sistema
git pull origin main
```

### 3️⃣ Gerar JWT Secret

```bash
openssl rand -base64 64
```

**Copie o resultado!** Você vai precisar no próximo passo.

### 4️⃣ Criar arquivo .env

```bash
cat > .env << 'EOF'
# ============================================
# CONFIGURAÇÕES DO BANCO DE DADOS (PostgreSQL)
# ============================================
DATABASE_URL=postgres://casadf_user:CasaDF_User_2024_Secure!@#$@db:5432/casadf_db
PGUSER=casadf_user
PGPASSWORD=CasaDF_User_2024_Secure!@#$
PGDATABASE=casadf_db
PGHOST=db
PGPORT=5432

# ============================================
# CONFIGURAÇÕES DA APLICAÇÃO
# ============================================
NODE_ENV=production
PORT=3000
SITE_URL=http://34.39.247.210:3000
VITE_API_URL=http://34.39.247.210:3000/api

# ============================================
# AUTENTICAÇÃO E SEGURANÇA
# ============================================
JWT_SECRET=COLE_AQUI_O_JWT_SECRET_QUE_VOCE_GEROU_NO_PASSO_3

# ============================================
# OAUTH MANUS (Sistema de Autenticação)
# ============================================
VITE_APP_ID=seu-manus-app-id-aqui
OAUTH_SERVER_URL=https://oauth.manus.im
VITE_OAUTH_PORTAL_URL=https://oauth.manus.im

# ============================================
# INFORMAÇÕES DO PROPRIETÁRIO
# ============================================
OWNER_OPEN_ID=seu-owner-open-id-aqui
OWNER_NAME=CasaDF

# ============================================
# MANUS FORGE API
# ============================================
BUILT_IN_FORGE_API_URL=https://api.manus.im
BUILT_IN_FORGE_API_KEY=sua-backend-forge-api-key
VITE_FRONTEND_FORGE_API_URL=https://api.manus.im
VITE_FRONTEND_FORGE_API_KEY=sua-frontend-forge-api-key

# ============================================
# INFORMAÇÕES DO SITE
# ============================================
VITE_APP_TITLE=CasaDF - Imóveis em Brasília
VITE_APP_LOGO=/logo.png

# ============================================
# OPCIONAIS (deixar vazio por enquanto)
# ============================================
VITE_ANALYTICS_ENDPOINT=
VITE_ANALYTICS_WEBSITE_ID=
GOOGLE_GEMINI_API_KEY=
MANUS_API_KEY=
N8N_WEBHOOK_URL=
APP_PORT=3000
PGADMIN_PORT=8080
PGADMIN_EMAIL=admin@casadf.local
PGADMIN_PASSWORD=admin
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
AWS_S3_BUCKET=
AWS_S3_ENDPOINT=
CHATWOOT_URL=
CHATWOOT_API_KEY=
GOOGLE_ANALYTICS_ID=
FACEBOOK_PIXEL_ID=
EOF
```

### 5️⃣ Editar .env e Substituir Valores

```bash
nano .env
```

**Substitua**:
- `COLE_AQUI_O_JWT_SECRET_QUE_VOCE_GEROU_NO_PASSO_3` → Cole o JWT Secret do passo 3
- `seu-manus-app-id-aqui` → Seu App ID do Manus
- `seu-owner-open-id-aqui` → Seu Owner Open ID do Manus
- `sua-backend-forge-api-key` → Sua API Key do Manus (backend)
- `sua-frontend-forge-api-key` → Sua API Key do Manus (frontend)

**Salvar**: `Ctrl+O`, `Enter`, `Ctrl+X`

### 6️⃣ EXECUTAR DEPLOY

```bash
./deploy-vm.sh
```

**Aguarde 3-5 minutos...**

### 7️⃣ Verificar

```bash
# Status dos containers
docker compose ps

# Health check
curl http://localhost:3000/health

# Ver logs
docker compose logs -f app
```

### 8️⃣ Acessar

Abra no navegador:
- **http://34.39.247.210:3000** - Site
- **http://34.39.247.210:3000/admin** - Admin

---

## ✅ Checklist

- [ ] Conectado na VM
- [ ] Repositório clonado/atualizado
- [ ] JWT Secret gerado
- [ ] Arquivo .env criado e editado
- [ ] Deploy executado (`./deploy-vm.sh`)
- [ ] Containers rodando (`docker compose ps`)
- [ ] Health check OK (`curl http://localhost:3000/health`)
- [ ] Site acessível no navegador

---

## 🐛 Se der erro

```bash
# Ver logs detalhados
docker compose logs app

# Reiniciar
docker compose restart

# Rebuild completo
docker compose down -v
./deploy-vm.sh
```

---

## 📞 Comandos Úteis

```bash
# Ver logs em tempo real
docker compose logs -f app

# Status
docker compose ps

# Reiniciar app
docker compose restart app

# Parar tudo
docker compose down

# Entrar no container
docker compose exec app sh

# Entrar no PostgreSQL
docker compose exec db psql -U casadf_user -d casadf_db
```

---

**Tempo estimado**: 3-5 minutos  
**Pronto para executar**: SIM ✅
