#!/bin/bash

echo "🧹 Limpando arquivos temporários e builds..."

# Remover node_modules
if [ -d "node_modules" ]; then
    echo "  Removendo node_modules..."
    rm -rf node_modules
fi

# Remover builds
if [ -d "dist" ]; then
    echo "  Removendo dist..."
    rm -rf dist
fi

if [ -d "build" ]; then
    echo "  Removendo build..."
    rm -rf build
fi

# Remover arquivos Drizzle gerados
if [ -d "drizzle/meta" ]; then
    echo "  Removendo drizzle/meta..."
    rm -rf drizzle/meta
fi

if [ -f "drizzle/schema.js" ]; then
    echo "  Removendo drizzle/schema.js..."
    rm -f drizzle/schema.js
fi

# Remover migrations SQL antigas
echo "  Removendo migrations SQL antigas..."
rm -f drizzle/*.sql

# Remover logs
echo "  Removendo logs..."
rm -f *.log
rm -rf logs/

# Remover cache
if [ -d ".cache" ]; then
    echo "  Removendo .cache..."
    rm -rf .cache
fi

echo "✅ Limpeza concluída!"
echo ""
echo "Para reinstalar dependências:"
echo "  pnpm install"
echo ""
echo "Para gerar migrations PostgreSQL:"
echo "  pnpm db:generate"
