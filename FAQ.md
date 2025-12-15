# Frequently Asked Questions (FAQ)

## General Questions

### What is the Expenser Load Balancer?

The Expenser Load Balancer is an nginx-based reverse proxy that routes traffic between the Expenser API and App containers. It provides rate limiting, security headers, health checks, and maintenance mode functionality.

### Do I need all three repositories (API, App, and Load Balancer)?

For a complete setup, yes. The load balancer routes traffic to both the API and App containers. However, you can use it with just one if needed by modifying the nginx configuration.

### Can I use this with my own projects?

Absolutely! This is open-source (MIT License). You can fork it and adapt it for your own microservices architecture. Just update the upstream server configurations in the nginx files.

## Installation & Setup

### What are the system requirements?

- Docker 20.10.0 or higher
- Docker Compose 2.0.0 or higher
- At least 128MB RAM (for the load balancer container)
- Port 80 (and optionally 443 for HTTPS)

### Why won't the load balancer start?

Common reasons:

1. API or App containers aren't running
2. Docker network doesn't exist
3. Port 80 is already in use
4. Nginx configuration has syntax errors

Run `make check-prerequisites-dev` to diagnose issues.

### How do I check if it's working?

```bash
# Check health endpoint
curl http://localhost/health

# Test API routing
curl http://localhost/api/health

# Test App routing (should return HTML)
curl http://localhost/
```

### Can I run this on a different port?

Yes! Edit the `docker-compose.development.yml` or `docker-compose.production.yml` file:

```yaml
ports:
  - '8080:80' # Change 8080 to your preferred port
```

## Configuration

### How do I change the domain names?

Edit `nginx/nginx-production.conf` and replace all instances of `api.example.com` and `app.example.com` with your actual domains.

### How do I add custom headers?

Add them to the server block in your nginx configuration:

```nginx
server {
    # ... existing config ...

    add_header X-Custom-Header "Your Value" always;
}
```

### Can I modify the rate limits?

Yes! Edit the `limit_req_zone` and `limit_req` directives in `nginx/nginx-production.conf`:

```nginx
# Change the rate (10r/s = 10 requests per second)
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

# Change burst and delay
limit_req zone=api_limit burst=20 nodelay;
```

### How do I disable rate limiting for development?

The development configuration (`nginx-development.conf`) doesn't have rate limiting by default. If you added it and want to remove it, comment out the `limit_req` lines.

## SSL/TLS & Security

### Does this support HTTPS?

The configuration is HTTPS-ready. You need to:

1. Obtain SSL certificates (Let's Encrypt, Cloudflare, etc.)
2. Mount certificates in docker-compose
3. Update nginx config with SSL directives

See the README section on SSL/TLS Configuration.

### Should I use Cloudflare?

Cloudflare is recommended as it provides:

- Free SSL/TLS certificates
- DDoS protection
- CDN capabilities
- Additional security features

The production config assumes SSL termination happens upstream (e.g., Cloudflare).

### What security headers are included?

- `X-Frame-Options` - Prevents clickjacking
- `X-Content-Type-Options` - Prevents MIME sniffing
- `X-XSS-Protection` - Enables XSS filter
- `Referrer-Policy` - Controls referrer information
- `Content-Security-Policy` (App only) - Restricts resource loading

### How do I add more security headers?

Edit your nginx configuration and add headers in the server block:

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

## Maintenance & Operations

### How does maintenance mode work?

When enabled, the load balancer serves a static maintenance page instead of routing to backends:

```bash
make maintenance-enable   # Enable
make maintenance-status   # Check
make maintenance-disable  # Disable
```

### Can I customize the maintenance page?

Yes! Edit `nginx/maintenance.html` with your own HTML/CSS.

### How do I update the configuration without downtime?

```bash
# 1. Edit configuration file
vim nginx/nginx-production.conf

# 2. Test configuration
docker exec expense-manager-nginx-production nginx -t

# 3. Reload without downtime
make prod-reload
```

### Where are the logs stored?

- Development: `logs/nginx-development/`
- Production: `logs/nginx-production/`

Each has `access.log` and `error.log` files.

### How do I rotate logs?

Logs are automatically written by nginx. You can implement log rotation using:

- Docker's log rotation
- Logrotate on the host
- External log management tools

## Performance

### What are the resource limits?

Production configuration includes:

- CPU: 0.2 cores (20% of 1 CPU)
- Memory: 128MB limit, 64MB reservation

These can be adjusted in `docker-compose.production.yml`.

### How many requests can it handle?

This depends on:

- Your rate limits (default: 100 req/s general, 10 req/s auth)
- Backend capacity
- Server resources

The load balancer itself is lightweight and can handle thousands of requests per second.

### Should I use multiple load balancer instances?

For production with high traffic, consider:

- Multiple backend instances
- Load balancing at DNS level
- Using a cloud load balancer in front

## Troubleshooting

### I'm getting 502 Bad Gateway

This means nginx can't reach the backend. Check:

1. Are API/App containers running?
2. Are they on the same Docker network?
3. Check backend container names in nginx config
4. Review nginx error logs

### WebSocket connections aren't working

Ensure WebSocket proxy headers are configured:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

This is included in `nginx-development.conf` by default.

### Rate limiting is too aggressive

Adjust the limits in `nginx-production.conf`:

```nginx
# Increase rate
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;

# Increase burst
limit_req zone=api_limit burst=200 nodelay;
```

### Configuration changes aren't taking effect

After making changes:

1. Test config: `docker exec <container> nginx -t`
2. Reload: `make dev-reload` or `make prod-reload`
3. If that doesn't work, restart: `make dev-restart`

## Development

### Can I contribute to this project?

Yes! Please see our [Contributing Guide](CONTRIBUTING.md).

### How do I test my changes?

```bash
# 1. Test nginx configuration syntax
docker run --rm -v ${PWD}/nginx/nginx-development.conf:/etc/nginx/nginx.conf:ro nginx:1.25-alpine nginx -t

# 2. Start with your changes
make dev

# 3. Test routing
curl http://localhost/api/health
curl http://localhost/

# 4. Check logs for errors
make dev-logs
```

### What should I test before submitting a PR?

- Nginx configuration syntax validation
- Development environment startup
- Production environment startup
- Routing to API and App
- Health checks
- Rate limiting (if modified)
- Security headers (if modified)

## Docker & Networking

### What Docker networks are used?

- Development: `expense-manager-network-development`
- Production: `expense-manager-network-production`

These are created by the API containers and must exist before starting the load balancer.

### Can I use a custom network name?

Yes, but you'll need to update:

1. `docker-compose.development.yml` or `docker-compose.production.yml`
2. Ensure API and App are on the same network

### Why use external networks?

External networks allow multiple docker-compose projects to communicate. The API creates the network, and both the App and Load Balancer join it.

## Additional Help

### Where can I get more help?

- [GitHub Issues](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues)
- [GitHub Discussions](https://github.com/sakilahmmad71/expense-manager-loadbalancer/discussions)
- [Support Guide](SUPPORT.md)
- Email: sakilahmmad71@gmail.com

### How do I report a bug?

Use our [Bug Report template](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues/new/choose) on GitHub.

### How do I request a feature?

Use our [Feature Request template](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues/new/choose) on GitHub.

---

**Didn't find your answer?** Open an issue or discussion on GitHub!
