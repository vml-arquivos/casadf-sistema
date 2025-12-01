#!/bin/bash

# ============================================
# Script de Conexão SSH - CasaDF VM
# ============================================

VM_NAME="casadf-sistema-v2"
VM_ZONE="southamerica-east1-b"
VM_IP="34.151.248.227"
VM_USER="ubuntu"

# Cores
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🔌 Conectando à VM CasaDF${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${GREEN}VM: ${VM_NAME}${NC}"
echo -e "${GREEN}Zona: ${VM_ZONE}${NC}"
echo -e "${GREEN}IP: ${VM_IP}${NC}"
echo ""

# Verificar se gcloud está disponível
if command -v gcloud &> /dev/null; then
    echo -e "${GREEN}Conectando via gcloud...${NC}"
    echo ""
    gcloud compute ssh ${VM_USER}@${VM_NAME} --zone=${VM_ZONE}
else
    echo -e "${GREEN}Conectando via SSH direto...${NC}"
    echo ""
    ssh ${VM_USER}@${VM_IP}
fi
