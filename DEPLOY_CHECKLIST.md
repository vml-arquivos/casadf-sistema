# ✅ Checklist de Deploy - CasaDF Sistema

Este documento contém o checklist completo para validar que o sistema está pronto para deploy em produção.

## 📦 Arquivos e Configurações

### Arquivos Essenciais

- [x] `.env.example` - Template de variáveis de ambiente
- [x] `docker-compose.yml` - Configuração Docker Compose
- [x] `Dockerfile` - Build da aplicação
- [x] `deploy.sh` - Script automatizado de deploy
- [x] `build.sh` - Script de build
- [x] `.gitignore` - Arquivos ignorados pelo Git
- [x] `.dockerignore` - Arquivos ignorados pelo Docker

### Documentação

- [x] `README.md` - Documentação principal
- [x] `DOCKER_DEPLOY.md` - Guia de deploy com Docker
- [x] `GOOGLE_CLOUD_DEPLOY.md` - Guia específico para Google Cloud
- [x] `ENV_VARIABLES.md` - Documentação de variáveis
- [x] `DEPLOY.md` - Guia geral de deploy
- [x] `API_DOCUMENTATION.md` - Documentação da API
- [x] `PROJECT_STRUCTURE.md` - Estrutura do projeto

### Scripts SQL

- [x] `sql-scripts/00-init-database.sql` - Script de inicialização consolidado
- [x] `drizzle/*.sql` - Migrations individuais do Drizzle
- [x] `drizzle/schema.ts` - Schema do banco de dados

## 🐳 Configuração Docker

### docker-compose.yml

- [x] Serviço `db` (MySQL 8.0) configurado
- [x] Serviço `app` (Aplicação) configurado
- [x] Serviço `phpmyadmin` (Desenvolvimento) configurado
- [x] Health checks configurados
- [x] Networks configuradas (`casadf-network`)
- [x] Volumes configurados (`mysql_data`)
- [x] Variáveis de ambiente mapeadas
- [x] Portas expostas corretamente

### Dockerfile

- [x] Multi-stage build implementado
- [x] Build do frontend (client)
- [x] Build do backend (server)
- [x] Dependências de produção instaladas
- [x] Usuário não-root configurado
- [x] Health check implementado
- [x] Porta 3000 exposta

## 🔐 Variáveis de Ambiente

### Banco de Dados

- [ ] `DATABASE_URL` - URL de conexão MySQL
- [ ] `MYSQL_ROOT_PASSWORD` - Senha root (alterar padrão!)
- [ ] `MYSQL_DATABASE` - Nome do banco (casadf)
- [ ] `MYSQL_USER` - Usuário do banco (casadf)
- [ ] `MYSQL_PASSWORD` - Senha do usuário (alterar padrão!)
- [ ] `MYSQL_PORT` - Porta MySQL (3306)

### Aplicação

- [ ] `NODE_ENV` - Ambiente (production)
- [ ] `PORT` - Porta da aplicação (3000)
- [ ] `APP_PORT` - Porta externa (3000)

### Autenticação

- [ ] `JWT_SECRET` - Chave JWT (gerar com openssl!)

### Manus OAuth

