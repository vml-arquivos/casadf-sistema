#!/bin/bash

echo "🔧 Corrigindo TODAS as referências ao sistema antigo..."

# Definir variáveis
OLD_NAME="Corretor das Mansões"
OLD_NAME2="corretordasmansoes"
OLD_PERSON1="Hernani Muniz"
OLD_PERSON2="Hernani"
OLD_PERSON3="Ernani Nunes"
OLD_PERSON4="Ernani"
OLD_EMAIL="ernanisimiao@hotmail.com"
OLD_EMAIL2="ernaniSimiao@hotmail.com"
OLD_PHOTO="ernani-nunes-photo.jpg"

NEW_NAME="CasaDF"
NEW_SYSTEM="casadf"
NEW_EMAIL="contato@casadf.com.br"
NEW_PHOTO="casadf-team.jpg"

echo "📝 Corrigindo arquivos HTML..."
find . -name "*.html" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -exec sed -i \
  -e "s/$OLD_NAME/$NEW_NAME/g" \
  -e "s/$OLD_NAME2/$NEW_SYSTEM/g" \
  -e "s/$OLD_PERSON1/$NEW_NAME/g" \
  -e "s/$OLD_PERSON3/$NEW_NAME/g" \
  {} \;

echo "📝 Corrigindo arquivos TypeScript/TSX..."
find . \( -name "*.ts" -o -name "*.tsx" \) -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -exec sed -i \
  -e "s/$OLD_PERSON1/$NEW_NAME/g" \
  -e "s/$OLD_PERSON2/$NEW_NAME/g" \
  -e "s/$OLD_PERSON3/$NEW_NAME/g" \
  -e "s/$OLD_PERSON4/$NEW_NAME/g" \
  -e "s/$OLD_EMAIL/$NEW_EMAIL/g" \
  -e "s/$OLD_EMAIL2/$NEW_EMAIL/g" \
  -e "s/$OLD_PHOTO/$NEW_PHOTO/g" \
  -e "s/mansões/imóveis/g" \
  -e "s/Mansões/Imóveis/g" \
  -e "s/ERNANI NUNES/CASADF/g" \
  -e "s/Sobre o Corretor/Sobre a CasaDF/g" \
  -e "s/Corretor/Consultoria/g" \
  {} \;

echo "📝 Corrigindo arquivos Markdown..."
find . -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -exec sed -i \
  -e "s/$OLD_NAME/$NEW_NAME/g" \
  -e "s/$OLD_NAME2/$NEW_SYSTEM/g" \
  -e "s/$OLD_PERSON1/$NEW_NAME/g" \
  -e "s/$OLD_PERSON3/$NEW_NAME/g" \
  -e "s/$OLD_EMAIL/$NEW_EMAIL/g" \
  -e "s/$OLD_EMAIL2/$NEW_EMAIL/g" \
  {} \;

echo "📝 Corrigindo comentários específicos..."
sed -i 's/Informações do corretor/Informações do imóvel/g' drizzle/schema.ts

echo "✅ Todas as referências corrigidas!"
echo ""
echo "📊 Resumo:"
echo "  - Corretor das Mansões → CasaDF"
echo "  - Hernani/Ernani → CasaDF"
echo "  - ernanisimiao@hotmail.com → contato@casadf.com.br"
echo "  - ernani-nunes-photo.jpg → casadf-team.jpg"
