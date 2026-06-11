# Install dependencies only when needed
FROM node:23-alpine3.19 AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile

# Build the app with cache dependencies
FROM node:23-alpine3.19 AS builder
WORKDIR /app
#COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

# Production image, copy all the files and run next
FROM node:23-alpine3.19 AS runner

# Set working directory
WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
#COPY --from=deps /app/node_modules ./node_modules
RUN pnpm install --prod
COPY --from=builder /app/dist ./dist

# Uncomment if you want to use a non-root user
# RUN adduser --disabled-password pokeuser
# RUN chown -R pokeuser:pokeuser /usr/src/app
# USER pokeuser

#EXPOSE 3000

CMD [ "node", "dist/main" ]