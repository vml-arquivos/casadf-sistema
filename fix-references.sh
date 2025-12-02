#!/bin/bash

echo "🔧 Corrigindo referências ao sistema antigo..."

# Header.tsx
sed -i 's/Ernani Nunes - O Corretor das Mansões/CasaDF - Imóveis em Brasília/g' client/src/components/Header.tsx
sed -i 's/logo-ernani-nunes\.jpg/logo-casadf.png/g' client/src/components/Header.tsx

# About.tsx
sed -i 's/Hernani Muniz/CasaDF/g' client/src/pages/About.tsx
sed -i 's/Hernani/CasaDF/g' client/src/pages/About.tsx
sed -i 's/Corretor de Imóveis de Luxo/Consultoria Imobiliária/g' client/src/pages/About.tsx

# Home.tsx
sed -i 's/Ernani Nunes - O Corretor das Mansões/CasaDF - Imóveis em Brasília/g' client/src/pages/Home.tsx

echo "✅ Referências corrigidas!"
