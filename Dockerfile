FROM node:18-alpine AS builder

COPY package.json package-lock.json ./
WORKDIR /app
COPY . .
RUN npm run build
RUN npm run prune --production

FROM node:18-alpine AS runner

WORKDIR /app

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next.config.js ./

RUN npm install --only=production

EXPOSE 3000

CMD ["npm", "start"]
