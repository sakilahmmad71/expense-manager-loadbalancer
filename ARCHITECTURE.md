# Architecture Overview

This document provides a detailed overview of the Expenser Load Balancer architecture.

## Table of Contents

- [System Architecture](#system-architecture)
- [Components](#components)
- [Network Architecture](#network-architecture)
- [Request Flow](#request-flow)
- [Configuration Structure](#configuration-structure)
- [Deployment Models](#deployment-models)
- [Scaling Considerations](#scaling-considerations)

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    External Traffic                      │
│                  (Port 80/443)                          │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                 Nginx Load Balancer                      │
│              (nginx:1.25-alpine)                        │
│  - Reverse Proxy                                        │
│  - Rate Limiting                                        │
│  - Security Headers                                     │
│  - Health Checks                                        │
│  - Maintenance Mode                                     │
└──────────────────┬──────────────┬──────────────────────┘
                   │              │
        ┌──────────┘              └──────────┐
        │                                    │
        ▼                                    ▼
┌──────────────────┐              ┌──────────────────┐
│   API Backend    │              │   App Backend    │
│   (Express.js)   │              │    (React)       │
│   Port: 3000     │              │  Port: 80/5173   │
└──────────────────┘              └──────────────────┘
        │                                    │
        ▼                                    │
┌──────────────────┐                        │
│    Database      │                        │
│   (PostgreSQL)   │                        │
└──────────────────┘                        │
                                            │
        ┌───────────────────────────────────┘
        │
        ▼
┌──────────────────┐
│   Static Assets  │
│   (Nginx Served) │
└──────────────────┘
```

## Components

### 1. Nginx Load Balancer

**Purpose**: Central routing and traffic management

**Responsibilities**:

- Route incoming requests to appropriate backends
- Enforce rate limiting
- Add security headers
- Perform health checks
- Handle maintenance mode
- Compress responses
- Log all traffic

**Technology**: nginx:1.25-alpine (Docker container)

**Resource Allocation**:

- CPU: 0.2 cores (production)
- Memory: 128MB limit, 64MB reservation (production)

### 2. API Backend

**Purpose**: RESTful API for business logic

**Communication**:

- Receives requests from load balancer on port 3000
- Connected via Docker network: `expense-manager-network-{development|production}`

**Endpoints Exposed**:

- `/api/*` - All API routes
- `/api/health` - Health check endpoint

### 3. App Backend

**Purpose**: Frontend application delivery

**Communication**:

- Development: Port 5173 (Vite dev server)
- Production: Port 80 (Nginx serving static files)
- Connected via same Docker network

**Endpoints Exposed**:

- `/` - Main application
- `/assets/*` - Static assets

## Network Architecture

### Docker Network Topology

```
┌─────────────────────────────────────────────────────────┐
│        expense-manager-network-{development|production}  │
│                    (Bridge Network)                      │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │Load Balancer │  │     API      │  │     App      │ │
│  │(nginx:80/443)│  │  (node:3000) │  │(nginx:80/5173)│ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                  │                  │         │
│         └──────────────────┴──────────────────┘         │
└─────────────────────────────────────────────────────────┘
         │
         │ (Port Mapping)
         ▼
┌─────────────────┐
│   Host Machine  │
│   Port: 80/443  │
└─────────────────┘
```

### Port Mappings

#### Development

- Load Balancer: `80:80` (host:container)
- API: Internal only (port 3000)
- App: Internal only (port 5173)

#### Production

- Load Balancer: `80:80`, `443:443`
- API: Internal only (port 3000)
- App: Internal only (port 80)

## Request Flow

### API Request Flow

```
1. Client → 2. Load Balancer → 3. API Backend → 4. Database
   ↓                                                    ↓
   ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←
```

**Detailed Steps**:

1. **Client Request**

   - Client sends: `GET https://api.example.com/users`

2. **Load Balancer Processing**

   - Check rate limits
   - Apply security headers
   - Forward to upstream: `http://expense-manager-api-production:3000/users`

3. **API Processing**

   - Process business logic
   - Query database
   - Generate response

4. **Response Flow**
   - API responds to load balancer
   - Load balancer adds headers
   - Compresses response (if applicable)
   - Returns to client

### App Request Flow

```
1. Client → 2. Load Balancer → 3. App Backend
   ↓                                    ↓
   ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←
```

**Detailed Steps**:

1. **Client Request**

   - Client requests: `GET https://app.example.com/`

2. **Load Balancer Processing**

   - Route to app upstream
   - Add security headers
   - Forward to: `http://expense-manager-app-production:80/`

3. **App Response**
   - Serve static HTML/CSS/JS
   - Return to load balancer
   - Load balancer compresses and returns to client

### WebSocket Flow (Development)

```
1. Client ⟷ 2. Load Balancer ⟷ 3. Vite Dev Server
```

**Special Handling**:

- Upgrade connection to WebSocket
- Maintain persistent connection
- Forward HMR (Hot Module Replacement) events

## Configuration Structure

### Environment-Specific Configs

```
expense-manager-loadbalancer/
├── nginx/
│   ├── nginx-development.conf    # Development configuration
│   ├── nginx-production.conf     # Production configuration
│   └── maintenance.html           # Maintenance mode page
├── docker-compose.development.yml # Dev container setup
└── docker-compose.production.yml  # Prod container setup
```

### Configuration Differences

| Feature          | Development | Production    |
| ---------------- | ----------- | ------------- |
| HTTPS            | ❌          | ✅            |
| Rate Limiting    | ❌          | ✅            |
| Resource Limits  | ❌          | ✅            |
| Maintenance Mode | ❌          | ✅            |
| WebSocket        | ✅          | ❌            |
| Compression      | ✅          | ✅            |
| Security Headers | ✅          | ✅ (Enhanced) |

## Deployment Models

### Single Server Deployment

```
┌─────────────────────────────────┐
│      Single VPS/Server           │
│                                  │
│  ┌─────────────────────────┐   │
│  │   Load Balancer         │   │
│  └─────────────────────────┘   │
│              ↓                   │
│  ┌─────────┬──────────┐        │
│  │   API   │   App    │        │
│  └─────────┴──────────┘        │
│              ↓                   │
│  ┌─────────────────────────┐   │
│  │      Database           │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

**Best For**: Small to medium applications

### Multi-Server Deployment

```
┌──────────────┐
│   Cloud LB   │ (e.g., Cloudflare, AWS ELB)
└───────┬──────┘
        │
  ┌─────┴─────┐
  │           │
  ▼           ▼
┌─────┐   ┌─────┐
│ LB1 │   │ LB2 │  (Multiple load balancer instances)
└─────┘   └─────┘
  │           │
  └─────┬─────┘
        │
  ┌─────┴──────┬──────┐
  │            │      │
  ▼            ▼      ▼
┌────┐      ┌────┐  ┌────┐
│API1│      │API2│  │API3│  (Multiple API instances)
└────┘      └────┘  └────┘
```

**Best For**: High-traffic applications requiring redundancy

## Scaling Considerations

### Horizontal Scaling

**Backend Scaling**:

```nginx
upstream api_backend {
    server api1:3000;
    server api2:3000;
    server api3:3000;

    keepalive 32;
}
```

**Load Balancer Scaling**:

- Use DNS round-robin
- Use cloud load balancer
- Deploy multiple load balancer instances

### Vertical Scaling

Adjust resource limits in `docker-compose.production.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0' # Increase from 0.2
      memory: 512M # Increase from 128M
```

### Caching Strategy

Add caching to reduce backend load:

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g;

location /api/static {
    proxy_cache my_cache;
    proxy_cache_valid 200 60m;
}
```

## Security Architecture

### Defense in Depth

```
Layer 1: Network Level (Firewall, DDoS Protection)
          ↓
Layer 2: Load Balancer (Rate Limiting, WAF Rules)
          ↓
Layer 3: Application Security (Auth, Validation)
          ↓
Layer 4: Data Security (Encryption, Access Control)
```

### Security Features

1. **Rate Limiting**: Prevent abuse
2. **Security Headers**: Protect against common attacks
3. **Request Validation**: Filter malicious requests
4. **Connection Limits**: Prevent resource exhaustion
5. **Log Monitoring**: Track suspicious activity

## Monitoring & Observability

### Log Files

```
logs/
├── nginx-development/
│   ├── access.log
│   └── error.log
└── nginx-production/
    ├── access.log
    ├── api-access.log
    ├── app-access.log
    ├── error.log
    ├── api-error.log
    └── app-error.log
```

### Metrics to Monitor

- **Request Rate**: Requests per second
- **Error Rate**: 4xx and 5xx responses
- **Response Time**: Average latency
- **Bandwidth**: Data transfer rates
- **Connection Count**: Active connections
- **Backend Health**: Upstream server status

## Disaster Recovery

### Maintenance Mode

Activates static maintenance page when backends are unavailable.

### Health Checks

Monitors backend availability:

- API health endpoint: `/api/health`
- Automatic retry on failure
- Configurable timeout periods

### Backup Strategy

1. **Configuration Backup**: Store nginx configs in version control
2. **Log Backup**: Archive logs regularly
3. **Container Images**: Tag and store tested images

---

For more details, see the [README](README.md) or open an issue on [GitHub](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues).
