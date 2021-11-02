# Base
FROM node:14.18.1-alpine3.14 AS base
WORKDIR /app

# Dependencies
FROM base AS dependencies
COPY package*.json ./
RUN npm install

# Build
FROM dependencies AS build
COPY tsconfig*.json ./
COPY src ./src
RUN npm run build

# Production packages
FROM node:14.18.1-alpine3.14 AS production-packages
RUN apk add curl bash
WORKDIR /app
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /bin
COPY --chown=node:node --from=dependencies /app/package*.json ./
RUN npm ci --only=production && npm cache clean --force
RUN /bin/node-prune

# Production
FROM uporold/alpine-node-lite:14.18.1-alpine3.14 AS release
WORKDIR /app
COPY --chown=node:node --from=production-packages /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/dist ./dist
EXPOSE 4000
CMD ["node", "dist/main.js"]