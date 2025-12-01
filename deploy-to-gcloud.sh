#!/bin/bash

# ============================================
# Script de Deploy Automatizado - CasaDF
# Google Cloud VM: casadf-sistema-v2
# ============================================

set -e  # Parar em caso de erro

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações da VM
VM_NAME="casadf-sistema-v2"
VM_ZONE="southamerica-east1-b"
VM_IP="34.151.248.227"
VM_USER="ubuntu"  # Ajuste se necessário

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🏠 CasaDF - Deploy Automatizado${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${GREEN}VM: ${VM_NAME}${NC}"
echo -e "${GREEN}Zona: ${VM_ZONE}${NC}"
echo -e "${GREEN}IP: ${VM_IP}${NC}"
echo ""

# Verificar se gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo -e "${YELLOW}⚠️  gcloud CLI não encontrado. Tentando SSH direto...${NC}"
    USE_GCLOUD=false
else
    echo -e "${GREEN}✅ gcloud CLI encontrado${NC}"
    USE_GCLOUD=true
fi

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    echo -e "${RED}❌ Arquivo .env não encontrado!${NC}"
    echo -e "${YELLOW}Por favor, crie o arquivo .env com as variáveis necessárias${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Arquivo .env encontrado${NC}"
echo ""

# Criar script de setup remoto
echo -e "${BLUE}📝 Criando script de setup remoto...${NC}"

cat > /tmp/casadf-remote-setup.sh << 'REMOTE_SCRIPT'
#!/bin/bash

set -e

echo "============================================"
echo "🚀 Iniciando configuração do servidor..."
echo "============================================"
echo ""

# Atualizar sistema
echo "📦 Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar Docker se não estiver instalado
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker instalado"
else
    echo "✅ Docker já está instalado"
fi

# Instalar Docker Compose se não estiver instalado
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose instalado"
else
    echo "✅ Docker Compose já está instalado"
fi

# Instalar Git se não estiver instalado
if ! command -v git &> /dev/null; then
    echo "📦 Instalando Git..."
    sudo apt install git -y
    echo "✅ Git instalado"
else
    echo "✅ Git já está instalado"
fi

# Verificar versões
echo ""
echo "📊 Versões instaladas:"
docker --version
docker-compose --version
git --version

echo ""
echo "✅ Configuração do servidor concluída!"
REMOTE_SCRIPT

chmod +x /tmp/casadf-remote-setup.sh

# Função para executar comandos na VM
execute_remote() {
    if [ "$USE_GCLOUD" = true ]; then
        gcloud compute ssh ${VM_USER}@${VM_NAME} --zone=${VM_ZONE} --command="$1"
    else
        ssh ${VM_USER}@${VM_IP} "$1"
    fi
}

# Função para copiar arquivos para VM
copy_to_vm() {
    if [ "$USE_GCLOUD" = true ]; then
        gcloud compute scp "$1" ${VM_USER}@${VM_NAME}:"$2" --zone=${VM_ZONE}
    else
        scp "$1" ${VM_USER}@${VM_IP}:"$2"
    fi
}

# Passo 1: Copiar e executar script de setup
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Passo 1: Configurar servidor${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "${YELLOW}Copiando script de setup...${NC}"
copy_to_vm /tmp/casadf-remote-setup.sh /tmp/casadf-remote-setup.sh

echo -e "${YELLOW}Executando script de setup...${NC}"
execute_remote "bash /tmp/casadf-remote-setup.sh"

echo -e "${GREEN}✅ Servidor configurado${NC}"
echo ""

# Passo 2: Clonar ou atualizar repositório
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Passo 2: Clonar/Atualizar repositório${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

execute_remote "
    if [ -d ~/casadf-sistema ]; then
        echo '📥 Atualizando repositório existente...'
        cd ~/casadf-sistema
        git pull origin main
    else
        echo '📥 Clonando repositório...'
        git clone https://github.com/vml-arquivos/casadf-sistema.git
    fi
"

echo -e "${GREEN}✅ Repositório atualizado${NC}"
echo ""

# Passo 3: Copiar arquivo .env
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Passo 3: Configurar variáveis de ambiente${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "${YELLOW}Copiando arquivo .env...${NC}"
copy_to_vm .env /tmp/.env
execute_remote "mv /tmp/.env ~/casadf-sistema/.env"

echo -e "${GREEN}✅ Arquivo .env configurado${NC}"
echo ""

# Passo 4: Executar deploy
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Passo 4: Executar deploy${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

execute_remote "
    cd ~/casadf-sistema
    chmod +x deploy.sh
    ./deploy.sh
"

echo ""
echo -e "${GREEN}✅ Deploy executado${NC}"
echo ""

# Passo 5: Verificar status
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Passo 5: Verificar status${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

execute_remote "cd ~/casadf-sistema && docker-compose ps"

echo ""

# Passo 6: Testar aplicação
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Passo 6: Testar aplicação${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "${YELLOW}Testando health check...${NC}"
if execute_remote "curl -f http://localhost:3000/health" &> /dev/null; then
    echo -e "${GREEN}✅ Aplicação está respondendo!${NC}"
else
    echo -e "${YELLOW}⚠️  Aplicação ainda está iniciando...${NC}"
fi

# Informações finais
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}🎉 Deploy Concluído!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${GREEN}📍 URLs de Acesso:${NC}"
echo -e "  🌐 Aplicação: ${BLUE}http://${VM_IP}:3000${NC}"
echo -e "  🗄️  phpMyAdmin: ${BLUE}http://${VM_IP}:8080${NC} (dev)"
echo ""
echo -e "${GREEN}📝 Comandos úteis:${NC}"
echo ""
if [ "$USE_GCLOUD" = true ]; then
    echo -e "  Conectar via SSH:"
    echo -e "  ${YELLOW}gcloud compute ssh ${VM_USER}@${VM_NAME} --zone=${VM_ZONE}${NC}"
else
    echo -e "  Conectar via SSH:"
    echo -e "  ${YELLOW}ssh ${VM_USER}@${VM_IP}${NC}"
fi
echo ""
echo -e "  Ver logs:"
echo -e "  ${YELLOW}cd ~/casadf-sistema && docker-compose logs -f${NC}"
echo ""
echo -e "  Reiniciar:"
echo -e "  ${YELLOW}cd ~/casadf-sistema && docker-compose restart${NC}"
echo ""
echo -e "  Parar:"
echo -e "  ${YELLOW}cd ~/casadf-sistema && docker-compose down${NC}"
echo ""
echo -e "${BLUE}============================================${NC}"
echo ""

# Limpar arquivo temporário
rm -f /tmp/casadf-remote-setup.sh

echo -e "${GREEN}✅ Script concluído com sucesso!${NC}"
echo ""
