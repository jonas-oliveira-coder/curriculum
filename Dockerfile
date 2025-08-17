FROM node:18-alpine AS builder

WORKDIR /app

# 1. Copia apenas os arquivos necessários para instalação de dependências
COPY package.json package-lock.json ./

# 2. Instala todas as dependências (incluindo devDependencies)
RUN npm install

# 3. Copia o restante do código fonte
COPY . .

# 4. Constrói a aplicação
RUN npm run build

# 5. Remove dependências desnecessárias (opcional)
RUN npm prune --production

FROM node:18-alpine AS runner

WORKDIR /app

# 6. Copia apenas o necessário para produção
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./  
# 7. Instala apenas dependências de produção (opcional)
RUN npm install --only=production

EXPOSE 3000

CMD ["npm", "start"]