# Contributing to Expenser Load Balancer

Thank you for your interest in contributing to the Expenser Load Balancer! This nginx-based load balancer is a critical component of the Expenser infrastructure.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Configuration Guidelines](#configuration-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## 📜 Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## 🤝 How Can I Contribute?

### Reporting Issues

- Configuration errors
- Performance problems
- Security concerns
- Documentation improvements

### Suggesting Improvements

- Rate limiting strategies
- Caching optimizations
- Security enhancements
- Health check improvements

## 🛠️ Development Setup

### Prerequisites

- Docker & Docker Compose
- Basic nginx knowledge
- Running API and App containers

### Setup Steps

1. **Fork and Clone**

```bash
git clone https://github.com/YOUR_USERNAME/expense-manager-loadbalancer.git
cd expense-manager-loadbalancer
```

2. **Ensure Dependencies Running**

```bash
# Start API
cd ../expense-manager-apis && make dev

# Start App
cd ../expense-manager-app && make dev
```

3. **Start Load Balancer**

```bash
# Development
make dev

# View logs
make dev-logs
```

## ⚙️ Configuration Guidelines

### Nginx Configuration

Located in `nginx/` directory:

- `nginx-development.conf` - Development environment
- `nginx-production.conf` - Production environment
- `maintenance.html` - Maintenance page

### Key Configuration Areas

**1. Upstream Definitions**

```nginx
upstream api_backend {
    server expense-manager-api:3000;
    keepalive 32;
}
```

**2. Rate Limiting**

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
```

**3. Security Headers**

```nginx
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
```

**4. Health Checks**

```nginx
location /health {
    access_log off;
    return 200 "healthy\n";
}
```

### Best Practices

- **Test configurations** before committing
- **Use variables** for repeated values
- **Add comments** for complex rules
- **Follow nginx naming conventions**
- **Consider performance impact**

## 🧪 Testing

### Configuration Testing

```bash
# Test nginx config
docker exec expense-manager-loadbalancer nginx -t

# Reload without downtime
docker exec expense-manager-loadbalancer nginx -s reload
```

### Manual Testing

1. **Test routing**

```bash
# API endpoint
curl http://localhost/api/health

# App endpoint
curl http://localhost/
```

2. **Test rate limiting**

```bash
# Rapid requests to trigger rate limit
for i in {1..20}; do curl http://localhost/api/health; done
```

3. **Test compression**

```bash
curl -H "Accept-Encoding: gzip" -I http://localhost/
```

4. **Test security headers**

```bash
curl -I http://localhost/ | grep -E "X-Frame-Options|X-Content-Type-Options"
```

### Performance Testing

```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost/api/health

# Using wrk
wrk -t4 -c100 -d30s http://localhost/api/health
```

## 💬 Commit Messages

Use conventional commit format:

```
<type>(<scope>): <subject>

<body>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `perf`: Performance improvement
- `security`: Security enhancement
- `docs`: Documentation
- `config`: Configuration changes

**Examples:**

```
feat(rate-limit): add stricter API rate limiting

Reduce API rate limit from 100 to 50 requests per minute
to prevent abuse and improve stability.
```

```
security(headers): add CSP header

Add Content-Security-Policy header to prevent XSS attacks.
```

## 🔀 Pull Request Process

### Before Submitting

1. ✅ Test nginx configuration (`nginx -t`)
2. ✅ Verify routing works correctly
3. ✅ Check logs for errors
4. ✅ Update documentation
5. ✅ Test in both dev and prod configs

### PR Guidelines

1. **Clear description** of changes
2. **Justification** for configuration changes
3. **Testing results** included
4. **Performance impact** noted
5. **Security implications** considered

## 🔒 Security

### Security-Related Changes

When modifying security configurations:

- Explain the security benefit
- Consider backward compatibility
- Test thoroughly
- Document any breaking changes

### Reporting Vulnerabilities

Email sakilahmmad71@gmail.com for security issues.

## 📚 Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Nginx Best Practices](https://www.nginx.com/blog/tuning-nginx/)
- [Docker Nginx](https://hub.docker.com/_/nginx)

## 📝 Configuration Checklist

When modifying configs:

- [ ] Tested with `nginx -t`
- [ ] Verified routing works
- [ ] Checked logs for errors
- [ ] Tested rate limiting
- [ ] Verified security headers
- [ ] Tested compression
- [ ] Updated documentation
- [ ] Tested in both environments

## 📧 Contact

- **Maintainer**: Shakil Ahmed
- **Email**: sakilahmmad71@gmail.com
- **GitHub**: [@sakilahmmad71](https://github.com/sakilahmmad71)

---

Happy Contributing! 🚀
