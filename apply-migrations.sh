#!/bin/bash

echo "🗄️  Aplicando migrations do PostgreSQL..."

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Erro: DATABASE_URL não está definida!"
    echo "Configure a variável de ambiente DATABASE_URL antes de executar este script."
    exit 1
fi

# Aplicar migration
echo "📝 Aplicando migration 0000_init.sql..."
psql "$DATABASE_URL" -f drizzle/migrations/0000_init.sql

if [ $? -eq 0 ]; then
    echo "✅ Migrations aplicadas com sucesso!"
    echo ""
    echo "📊 Verificando tabelas criadas..."
    psql "$DATABASE_URL" -c "\dt"
else
    echo "❌ Erro ao aplicar migrations!"
    exit 1
fi
