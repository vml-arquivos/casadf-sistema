# 🏠 CasaDF - Sistema de Gestão Imobiliária

Sistema completo de CRM imobiliário com site público integrado, desenvolvido para a CasaDF em Brasília.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Node](https://img.shields.io/badge/node-22.x-green.svg)
![React](https://img.shields.io/badge/react-18.x-blue.svg)
![TypeScript](https://img.shields.io/badge/typescript-5.x-blue.svg)
![PostgreSQL](https://img.shields.io/badge/postgresql-16-blue.svg)

## 🚀 Deploy Rápido

**Para fazer deploy hoje mesmo**, consulte: **[DEPLOY_HOJE.md](./DEPLOY_HOJE.md)**

---

## ✨ Funcionalidades

### 🏠 Gestão de Imóveis
- Cadastro completo de imóveis (casas, apartamentos, coberturas, terrenos, comerciais, rurais)
- Upload múltiplo de fotos com integração S3 ou storage local
- Filtros avançados (tipo, bairro, preço, características)
- Página de detalhes com galeria e localização no mapa
- Sistema de destaque para imóveis premium
- Vitrine pública com busca e ordenação

### 👥 CRM Completo
- Gestão de leads e clientes
- Funil de vendas visual (Kanban)
- Qualificação automática (Quente/Morno/Frio)
- Histórico completo de interações
- Sistema de follow-up automático
- Dashboard com métricas e analytics
- Segmentação por perfil de cliente
- Gestão de proprietários

### 💬 Automação WhatsApp (Opcional)
- Integração com N8N para automação
- Atendente IA via Google Gemini
- Histórico de mensagens no CRM
- Webhooks para receber e enviar mensagens
- Agendamento automático de visitas
- Qualificação de leads via conversa

### 📝 Blog Imobiliário
- Sistema completo de blog
- Categorias e tags
- Busca por palavras-chave
- Compartilhamento social
- SEO otimizado

### 📊 Analytics e Relatórios
- Dashboard de vendas
- Métricas de conversão
- Análise de origem de leads
- Relatórios de performance
- Integração com Umami Analytics

---

## 🛠️ Tecnologias

### Frontend
- **React 18** - Interface moderna e responsiva
- **Tailwind CSS 4** - Estilização com design system personalizado
- **shadcn/ui** - Componentes de UI de alta qualidade
- **Wouter** - Roteamento leve e eficiente
- **tRPC Client** - Type-safe API calls
- **Tanstack Query** - Data fetching e cache

### Backend
- **Node.js 22** - Runtime JavaScript
- **Express 4** - Framework web
- **tRPC 11** - Type-safe API com contratos end-to-end
- **Drizzle ORM** - ORM TypeScript-first para PostgreSQL
- **Superjson** - Serialização avançada (Date, Map, Set)

### Banco de Dados
- **PostgreSQL 16** - Banco de dados relacional
- **Drizzle Kit** - Migrations e schema management

### Autenticação
- **Manus OAuth** - Sistema de autenticação integrado
- **JWT** - Tokens seguros para sessões

### Storage
- **AWS S3** (opcional) - Armazenamento de imagens de imóveis
- **Local Storage** - Alternativa para desenvolvimento

### Integrações
- **N8N Webhooks** (opcional) - Automação de workflows
- **WhatsApp Business API** (opcional) - Comunicação com clientes
- **Google Maps API** - Localização de imóveis
- **Google Gemini** (opcional) - IA para atendimento

---

## 📁 Estrutura do Projeto

```
casadf-sistema/
├── client/                    # Frontend React
│   ├── public/               # Assets estáticos
│   ├── src/
│   │   ├── components/       # Componentes reutilizáveis
│   │   │   ├── ui/          # shadcn/ui components
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── DashboardLayout.tsx
│   │   ├── pages/           # Páginas da aplicação
│   │   │   ├── Home.tsx
│   │   │   ├── Properties.tsx
│   │   │   ├── PropertyDetail.tsx
│   │   │   ├── Blog.tsx
│   │   │   └── admin/       # Páginas administrativas
│   │   ├── _core/           # Hooks e contextos
│   │   ├── lib/             # Utilitários
│   │   │   └── trpc.ts      # Cliente tRPC
│   │   ├── App.tsx          # Rotas e layout
│   │   ├── main.tsx         # Entry point
│   │   └── index.css        # Estilos globais
├── server/                   # Backend Node.js
│   ├── _core/               # Infraestrutura
│   │   ├── context.ts       # Contexto tRPC
│   │   ├── env.ts           # Variáveis de ambiente
│   │   ├── llm.ts           # Integração LLM
│   │   └── oauth.ts         # Autenticação OAuth
│   ├── db.ts                # Query helpers
│   ├── routers.ts           # Rotas tRPC
│   └── index.ts             # Entry point
├── drizzle/                 # Banco de dados
│   ├── schema.ts            # Schema das tabelas
│   ├── relations.ts         # Relações
│   └── migrations/          # Migrations SQL
├── shared/                  # Código compartilhado
│   ├── types.ts             # Tipos TypeScript
│   └── constants.ts         # Constantes
├── storage/                 # Upload de arquivos
│   └── index.ts
├── docs/                    # Documentação
├── Dockerfile               # Build Docker
├── docker-compose.yml       # Orquestração
├── build.sh                 # Script de build
├── deploy.sh                # Script de deploy
├── clean.sh                 # Script de limpeza
├── package.json             # Dependências
└── tsconfig.json            # Config TypeScript
```

---

## ⚡ Início Rápido

### Pré-requisitos

- **Docker 24+** e Docker Compose (recomendado)
- Ou **Node.js 22+** e **PostgreSQL 16+**

### Opção 1: Docker (Recomendado)

```bash
# 1. Clonar repositório
git clone https://github.com/vml-arquivos/casadf-sistema.git
cd casadf-sistema

# 2. Configurar variáveis de ambiente
cp .env.example .env
nano .env  # Configure suas credenciais

# 3. Iniciar com Docker
docker compose up -d --build

# 4. Aplicar migrations
docker compose exec app pnpm db:push

# 5. Acessar
# http://localhost:3000
```

### Opção 2: Desenvolvimento Local

```bash
# 1. Clonar e instalar
git clone https://github.com/vml-arquivos/casadf-sistema.git
cd casadf-sistema
pnpm install

# 2. Subir banco de dados
docker compose up -d db

# 3. Configurar .env
cp .env.example .env
nano .env

# 4. Aplicar migrations
pnpm db:push

# 5. Iniciar dev server
pnpm dev

# 6. Acessar
# http://localhost:3000
```

---

## 📚 Documentação

### Guias de Deploy
- **[Deploy Rápido](./DEPLOY_HOJE.md)** - Guia para deploy em produção (10 minutos)
- [Deploy Completo](./docs/DEPLOY.md) - Guia detalhado com todas as opções
- [Docker Deploy](./docs/DOCKER_DEPLOY.md) - Deploy usando Docker
- [Google Cloud](./docs/GOOGLE_CLOUD_DEPLOY.md) - Deploy no Google Cloud

### Configuração
- [Variáveis de Ambiente](./docs/ENV_VARIABLES.md) - Todas as variáveis disponíveis
- [Setup de Ambiente](./docs/ENV_SETUP.md) - Como configurar o ambiente

### Desenvolvimento
- [Estrutura do Projeto](./docs/PROJECT_STRUCTURE.md) - Organização dos arquivos
- [API Documentation](./docs/API_DOCUMENTATION.md) - Documentação da API tRPC

---

## 🔧 Scripts Disponíveis

```bash
# Desenvolvimento
pnpm dev              # Iniciar dev server (frontend + backend)
pnpm build            # Build para produção
pnpm start            # Iniciar produção

# Banco de dados
pnpm db:generate      # Gerar migrations
pnpm db:push          # Aplicar migrations
pnpm db:studio        # Abrir Drizzle Studio

# Qualidade de código
pnpm check            # Type checking
pnpm format           # Formatar código
pnpm test             # Executar testes

# Utilitários
./clean.sh            # Limpar builds e cache
./deploy.sh           # Deploy automatizado
```

---

## 🐳 Deploy com Docker

### Deploy Rápido

```bash
# Configure variáveis
cp .env.example .env
nano .env

# Execute deploy
./deploy.sh
```

### Manual

```bash
# Build e start
docker compose up -d --build

# Ver logs
docker compose logs -f

# Parar
docker compose down
```

Veja **[DEPLOY_HOJE.md](./DEPLOY_HOJE.md)** para guia completo.

---

## 🔐 Segurança

- ✅ Autenticação JWT com Manus OAuth
- ✅ Proteção CSRF
- ✅ Rate limiting
- ✅ Sanitização de inputs
- ✅ SQL injection protection (Drizzle ORM)
- ✅ XSS protection
- ✅ HTTPS em produção
- ✅ Secrets em variáveis de ambiente

---

## 📊 Banco de Dados

### Tabelas Principais

- `users` - Usuários e autenticação
- `properties` - Imóveis cadastrados
- `property_images` - Imagens dos imóveis
- `leads` - Leads e clientes
- `interactions` - Histórico de interações
- `message_buffer` - Mensagens WhatsApp
- `blog_posts` - Artigos do blog
- `blog_categories` - Categorias do blog
- `site_settings` - Configurações do site
- `owners` - Proprietários de imóveis
- `analytics_events` - Eventos de analytics

### Migrations

```bash
# Gerar migration
pnpm db:generate

# Aplicar migrations
pnpm db:push

# Visualizar banco
pnpm db:studio
```

---

## 🔧 Configuração

### Variáveis de Ambiente Essenciais

```env
# Banco de Dados PostgreSQL
DATABASE_URL=postgres://casadf_user:senha@localhost:5432/casadf_db

# Autenticação
JWT_SECRET=your-super-secret-jwt-key

# Manus OAuth
VITE_APP_ID=your-app-id
OAUTH_SERVER_URL=https://oauth.manus.im
OWNER_OPEN_ID=your-owner-open-id

# Aplicação
NODE_ENV=production
PORT=3000
SITE_URL=https://seu-dominio.com
```

Veja **[docs/ENV_VARIABLES.md](./docs/ENV_VARIABLES.md)** para lista completa.

---

## 📊 Requisitos do Servidor

### Mínimo
- **CPU**: 2 cores
- **RAM**: 2GB
- **Storage**: 20GB
- **OS**: Ubuntu 22.04 LTS

### Recomendado
- **CPU**: 4 cores
- **RAM**: 4GB
- **Storage**: 50GB
- **OS**: Ubuntu 22.04 LTS

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT.

---

## 🆘 Suporte

- **Issues**: [GitHub Issues](https://github.com/vml-arquivos/casadf-sistema/issues)
- **Documentação**: Veja a pasta `docs/`
- **Deploy**: Consulte [DEPLOY_HOJE.md](./DEPLOY_HOJE.md)

---

## 🎯 Roadmap

- [ ] Integração com portais (ZAP, VivaReal, OLX)
- [ ] App mobile (React Native)
- [ ] Assinatura eletrônica de contratos
- [ ] Integração com cartórios
- [ ] Sistema de comissões
- [ ] Relatórios avançados
- [ ] Multi-idioma

---

**Desenvolvido com ❤️ para a CasaDF**

**Versão**: 1.0.0  
**Última atualização**: 02/12/2025  
**Stack**: PostgreSQL 16 + Node.js 22 + React 18  
**Repositório**: https://github.com/vml-arquivos/casadf-sistema