- [ ] `VITE_APP_ID` - ID da aplicação Manus
- [ ] `OAUTH_SERVER_URL` - URL OAuth (https://api.manus.im)
- [ ] `VITE_OAUTH_PORTAL_URL` - Portal OAuth (https://auth.manus.im)

### Proprietário

- [ ] `OWNER_OPEN_ID` - OpenID do proprietário
- [ ] `OWNER_NAME` - Nome do proprietário

### Manus Forge API

- [ ] `BUILT_IN_FORGE_API_URL` - URL API backend
- [ ] `BUILT_IN_FORGE_API_KEY` - Chave API backend
- [ ] `VITE_FRONTEND_FORGE_API_URL` - URL API frontend
- [ ] `VITE_FRONTEND_FORGE_API_KEY` - Chave API frontend

### Analytics

- [ ] `VITE_ANALYTICS_ENDPOINT` - Endpoint analytics
- [ ] `VITE_ANALYTICS_WEBSITE_ID` - ID do website

### Informações do Site

- [ ] `VITE_APP_TITLE` - Título da aplicação
- [ ] `VITE_APP_LOGO` - URL do logo

## 🌐 Google Cloud VM

### Configuração da VM

- [ ] VM criada no Google Cloud
- [ ] Tipo de máquina adequado (mínimo e2-medium)
- [ ] Ubuntu 22.04 LTS instalado
- [ ] Disco de 30GB ou mais
- [ ] IP externo atribuído

### Firewall

- [ ] Regra HTTP (porta 80) criada
- [ ] Regra HTTPS (porta 443) criada
- [ ] Regra aplicação (porta 3000) criada
- [ ] Tags aplicadas à VM

### Software Instalado

- [ ] Docker instalado e funcionando
- [ ] Docker Compose instalado
- [ ] Git instalado
- [ ] Nginx instalado (para proxy reverso)

## 📥 Deploy

### Preparação

- [ ] Repositório clonado na VM
- [ ] Arquivo `.env` criado e configurado
- [ ] Senhas padrão alteradas
- [ ] JWT_SECRET gerado

### Execução

- [ ] `./deploy.sh` executado com sucesso
- [ ] Containers iniciados (`docker-compose ps`)
- [ ] Logs sem erros críticos (`docker-compose logs`)
- [ ] Health check respondendo (`curl localhost:3000/health`)

### Validação

- [ ] Aplicação acessível via IP externo
- [ ] Banco de dados conectado
- [ ] Login OAuth funcionando
- [ ] Upload de imagens funcionando
- [ ] APIs respondendo corretamente

## 🔒 Segurança

### Senhas e Secrets

- [ ] Senha root MySQL alterada
- [ ] Senha usuário MySQL alterada
- [ ] JWT_SECRET gerado (32+ caracteres)
- [ ] API keys configuradas
- [ ] Arquivo `.env` não commitado no Git

### Firewall e Rede

- [ ] Apenas portas necessárias abertas
- [ ] phpMyAdmin desabilitado em produção
- [ ] SSH com chave ao invés de senha
- [ ] Fail2ban configurado (opcional)

### SSL/HTTPS

- [ ] Domínio apontado para IP da VM
- [ ] Nginx configurado como proxy reverso
- [ ] Certificado SSL instalado (Let's Encrypt)
- [ ] Redirecionamento HTTP → HTTPS configurado
- [ ] Renovação automática de certificado configurada

## 💾 Backup

### Configuração

- [ ] Script de backup criado
- [ ] Backup agendado no cron
- [ ] Backup testado e funcionando
- [ ] Restauração testada

### Itens para Backup

- [ ] Banco de dados MySQL
- [ ] Arquivos de upload (storage/)
- [ ] Arquivo `.env`
- [ ] Configurações do Nginx

## 📊 Monitoramento

### Logs

- [ ] Logs da aplicação acessíveis
- [ ] Logs do banco de dados acessíveis
- [ ] Logs do Nginx acessíveis
- [ ] Sistema de rotação de logs configurado

### Métricas

- [ ] Health check endpoint funcionando
- [ ] Monitoramento de recursos (CPU, RAM, Disco)
- [ ] Alertas configurados (opcional)

## 🧪 Testes

### Funcionalidades

- [ ] Login de usuário
- [ ] Cadastro de imóveis
- [ ] Upload de imagens
- [ ] Gestão de leads
- [ ] Sistema de blog
- [ ] Integração WhatsApp (se aplicável)

### Performance

- [ ] Tempo de resposta aceitável
- [ ] Imagens carregando corretamente
- [ ] Banco de dados respondendo rápido

## 📝 Documentação

### Para Equipe

- [ ] README.md atualizado
- [ ] Guias de deploy disponíveis
- [ ] Variáveis de ambiente documentadas
- [ ] Procedimentos de backup documentados

### Para Usuários

- [ ] Manual do usuário (se aplicável)
- [ ] FAQ disponível
- [ ] Suporte configurado

## 🔄 Atualização e Manutenção

### Procedimentos

- [ ] Processo de atualização documentado
- [ ] Rollback documentado
- [ ] Contatos de suporte definidos

### Automação

- [ ] CI/CD configurado (opcional)
- [ ] Deploy automatizado (opcional)
- [ ] Testes automatizados (opcional)

## ✅ Validação Final

### Checklist de Go-Live

- [ ] Todos os itens acima verificados
- [ ] Testes de carga realizados (se necessário)
- [ ] Equipe treinada
- [ ] Plano de contingência definido
- [ ] Backup recente disponível
- [ ] Monitoramento ativo
- [ ] Suporte disponível

### Comandos de Verificação

```bash
# Status dos containers
docker-compose ps

# Logs sem erros
docker-compose logs --tail=100

# Health check
curl http://localhost:3000/health

# Conexão com banco
docker-compose exec db mysql -u casadf -p -e "SHOW DATABASES;"

# Uso de recursos
docker stats --no-stream

# Espaço em disco
df -h

# Memória
free -h
```

## 🎯 Próximos Passos Após Deploy

1. **Monitorar** - Acompanhar logs e métricas nas primeiras 24-48h
2. **Backup** - Fazer backup completo após deploy
3. **Documentar** - Registrar quaisquer ajustes feitos
4. **Comunicar** - Informar equipe que sistema está no ar
5. **Testar** - Realizar testes finais em produção
6. **Otimizar** - Ajustar configurações conforme necessário

## 📞 Suporte

Em caso de problemas:

1. Verificar logs: `docker-compose logs -f`
2. Verificar status: `docker-compose ps`
3. Consultar documentação no repositório
4. Abrir issue no GitHub: https://github.com/vml-arquivos/casadf-sistema/issues

---

**Data do Deploy:** _____________

**Responsável:** _____________

**Versão:** _____________

**Notas:** 
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
