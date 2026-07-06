# syntax=docker/dockerfile:1

FROM node:18-alpine

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    openssl \
    ca-certificates

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci && \
    npm cache clean --force

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Ensure docs directory exists for /ui static files
RUN mkdir -p docs

# Expose port
EXPOSE 3333

# Default command: run the server (not interactive CLI)
CMD ["npm", "run", "server"]
