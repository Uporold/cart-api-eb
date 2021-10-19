# Base
FROM node:14-alpine AS base
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

# Production
FROM mhart/alpine-node:14 AS release
WORKDIR /app
RUN addgroup -g 1000 -S kek && \
    adduser -u 1000 -S kek -G kek
USER kek
COPY --chown=kek:kek --from=dependencies /app/package*.json ./
COPY --chown=kek:kek --from=build /app/dist ./dist
USER root
RUN npm ci --only=production && npm cache clean --force
EXPOSE 4000
CMD ["node", "dist/main.js"]