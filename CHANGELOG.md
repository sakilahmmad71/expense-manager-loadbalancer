# Changelog

All notable changes to the Expenser Load Balancer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Open source release preparation
- Comprehensive documentation
- Security policy and guidelines
- Code of conduct for contributors

### Changed

- Updated README with detailed configuration options
- Improved error handling and logging
- Enhanced security headers configuration

### Security

- Added comprehensive security guidelines
- Implemented stricter rate limiting defaults
- Enhanced access logging for security monitoring

## [1.0.0] - 2025-12-15

### Added

- Initial release of Expenser Load Balancer
- Nginx-based reverse proxy for API and App routing
- Development and production environment configurations
- Rate limiting for API endpoints
- Security headers implementation
- Health check endpoints
- Maintenance mode functionality
- Docker Compose configurations for both environments
- Comprehensive Makefile for easy operations
- Log rotation and management
- WebSocket support for development (Vite HMR)
- Domain-based routing for production
- SSL/TLS ready configuration
- Resource limits and monitoring

### Configuration Features

- **Development Environment**:

  - HTTP-only configuration (port 80)
  - Localhost-based routing
  - WebSocket proxy for Vite HMR
  - Debug-friendly logging
  - Auto-restart containers

- **Production Environment**:
  - HTTPS-ready (ports 80 and 443)
  - Domain-based virtual hosts
  - Rate limiting (100 req/s general, 10 req/s auth)
  - Connection limits (20 API, 30 App per IP)
  - Gzip compression
  - Security headers
  - Separate log files per service
  - Maintenance mode support

### Security

- **Rate Limiting**: Configurable per endpoint
- **Security Headers**:
  - X-Frame-Options
  - X-Content-Type-Options
  - X-XSS-Protection
  - Referrer-Policy
- **Connection Limits**: IP-based restrictions
- **Access Logging**: Comprehensive request tracking

### Operational Features

- **Health Checks**: Built-in endpoint monitoring
- **Maintenance Mode**: Graceful service downtime
- **Log Management**: Organized by environment and service
- **Configuration Testing**: Built-in nginx config validation
- **Zero-Downtime Reloads**: Configuration updates without restart

### Make Targets

- **Development**: `dev`, `dev-down`, `dev-restart`, `dev-logs`, `dev-status`, `dev-reload`
- **Production**: `prod`, `prod-down`, `prod-restart`, `prod-logs`, `prod-status`, `prod-reload`
- **Maintenance**: `maintenance-enable`, `maintenance-disable`, `maintenance-status`
- **Prerequisites**: `check-docker`, `check-docker-compose`, `check-prerequisites-dev`, `check-prerequisites-prod`

### Docker Configuration

- **Base Image**: nginx:1.25-alpine
- **Networks**: External networks created by API containers
- **Volumes**: Configuration files, logs, maintenance page
- **Resource Limits**: CPU and memory constraints for production

---

## Contributing

See our [Contributing Guide](CONTRIBUTING.md) for details on how to contribute to this project.

## Security

See our [Security Policy](SECURITY.md) for information on reporting security vulnerabilities.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
