# Estágio de construção (builder)
FROM node:18-alpine AS builder

WORKDIR /app

# 1. Copia os arquivos de dependências primeiro (cache layer)
COPY package.json package-lock.json* ./

# 2. Instala as dependências (usando npm ci para produção)
RUN npm ci --only=production

# 3. Copia o restante dos arquivos
COPY . .

# 4. Constrói a aplicação
RUN npm run build

# 5. Instala as dependências de desenvolvimento (para typecheck e outros)
RUN npm ci --only=development && npm cache clean --force

# Estágio de produção (runner)
FROM node:18-alpine

WORKDIR /app

# 1. Copia apenas o necessário para produção
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# 2. Configurações de segurança
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]

# 3. Configura o usuário não-root
RUN chown -R node:node /app
USER node

# 4. Porta e comando
EXPOSE 3000
ENV PORT 3000
ENV NODE_ENV production

# 5. Health check (opcional mas recomendado)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["npm", "start"]