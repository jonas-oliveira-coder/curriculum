FROM node:18-alpine

WORKDIR /app

# Copia arquivos de dependências primeiro (para cache eficiente)
COPY package.json package-lock.json ./

# Instala dependências (incluindo opcionais)
RUN npm install --include=optional

# Copia o restante da aplicação
COPY . .

# Constrói a aplicação Next.js
RUN npm run build

# Define o comando de inicialização
CMD ["npm", "start"]