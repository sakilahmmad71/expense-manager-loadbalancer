# Support

Looking for help with the Expenser Load Balancer? Here are the best ways to get support:

## 📚 Documentation

Before reaching out, please check our comprehensive documentation:

- **[README.md](README.md)** - Complete setup and configuration guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines and development setup
- **[SECURITY.md](SECURITY.md)** - Security guidelines and reporting vulnerabilities
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## 🐛 Issues and Bugs

If you've found a bug or are experiencing issues:

1. **Search existing issues** first to avoid duplicates
2. **Create a new issue** using our templates:
   - [Bug Report](.github/ISSUE_TEMPLATE/bug_report.yml) - For reporting bugs
   - [Feature Request](.github/ISSUE_TEMPLATE/feature_request.yml) - For suggesting improvements
   - [Configuration Help](.github/ISSUE_TEMPLATE/help_request.yml) - For setup assistance
   - [Security Issue](.github/ISSUE_TEMPLATE/security_issue.yml) - For security concerns

## 💬 Community Support

- **[GitHub Discussions](https://github.com/sakilahmmad71/expense-manager-loadbalancer/discussions)** - Ask questions, share ideas, and get community help
- **[GitHub Issues](https://github.com/sakilahmmad71/expense-manager-loadbalancer/issues)** - Report bugs or request features

## 📧 Direct Contact

For sensitive issues or direct support:

- **Email**: [sakilahmmad71@gmail.com](mailto:sakilahmmad71@gmail.com)
- **Security Issues**: Please email for sensitive vulnerabilities instead of creating public issues

## 🚀 Getting Started

If you're new to the project:

1. **Read the [README.md](README.md)** for complete setup instructions
2. **Check Prerequisites** using `make check-prerequisites-dev`
3. **Start with Development** environment using `make dev`
4. **Review logs** with `make dev-logs` if you encounter issues

## 📋 Before Asking for Help

To help us provide better support, please:

1. **Check the documentation** and existing issues first
2. **Include relevant details**:
   - Environment (development/production)
   - Operating system
   - Docker version
   - Error messages or logs
   - Configuration files (remove sensitive info)

## ⚡ Quick Troubleshooting

### Common Issues

**Load balancer won't start:**

```bash
make check-prerequisites-dev  # Check if API/App are running
docker ps | grep expense-manager  # Verify containers
make dev-logs  # Check logs for errors
```

**Configuration errors:**

```bash
docker exec expense-manager-nginx-development nginx -t  # Test config
make dev-restart  # Restart with fresh config
```

**Port conflicts:**

```bash
lsof -i :80  # Check what's using port 80
docker ps  # Check for conflicting containers
```

### Useful Commands

```bash
make help                    # Show all available commands
make dev-status              # Check container status
make dev-reload              # Reload config without restart
make maintenance-status      # Check maintenance mode
```

## 🤝 Contributing

Want to contribute? Great! Please see our [Contributing Guide](CONTRIBUTING.md) for:

- Development setup
- Coding standards
- Pull request process
- Testing guidelines

## 📞 Response Times

- **GitHub Issues**: Usually within 24-48 hours
- **Email**: Within 24 hours for urgent issues
- **Security Issues**: Within 24 hours

## 🔗 Related Projects

The load balancer is part of the Expenser ecosystem:

- [Expenser API](https://github.com/sakilahmmad71/expense-manager-apis)
- [Expenser App](https://github.com/sakilahmmad71/expense-manager-app)
- [Expenser Landing](https://github.com/sakilahmmad71/expense-manager-landing)

---

Thank you for using the Expenser Load Balancer! 🚀
