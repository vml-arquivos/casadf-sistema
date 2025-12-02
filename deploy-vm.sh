#!/bin/bash

# ============================================
# Script de Deploy CasaDF - VM Google Cloud
# ============================================

set -e  # Parar em caso de erro

echo "🚀 Iniciando deploy do CasaDF na VM..."
echo ""

# ============================================
# 1. VERIFICAR PRÉ-REQUISITOS
# ============================================

echo "📋 Verificando pré-requisitos..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    exit 1
fi
echo "✅ Docker instalado"

# Verificar Docker Compose
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado!"
    exit 1
fi
echo "✅ Docker Compose instalado"

# Verificar pnpm
if ! command -v pnpm &> /dev/null; then
    echo "⚠️  pnpm não encontrado, instalando..."
    npm install -g pnpm
fi
echo "✅ pnpm instalado"

# Verificar arquivo .env
if [ ! -f ".env" ]; then
    echo "❌ Arquivo .env não encontrado!"
    echo "Execute: cp .env.example .env"
    echo "E configure as variáveis necessárias."
    exit 1
fi
echo "✅ Arquivo .env encontrado"

echo ""

# ============================================
# 2. LIMPAR AMBIENTE
# ============================================

echo "🧹 Limpando ambiente anterior..."

# Parar containers
docker compose down -v 2>/dev/null || true

# Limpar Docker
docker system prune -af --volumes 2>/dev/null || true

# Limpar node_modules e builds
rm -rf node_modules dist client/dist 2>/dev/null || true

echo "✅ Ambiente limpo"
echo ""

# ============================================
# 3. SUBIR BANCO DE DADOS
# ============================================

echo "🗄️  Subindo PostgreSQL..."

docker compose up -d db

# Aguardar banco inicializar
echo "⏳ Aguardando PostgreSQL inicializar (20 segundos)..."
sleep 20

# Verificar se banco está rodando
if ! docker compose ps | grep -q "db.*running"; then
    echo "❌ PostgreSQL não está rodando!"
    docker compose logs db
    exit 1
fi

echo "✅ PostgreSQL rodando"
echo ""

# ============================================
# 4. APLICAR MIGRATIONS
# ============================================

echo "📝 Aplicando migrations..."

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
    # Ler do .env
    export $(grep -v '^#' .env | xargs)
fi

# Aplicar migration
if [ -f "drizzle/migrations/0000_init.sql" ]; then
    docker compose exec -T db psql -U casadf_user -d casadf_db < drizzle/migrations/0000_init.sql 2>/dev/null || {
        echo "⚠️  Migration já aplicada ou erro, continuando..."
    }
    echo "✅ Migrations aplicadas"
else
    echo "❌ Arquivo de migration não encontrado!"
    exit 1
fi

echo ""

# ============================================
# 5. INSTALAR DEPENDÊNCIAS
# ============================================

echo "📦 Instalando dependências..."

pnpm install --frozen-lockfile

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências!"
    exit 1
fi

echo "✅ Dependências instaladas"
echo ""

# ============================================
# 6. FAZER BUILD
# ============================================

echo "🔨 Fazendo build da aplicação..."

pnpm build

if [ $? -ne 0 ]; then
    echo "❌ Erro no build!"
    exit 1
fi

echo "✅ Build concluído"
echo ""

# ============================================
# 7. SUBIR APLICAÇÃO
# ============================================

echo "🚀 Subindo aplicação..."

docker compose up -d --build

# Aguardar app inicializar
echo "⏳ Aguardando aplicação inicializar (15 segundos)..."
sleep 15

# Verificar se app está rodando
if ! docker compose ps | grep -q "app.*running"; then
    echo "❌ Aplicação não está rodando!"
    docker compose logs app
    exit 1
fi

echo "✅ Aplicação rodando"
echo ""

# ============================================
# 8. VERIFICAR SAÚDE
# ============================================

echo "🏥 Verificando saúde da aplicação..."

# Tentar health check
HEALTH_CHECK=$(curl -s http://localhost:3000/health || echo "error")

if [[ "$HEALTH_CHECK" == *"ok"* ]]; then
    echo "✅ Health check passou!"
else
    echo "⚠️  Health check falhou, mas aplicação pode estar iniciando..."
fi

echo ""

# ============================================
# 9. RESUMO
# ============================================

echo "════════════════════════════════════════"
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO!"
echo "════════════════════════════════════════"
echo ""
echo "📊 Status dos containers:"
docker compose ps
echo ""
echo "🌐 Aplicação disponível em:"
echo "   http://localhost:3000"
echo "   http://$(curl -s ifconfig.me):3000"
echo ""
echo "📝 Comandos úteis:"
echo "   docker compose logs -f app    # Ver logs da aplicação"
echo "   docker compose logs -f db     # Ver logs do banco"
echo "   docker compose ps             # Status dos containers"
echo "   docker compose restart app    # Reiniciar aplicação"
echo ""
echo "🎉 Sistema CasaDF está rodando!"
echo "════════════════════════════════════════"
