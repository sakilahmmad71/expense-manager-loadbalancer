# Configuration Examples

This directory contains example configurations for common use cases.

## Available Examples

1. **[custom-domains.conf](custom-domains.conf)** - Custom domain configuration
2. **[ssl-letsencrypt.conf](ssl-letsencrypt.conf)** - Let's Encrypt SSL configuration
3. **[rate-limiting-custom.conf](rate-limiting-custom.conf)** - Custom rate limiting rules
4. **[cors-configuration.conf](cors-configuration.conf)** - CORS headers configuration
5. **[multiple-backends.conf](multiple-backends.conf)** - Load balancing multiple backend servers
6. **[websocket-advanced.conf](websocket-advanced.conf)** - Advanced WebSocket configuration
7. **[caching.conf](caching.conf)** - Response caching configuration

## How to Use These Examples

1. Review the example that matches your use case
2. Copy relevant sections to your `nginx-production.conf` or `nginx-development.conf`
3. Modify as needed for your specific requirements
4. Test the configuration: `docker exec <container> nginx -t`
5. Reload nginx: `make dev-reload` or `make prod-reload`

## Need Help?

- Check the [FAQ](../FAQ.md)
- See the [Getting Started Guide](../GETTING_STARTED.md)
- Open an [issue](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues)
