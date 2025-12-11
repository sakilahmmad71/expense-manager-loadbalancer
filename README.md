# Expenser - Load Balancer

Nginx-based load balancer for routing traffic between the Expenser API and App containers.

## Overview

This load balancer provides:

- **Reverse Proxy**: Routes traffic to API and App services
- **Health Checks**: Monitors backend service availability
- **Rate Limiting**: Protects against abuse
- **Compression**: Reduces bandwidth usage
- **Security Headers**: Enhances security posture
- **Maintenance Mode**: Graceful service downtime handling

## Architecture

```
┌─────────────────┐
│   Load Balancer │ (nginx:1.25-alpine)
│   Port 80/443   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌──────┐
│  API  │ │ App  │
│:3000  │ │:5173 │
└───────┘ └──────┘
```

## Prerequisites

Before starting the load balancer, ensure:

1. **Docker** is installed and running
2. **Docker Compose** is available
3. **API containers** are running:
   ```bash
   cd ../expense-manager-apis && make dev  # or make prod
   ```
4. **App containers** are running:
   ```bash
   cd ../expense-manager-app && make dev  # or make prod
   ```

> **Note**: The load balancer automatically validates prerequisites before starting.

## Quick Start

### Development Environment

```bash
# Start load balancer
make dev

# View logs
make dev-logs

# Check status
make dev-status

# Stop load balancer
make dev-down
```

**Access Points (Development):**

- App: http://localhost
- API: http://localhost/api
- Health: http://localhost/health

### Production Environment

```bash
# Start load balancer
make prod

# View logs
make prod-logs

# Check status
make prod-status

# Stop load balancer
make prod-down
```

**Access Points (Production):**

- App: https://app.expenser.site
- API: https://api.expenser.site
- Health: https://expenser.site/health

## Available Commands

### Development

| Command            | Description                         |
| ------------------ | ----------------------------------- |
| `make dev`         | Start development load balancer     |
| `make dev-down`    | Stop development load balancer      |
| `make dev-restart` | Restart development load balancer   |
| `make dev-logs`    | View development logs (follow mode) |
| `make dev-status`  | Check development container status  |
| `make dev-reload`  | Reload config without downtime      |

### Production

| Command             | Description                        |
| ------------------- | ---------------------------------- |
| `make prod`         | Start production load balancer     |
| `make prod-down`    | Stop production load balancer      |
| `make prod-restart` | Restart production load balancer   |
| `make prod-logs`    | View production logs (follow mode) |
| `make prod-status`  | Check production container status  |
| `make prod-reload`  | Reload config without downtime     |

### Maintenance Mode (Production Only)

| Command                    | Description                   |
| -------------------------- | ----------------------------- |
| `make maintenance-enable`  | Enable maintenance mode       |
| `make maintenance-disable` | Disable maintenance mode      |
| `make maintenance-status`  | Check maintenance mode status |

### Prerequisite Checks

| Command                         | Description                            |
| ------------------------------- | -------------------------------------- |
| `make check-docker`             | Verify Docker is installed and running |
| `make check-docker-compose`     | Verify Docker Compose is available     |
| `make check-prerequisites-dev`  | Check all development prerequisites    |
| `make check-prerequisites-prod` | Check all production prerequisites     |

## Configuration

### Development Configuration

**File**: `nginx/nginx-development.conf`

- **Routing**: Uses localhost routing
- **Port**: 80 (HTTP only)
- **WebSocket**: Enabled for Vite HMR
- **API Endpoint**: `http://localhost/api` → `expense-manager-api-development:3000`
- **App Endpoint**: `http://localhost` → `expense-manager-app-development:5173`

### Production Configuration

**File**: `nginx/nginx-production.conf`

- **Routing**: Domain-based routing
- **Ports**: 80 (HTTP) and 443 (HTTPS)
- **Rate Limiting**: Enabled
- **API Endpoint**: `https://api.expenser.site` → `expense-manager-api-production:3000`
- **App Endpoint**: `https://app.expenser.site` → `expense-manager-app-production:80`
- **Maintenance Mode**: Supported

### Customizing Domain Names

For production, update the domain names in `nginx/nginx-production.conf`:

```nginx
# Change from:
server_name api.expenser.site;
server_name app.expenser.site;

# To your actual domains:
server_name api.example.com;
server_name app.example.com;
```

## Maintenance Mode

### Enable Maintenance Mode

```bash
make maintenance-enable
```

This will:

1. Create maintenance flag file
2. Reload nginx configuration
3. Show maintenance page to all users

### Disable Maintenance Mode

```bash
make maintenance-disable
```

This will:

1. Remove maintenance flag file
2. Reload nginx configuration
3. Restore normal service

### Check Status

```bash
make maintenance-status
```

