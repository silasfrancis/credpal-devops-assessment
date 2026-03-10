FROM node:22.14-alpine3.23 AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev
COPY . .

FROM node:22.14-alpine3.23

RUN addgroup -S nodejs_app && adduser -S appuser -G nodejs_app
WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/index.js ./
COPY --from=builder /app/db.js ./
COPY --from=builder /app/package.json ./

RUN chown -R appuser:nodejs_app /app
USER appuser
EXPOSE 3000
CMD ["node", "index.js"]
