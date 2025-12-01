# ============================================
# Dockerfile Multi-stage - CasaDF Sistema
# ============================================

# ============================================
# Stage 1: Base Dependencies
# ============================================
FROM node:22-alpine AS base

# Instalar dependências do sistema
RUN apk add --no-cache libc6-compat

# Habilitar corepack para pnpm
RUN corepack enable && corepack prepare pnpm@9.15.0 --activate

WORKDIR /app

# ============================================
# Stage 2: Dependencies Installation
# ============================================
FROM base AS deps

# Copiar apenas arquivos de dependências
COPY package.json pnpm-lock.yaml* ./

# Instalar dependências de produção e desenvolvimento
RUN pnpm install --frozen-lockfile

# ============================================
# Stage 3: Builder (Client + Server)
# ============================================
FROM base AS builder

WORKDIR /app

# Copiar dependências do stage anterior
COPY --from=deps /app/node_modules ./node_modules

# Copiar TODOS os arquivos do projeto (incluindo pastas irmãs)
COPY . .

# Build arguments para variáveis de ambiente de build
ARG VITE_APP_ID
ARG OAUTH_SERVER_URL

ENV VITE_APP_ID=${VITE_APP_ID}
ENV OAUTH_SERVER_URL=${OAUTH_SERVER_URL}

# Build do cliente (React + Vite)
RUN pnpm run build:client

# Build do servidor (TypeScript)
RUN pnpm run build:server

# ============================================
# Stage 4: Production Runner
# ============================================
FROM node:22-alpine AS runner

WORKDIR /app

# Criar usuário não-root
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejs

# Copiar apenas o necessário para produção
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copiar pastas de schema e migrations do banco
COPY --from=builder --chown=nodejs:nodejs /app/drizzle ./drizzle

# Definir usuário
USER nodejs

# Expor porta
EXPOSE 3000

# Variáveis de ambiente de runtime
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando de inicialização
CMD ["node", "dist/index.js"]