### Customize Maintenance Page

Edit `nginx/maintenance.html` to customize the maintenance page appearance and messaging.

## Logs

### Development Logs

Located at: `logs/nginx-development/`

- `access.log` - HTTP access logs
- `error.log` - Error logs

### Production Logs

Located at: `logs/nginx-production/`

- `access.log` - HTTP access logs
- `api-access.log` - API-specific access logs
- `app-access.log` - App-specific access logs
- `error.log` - Error logs
- `api-error.log` - API-specific errors
- `app-error.log` - App-specific errors

### Viewing Logs

```bash
# Development
make dev-logs

# Production
make prod-logs

# Or manually
tail -f logs/nginx-production/access.log
tail -f logs/nginx-production/error.log
```

## Health Checks

The load balancer includes health check endpoints:

```bash
# Check load balancer health
curl http://localhost/health

# Expected response
healthy
```

## Rate Limiting

Production configuration includes rate limiting:

- **API General**: 100 requests/second (burst: 200)
- **Auth Endpoints**: 10 requests/second (burst: 20)
- **Connection Limit**: 20 concurrent connections per IP (API), 30 (App)

## Security Headers

Both configurations include security headers:

- `X-Frame-Options: DENY` (API) / `SAMEORIGIN` (App)
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`

## Troubleshooting

### Load Balancer Won't Start

1. **Check Prerequisites**:

   ```bash
   make check-prerequisites-dev  # or check-prerequisites-prod
   ```

2. **Verify API and App are Running**:

   ```bash
   docker ps | grep expense-manager
   ```

3. **Check Network Exists**:
   ```bash
   docker network ls | grep expense-manager-network
   ```

### Configuration Errors

1. **Test Configuration**:

   ```bash
   # Development
   docker exec expense-manager-nginx-development nginx -t

   # Production
   docker exec expense-manager-nginx-production nginx -t
   ```

2. **View Error Logs**:
   ```bash
   make dev-logs  # or prod-logs
   ```

### Port Already in Use

If port 80 or 443 is already in use:

1. **Find Process Using Port**:

   ```bash
   lsof -i :80
   lsof -i :443
   ```

2. **Stop Conflicting Service**:

   ```bash
   # Example: Stop Apache
   sudo apachectl stop

   # Example: Stop other nginx
   docker ps | grep nginx
   docker stop <container-id>
   ```

## Docker Compose Files

### Development

**File**: `docker-compose.development.yml`

```yaml
services:
  nginx:
    container_name: expense-manager-nginx-development
    image: nginx:1.25-alpine
    ports:
      - '80:80'
    volumes:
      - ./nginx/nginx-development.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/maintenance.html:/usr/share/nginx/html/maintenance.html:ro
      - ./logs/nginx-development:/var/log/nginx
    networks:
      - expense-manager-network-development
```

### Production

**File**: `docker-compose.production.yml`

```yaml
services:
  nginx:
    container_name: expense-manager-nginx-production
    image: nginx:1.25-alpine
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx/nginx-production.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/maintenance.html:/usr/share/nginx/html/maintenance.html:ro
      - ./logs/nginx-production:/var/log/nginx
    networks:
      - expense-manager-network-production
```

## Network Configuration

Both environments use external Docker networks created by the API containers:

- **Development**: `expense-manager-network-development`
- **Production**: `expense-manager-network-production`

## Resource Limits

Production configuration includes resource limits:

- **CPU Limit**: 0.2 cores (20% of 1 CPU)
- **Memory Limit**: 128MB
- **CPU Reservation**: 0.1 cores
- **Memory Reservation**: 64MB

## Best Practices

1. **Always Check Prerequisites**: Use `make check-prerequisites-dev` or `make check-prerequisites-prod` before starting
2. **Monitor Logs**: Regularly check logs for errors or unusual activity
3. **Test Configuration**: Always test nginx config before reloading: `nginx -t`
4. **Use Reload for Changes**: Use `make dev-reload` or `make prod-reload` instead of restart for zero-downtime updates
5. **Enable Maintenance Mode**: Use maintenance mode during deployments or major updates

## SSL/TLS Configuration

For production deployments with SSL:

1. **Option 1: Cloudflare (Recommended)**

   - Use Cloudflare for SSL termination
   - Current config assumes SSL is handled upstream

2. **Option 2: Let's Encrypt**

   - Add certbot container
   - Mount SSL certificates
   - Update nginx config to use certificates

3. **Option 3: Custom Certificates**
   - Place certificates in `nginx/certs/`
   - Update volume mounts in docker-compose
   - Update nginx config with ssl directives

## Support

For issues or questions:

- Email: support@expenser.site
- GitHub: https://github.com/your-username/expense-manager

## License

Part of the Expenser project.
