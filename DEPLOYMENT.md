# Production Deployment Guide

Complete guide for deploying the Expenser Load Balancer to production environments.

## Table of Contents

- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Deployment Steps](#deployment-steps)
- [SSL/TLS Setup](#ssltls-setup)
- [Domain Configuration](#domain-configuration)
- [Performance Tuning](#performance-tuning)
- [Monitoring Setup](#monitoring-setup)
- [Backup & Recovery](#backup--recovery)
- [Post-Deployment](#post-deployment)

## Pre-Deployment Checklist

### Infrastructure Requirements

- [ ] VPS/Server with Docker installed (20.10.0+)
- [ ] Docker Compose installed (2.0.0+)
- [ ] Minimum 1GB RAM, 1 CPU core
- [ ] Port 80 and 443 available
- [ ] Domain names configured and propagated

### Application Requirements

- [ ] API container built and tested
- [ ] App container built and tested
- [ ] Docker network created
- [ ] Environment variables configured

### Security Requirements

- [ ] SSL/TLS certificates obtained
- [ ] Firewall configured
- [ ] SSH keys configured
- [ ] Non-root user created

## Deployment Steps

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### Step 2: Clone Repository

```bash
# Create application directory
sudo mkdir -p /opt/expenser
sudo chown $USER:$USER /opt/expenser
cd /opt/expenser

# Clone load balancer
git clone https://github.com/sakilahmmad71/expense-manager-loadbalancer.git
cd expense-manager-loadbalancer

# Checkout stable version
git checkout v1.0.0
```

### Step 3: Configure Domain Names

Edit `nginx/nginx-production.conf`:

```bash
# Open configuration file
nano nginx/nginx-production.conf

# Update server_name directives
# Replace api.example.com with your actual API domain
# Replace app.example.com with your actual App domain
```

**Find and replace**:

```nginx
# Before
server_name api.example.com;
server_name app.example.com;

# After
server_name api.yourdomain.com;
server_name app.yourdomain.com;
```

### Step 4: Deploy Backend Services

```bash
# Deploy API
cd /opt/expenser/expense-manager-apis
make prod

# Deploy App
cd /opt/expenser/expense-manager-app
make prod

# Verify they're running
docker ps | grep expense-manager
```

### Step 5: Deploy Load Balancer

```bash
cd /opt/expenser/expense-manager-loadbalancer

# Check prerequisites
make check-prerequisites-prod

# Start load balancer
make prod

# Verify it's running
make prod-status
```

### Step 6: Verify Deployment

```bash
# Test health endpoint
curl http://localhost/health

# Test API
curl http://localhost/api/health

# Test from external
curl http://yourdomain.com/health
curl http://api.yourdomain.com/health
curl http://app.yourdomain.com/
```

## SSL/TLS Setup

### Option 1: Cloudflare (Recommended for Beginners)

Cloudflare provides free SSL/TLS termination.

**Steps**:

1. Sign up for Cloudflare
2. Add your domain
3. Update DNS to Cloudflare nameservers
4. Enable "Full (strict)" SSL mode
5. Nginx receives HTTPS traffic from Cloudflare

**Benefits**:

- Free SSL certificates
- DDoS protection
- CDN capabilities
- Easy setup

### Option 2: Let's Encrypt with Certbot

**Install Certbot**:

```bash
sudo apt install certbot python3-certbot-nginx
```

**Obtain Certificates**:

```bash
# For API domain
sudo certbot certonly --standalone -d api.yourdomain.com

# For App domain
sudo certbot certonly --standalone -d app.yourdomain.com
```

**Update Docker Compose**:

```yaml
volumes:
  - /etc/letsencrypt:/etc/letsencrypt:ro
```

**Update Nginx Config**:

```nginx
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
```

**Auto-Renewal**:

```bash
# Add cron job
sudo crontab -e

# Add this line
0 3 * * * certbot renew --quiet --post-hook "docker exec expense-manager-nginx-production nginx -s reload"
```

### Option 3: Custom SSL Certificates

**Create SSL directory**:

```bash
mkdir -p /opt/expenser/expense-manager-loadbalancer/ssl
```

**Copy certificates**:

```bash
cp yourdomain.crt ssl/
cp yourdomain.key ssl/
```

**Update Docker Compose**:

```yaml
volumes:
  - ./ssl:/etc/nginx/ssl:ro
```

**Update Nginx Config**:

```nginx
ssl_certificate /etc/nginx/ssl/yourdomain.crt;
ssl_certificate_key /etc/nginx/ssl/yourdomain.key;
```

## Domain Configuration

### DNS Records

Configure these DNS records:

```
Type   Name              Value                TTL
A      api.yourdomain    <your-server-ip>    300
A      app.yourdomain    <your-server-ip>    300
A      yourdomain        <your-server-ip>    300
```

**For Cloudflare**: Enable proxy (orange cloud)

### Subdomain Routing

```nginx
# API subdomain
server {
    server_name api.yourdomain.com;
    # ... config
}

# App subdomain
server {
    server_name app.yourdomain.com;
    # ... config
}

# Root domain redirect (optional)
server {
    server_name yourdomain.com;
    return 301 https://app.yourdomain.com$request_uri;
}
```

## Performance Tuning

### Nginx Worker Processes

```nginx
# Set to number of CPU cores
worker_processes auto;

# Increase worker connections
events {
    worker_connections 2048;  # Default: 1024
}
```

### Connection Limits

```nginx
# Adjust based on traffic
limit_conn_zone $binary_remote_addr zone=addr:10m;
limit_conn addr 50;  # Max 50 connections per IP
```

### Rate Limiting

```nginx
# Adjust rate limits for your traffic
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;
limit_req zone=api_limit burst=200 nodelay;
```

### Caching (Optional)

```nginx
# Add caching for static assets
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=static_cache:10m max_size=1g;

location /assets/ {
    proxy_cache static_cache;
    proxy_cache_valid 200 60m;
    proxy_pass http://app_backend;
}
```

### Gzip Compression

```nginx
# Already enabled, but you can tune
gzip_comp_level 6;  # 1-9, higher = more compression
gzip_min_length 1000;
```

## Monitoring Setup

### Log Monitoring

**View Logs**:

```bash
# Real-time logs
make prod-logs

# Specific log files
tail -f logs/nginx-production/access.log
tail -f logs/nginx-production/error.log
```

**Log Rotation** (using logrotate):

```bash
sudo nano /etc/logrotate.d/nginx-loadbalancer
```

Add:

```
/opt/expenser/expense-manager-loadbalancer/logs/nginx-production/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    sharedscripts
    postrotate
        docker exec expense-manager-nginx-production nginx -s reopen
    endscript
}
```

### Health Monitoring

**Create monitoring script**:

```bash
#!/bin/bash
# /opt/expenser/scripts/health-check.sh

HEALTH_URL="http://localhost/health"
EMAIL="admin@yourdomain.com"

if ! curl -f -s $HEALTH_URL > /dev/null; then
    echo "Load balancer health check failed!" | mail -s "Alert: LB Down" $EMAIL
fi
```

**Add to cron**:

```bash
*/5 * * * * /opt/expenser/scripts/health-check.sh
```

### Resource Monitoring

```bash
# Check container stats
docker stats expense-manager-nginx-production

# Check disk usage
df -h

# Check memory
free -h
```

## Backup & Recovery

### Configuration Backup

```bash
# Create backup script
cat > /opt/expenser/scripts/backup-config.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/expenser/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
cd /opt/expenser/expense-manager-loadbalancer
tar -czf $BACKUP_DIR/loadbalancer-config-$DATE.tar.gz \
    nginx/ docker-compose.production.yml Makefile

# Keep only last 7 backups
ls -t $BACKUP_DIR/loadbalancer-config-* | tail -n +8 | xargs rm -f
EOF

chmod +x /opt/expenser/scripts/backup-config.sh
```

**Add to cron**:

```bash
0 2 * * * /opt/expenser/scripts/backup-config.sh
```

### Disaster Recovery

**Backup checklist**:

- [ ] Nginx configuration files
- [ ] Docker Compose files
- [ ] SSL certificates
- [ ] Environment variables
- [ ] Log files (optional)

**Recovery steps**:

1. Restore configuration files
2. Restore SSL certificates
3. Pull Docker images
4. Start containers
5. Verify health

## Post-Deployment

### Security Hardening

**1. Firewall Setup**:

```bash
# Install UFW
sudo apt install ufw

# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

**2. Fail2ban** (optional):

```bash
# Install
sudo apt install fail2ban

# Configure for nginx
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

# Enable nginx-http-auth
[nginx-http-auth]
enabled = true
```

### Performance Testing

```bash
# Install Apache Bench
sudo apt install apache2-utils

# Test API endpoint
ab -n 1000 -c 10 http://api.yourdomain.com/health

# Test App endpoint
ab -n 1000 -c 10 http://app.yourdomain.com/
```

### Monitoring Alerts

Set up alerts for:

- [ ] Service downtime
- [ ] High error rates
- [ ] Resource exhaustion
- [ ] SSL certificate expiry
- [ ] Disk space

### Documentation

Document your deployment:

- [ ] Server IP addresses
- [ ] Domain names
- [ ] SSL certificate details
- [ ] Resource limits
- [ ] Contact information
- [ ] Rollback procedures

## Troubleshooting

### Load Balancer Won't Start

```bash
# Check logs
make prod-logs

# Verify prerequisites
make check-prerequisites-prod

# Test nginx config
docker exec expense-manager-nginx-production nginx -t

# Check port conflicts
sudo lsof -i :80
sudo lsof -i :443
```

### SSL Errors

```bash
# Verify certificate files exist
ls -la /etc/letsencrypt/live/yourdomain.com/

# Check certificate validity
openssl x509 -in /path/to/cert.pem -text -noout

# Test SSL connection
openssl s_client -connect yourdomain.com:443
```

### High Load

```bash
# Check resource usage
docker stats

# Review access logs for unusual patterns
tail -f logs/nginx-production/access.log | grep -E "POST|DELETE"

# Enable maintenance mode temporarily
make maintenance-enable
```

## Maintenance

### Regular Tasks

**Daily**:

- [ ] Monitor logs for errors
- [ ] Check resource usage
- [ ] Verify health endpoints

**Weekly**:

- [ ] Review access patterns
- [ ] Check for security updates
- [ ] Backup configuration

**Monthly**:

- [ ] Review and optimize rate limits
- [ ] Audit security configurations
- [ ] Update documentation

### Updates

```bash
# Pull latest changes
cd /opt/expenser/expense-manager-loadbalancer
git pull

# Test configuration
docker run --rm -v ${PWD}/nginx/nginx-production.conf:/etc/nginx/nginx.conf:ro nginx:1.25-alpine nginx -t

# Apply updates
make prod-reload

# If major changes, restart
make prod-restart
```

## Support

Need help with production deployment?

- Check [FAQ](FAQ.md)
- See [Support Guide](SUPPORT.md)
- Open an [issue](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues)
- Email: sakilahmmad71@gmail.com

---

**Congratulations!** Your load balancer is now running in production! 🎉
