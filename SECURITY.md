# Security Policy

## Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of the Expenser Load Balancer seriously. If you discover a security vulnerability, please follow these steps:

### 🔒 Private Reporting (Preferred)

1. **Email**: Send details to [sakilahmmad71@gmail.com](mailto:sakilahmmad71@gmail.com)
2. **Subject**: Start with `[SECURITY]` followed by a brief description
3. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Affected nginx configurations
   - Suggested fix (if available)

### 📋 What to Include

Please provide as much information as possible:

- **Vulnerability Type**: (e.g., Rate limiting bypass, Header injection, etc.)
- **Affected Components**: Which nginx configuration files
- **Attack Scenario**: How the vulnerability could be exploited
- **Proof of Concept**: Safe reproduction steps
- **Environment**: Development/Production configuration

### ⏱️ Response Timeline

- **Initial Response**: Within 24 hours
- **Acknowledgment**: Within 48 hours
- **Status Updates**: Weekly until resolution
- **Fix Timeline**: Critical issues within 7 days, others within 30 days

### 🛡️ Security Best Practices

When configuring the load balancer:

#### Nginx Configuration Security

1. **Rate Limiting**

   ```nginx
   # Implement appropriate rate limits
   limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
   ```

2. **Security Headers**

   ```nginx
   # Always include security headers
   add_header X-Frame-Options "DENY";
   add_header X-Content-Type-Options "nosniff";
   add_header X-XSS-Protection "1; mode=block";
   ```

3. **Access Logging**
   ```nginx
   # Monitor access patterns
   access_log /var/log/nginx/access.log combined;
   error_log /var/log/nginx/error.log warn;
   ```

#### Docker Security

1. **Run as non-root user** (when possible)
2. **Use specific nginx version** (avoid `latest` tag)
3. **Limit container resources**
4. **Keep base images updated**

#### Network Security

1. **Use internal Docker networks**
2. **Expose only necessary ports**
3. **Implement proper SSL/TLS termination**
4. **Regular SSL certificate updates**

### 🚨 Common Security Issues

#### High Priority Issues

- **Unrestricted proxy access** to internal services
- **Missing rate limiting** on critical endpoints
- **Weak SSL/TLS configuration**
- **Exposed admin interfaces**
- **Information disclosure** in error pages

#### Medium Priority Issues

- **Missing security headers**
- **Verbose error messages** in production
- **Unencrypted internal communication**
- **Weak access logging**

#### Low Priority Issues

- **Version disclosure** in server headers
- **Unnecessary nginx modules** enabled
- **Overly permissive CORS** policies

### 🔍 Security Testing

Regular security testing should include:

1. **Configuration Reviews**

   ```bash
   # Test nginx configuration
   nginx -t

   # Check for common misconfigurations
   curl -I http://localhost/ | grep -i server
   ```

2. **Rate Limiting Tests**

   ```bash
   # Test rate limits
   for i in {1..20}; do curl http://localhost/api/health; done
   ```

3. **Header Security Tests**
   ```bash
   # Check security headers
   curl -I http://localhost/ | grep -E "X-Frame|X-Content|X-XSS"
   ```

### 📚 Security Resources

- [OWASP Nginx Security](https://cheatsheetseries.owasp.org/cheatsheets/Nginx_Security_Cheat_Sheet.html)
- [Nginx Security Best Practices](https://www.nginx.com/blog/mitigating-ddos-attacks-with-nginx-and-nginx-plus/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### 🏆 Security Hall of Fame

We acknowledge security researchers who responsibly disclose vulnerabilities:

_No reports yet - be the first!_

### 📞 Contact

For security-related questions or concerns:

- **Security Email**: [sakilahmmad71@gmail.com](mailto:sakilahmmad71@gmail.com)
- **Maintainer**: Shakil Ahmed ([@sakilahmmad71](https://github.com/sakilahmmad71))

---

Thank you for helping keep the Expenser Load Balancer secure! 🔒
