#!/bin/bash

# ============================================
# Script de Configuração Inicial da VM
# CasaDF Sistema - Google Cloud
# ============================================
#
# Execute este script DENTRO da VM após conectar via SSH
# 
# Como usar:
# 1. Conecte na VM: gcloud compute ssh ubuntu@casadf-sistema-v2 --zone=southamerica-east1-b
# 2. Execute: bash setup-vm.sh
#
# ============================================

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🏠 CasaDF - Configuração Inicial da VM${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Atualizar sistema
echo -e "${BLUE}📦 Atualizando sistema...${NC}"
sudo apt update
sudo apt upgrade -y
echo -e "${GREEN}✅ Sistema atualizado${NC}"
echo ""

# Instalar Docker
echo -e "${BLUE}🐳 Instalando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker instalado${NC}"
else
    echo -e "${YELLOW}⚠️  Docker já está instalado${NC}"
fi
echo ""

# Instalar Docker Compose
echo -e "${BLUE}🐳 Instalando Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose instalado${NC}"
else
    echo -e "${YELLOW}⚠️  Docker Compose já está instalado${NC}"
fi
echo ""

# Instalar Git
echo -e "${BLUE}📦 Instalando Git...${NC}"
if ! command -v git &> /dev/null; then
    sudo apt install git -y
    echo -e "${GREEN}✅ Git instalado${NC}"
else
    echo -e "${YELLOW}⚠️  Git já está instalado${NC}"
fi
echo ""

# Instalar utilitários
echo -e "${BLUE}📦 Instalando utilitários...${NC}"
sudo apt install -y curl wget nano vim htop net-tools
echo -e "${GREEN}✅ Utilitários instalados${NC}"
echo ""

# Configurar firewall (ufw)
echo -e "${BLUE}🔒 Configurando firewall...${NC}"
sudo ufw --force enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3000/tcp  # Aplicação
sudo ufw allow 8080/tcp  # phpMyAdmin (dev)
echo -e "${GREEN}✅ Firewall configurado${NC}"
echo ""

# Clonar repositório
echo -e "${BLUE}📥 Clonando repositório...${NC}"
if [ -d ~/casadf-sistema ]; then
    echo -e "${YELLOW}⚠️  Diretório já existe. Atualizando...${NC}"
    cd ~/casadf-sistema
    git pull origin main
else
    git clone https://github.com/vml-arquivos/casadf-sistema.git
    cd ~/casadf-sistema
fi
echo -e "${GREEN}✅ Repositório clonado${NC}"
echo ""

# Verificar instalações
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}📊 Versões Instaladas${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
docker --version
docker-compose --version
git --version
echo ""

# Informações importantes
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}✅ Configuração Inicial Concluída!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo -e "1. ${RED}Faça logout e login novamente${NC} para aplicar grupo docker"
echo -e "2. Configure o arquivo ${BLUE}.env${NC} em ~/casadf-sistema/"
echo -e "3. Execute ${BLUE}./deploy.sh${NC} para fazer deploy"
echo ""
echo -e "${GREEN}Próximos passos:${NC}"
echo -e "  ${YELLOW}exit${NC}                           # Sair da VM"
echo -e "  ${YELLOW}gcloud compute ssh ...${NC}         # Conectar novamente"
echo -e "  ${YELLOW}cd ~/casadf-sistema${NC}            # Entrar no diretório"
echo -e "  ${YELLOW}nano .env${NC}                      # Configurar variáveis"
echo -e "  ${YELLOW}./deploy.sh${NC}                    # Executar deploy"
echo ""
echo -e "${BLUE}============================================${NC}"
