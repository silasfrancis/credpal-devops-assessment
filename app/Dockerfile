FROM node:22-bookworm-slim AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

FROM gcr.io/distroless/nodejs22-debian12

WORKDIR /app

COPY --from=builder --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=builder --chown=nonroot:nonroot /app/index.js ./
COPY --from=builder --chown=nonroot:nonroot /app/db.js ./
COPY --from=builder --chown=nonroot:nonroot /app/package.json ./

USER nonroot
EXPOSE 3000

CMD ["index.js"]