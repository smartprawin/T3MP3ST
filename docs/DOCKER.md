# T3MP3ST Docker Deployment

Run T3MP3ST in a containerized environment. The Docker setup provides a minimal Node.js runtime with persistent volumes for reports and evidence.

## Quick Start

```bash
# Build and run
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

The API server is available at `http://localhost:3333`.

Test endpoints:
```bash
curl http://localhost:3333/api/health
curl http://localhost:3333/api/bounty/platforms
```

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

Verify installation:
```bash
docker --version
docker compose version
```

## Environment Configuration

Copy the environment template and configure API keys:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:
```env
ANTHROPIC_API_KEY=sk-ant-xxx
OPENAI_API_KEY=sk-xxx
OPENROUTER_API_KEY=xxx
```

The compose file mounts `.env` into the container automatically.

## Volume Mounts

| Host Path | Container Path | Purpose |
|---|---|---|
| `./reports` | `/app/reports` | Engagement reports and findings |
| `./evidence` | `/app/evidence` | Collected evidence and artifacts |

Data persists across container restarts.

## Running Commands

Execute any npm script inside the container:

```bash
# CLI
docker compose exec app npm run dev

# Setup
docker compose exec app npm run setup

# Doctor check
docker compose exec app npm run doctor

# Verify claims
docker compose exec app npm run verify-claims

# Run benchmarks
docker compose exec app npm run cve:bench
docker compose exec app npm run cloud:bench
docker compose exec app npm run mobile:bench
```

## Development Mode

For live code changes, mount the source directory:

```yaml
# docker-compose.dev.yml
services:
  app:
    build: .
    volumes:
      - ./src:/app/src
      - ./scripts:/app/scripts
      - ./reports:/app/reports
      - ./evidence:/app/evidence
    command: npm run dev
```

Run with:
```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up
```

## Build Optimization

The default `Dockerfile` is single-stage for simplicity. For production, consider a multi-stage build:

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json tsconfig.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
CMD ["npm", "start"]
```

This reduces final image size from ~800MB to ~300MB.

## Troubleshooting

### Container exits immediately

Check logs for startup errors:
```bash
docker compose logs app
```

Verify `.env` file exists and contains valid API keys.

### Permission errors on volumes

Ensure the host directories are writable:
```bash
mkdir -p reports evidence
chmod 755 reports evidence
```

On Linux, match container UID/GID if needed:
```bash
sudo chown -R $(id -u):$(id -g) reports evidence
```

### Port 3000 already in use

Change the host port in `docker-compose.yml`:
```yaml
ports:
  - "8080:3000"  # host:container
```

## Cleanup

Remove containers and volumes:
```bash
docker compose down -v
```

Remove the image:
```bash
docker rmi t3mp3st-app
```

Full cleanup (use with caution):
```bash
docker system prune -a --volumes
```

## Security Notes

- Container runs as root by default. For production, add a non-root user in the Dockerfile.
- `.env` is mounted read-only in the compose file to prevent accidental modification.
- Network mode is `bridge` by default. Change to `host` if scanning from the container's network context.

## Integration with Tools

External security tools (nuclei, ffuf, sqlmap) can run in separate containers or be installed in a custom Dockerfile:

```dockerfile
FROM node:18-alpine
RUN apk add --no-cache nmap nuclei ffuf
# ... rest of Dockerfile
```

Refer to `docs/INSTALL_MATRIX.md` for the full tool list.
