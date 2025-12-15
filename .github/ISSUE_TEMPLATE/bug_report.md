---
name: 🐛 Bug Report
about: Report a bug to help us improve the Load Balancer
title: '[BUG] '
labels: ['bug', 'needs-triage']
assignees: []
---

## 🐛 Bug Description

<!-- A clear and concise description of what the bug is -->

## 🔄 Steps to Reproduce

<!-- Steps to reproduce the behavior -->

1. Start load balancer with '...'
2. Send request to '...'
3. With configuration '...'
4. See error

## ✅ Expected Behavior

<!-- A clear and concise description of what you expected to happen -->

## ❌ Actual Behavior

<!-- A clear and concise description of what actually happened -->

## 🖼️ Screenshots/Logs

<!-- If applicable, add screenshots or error logs to help explain your problem -->

**Nginx Logs:**

```
Paste nginx logs here
```

**Docker Logs:**

```
Paste docker logs here
```

## 🌍 Environment

<!-- Please complete the following information -->

- **OS:** [e.g. macOS, Ubuntu 22.04, Windows]
- **Docker Version:** [e.g. 24.0.6]
- **Docker Compose Version:** [e.g. 2.21.0]
- **Nginx Version:** [e.g. nginx:1.25-alpine]
- **Environment:** [Development / Production]

## 🔧 Configuration

<!-- Please share relevant configuration (remove sensitive information) -->

- **Compose File:** [docker-compose.development.yml / docker-compose.production.yml]
- **Nginx Config:** [nginx-development.conf / nginx-production.conf]
- **Custom Modifications:** [Yes / No - describe if yes]

## 🌐 Network Details

<!-- If the bug is related to routing or networking -->

- **Affected Endpoint:** [e.g. http://localhost/api/health]
- **Backend Status:** [Running / Not Running / Unknown]
- **Port Mappings:** [e.g. 80:80, 443:443]
- **Docker Network:** [expense-manager-network-development / production]

## 📋 Backend Services

<!-- Status of related services -->

- [ ] API container is running
- [ ] App container is running
- [ ] Docker network exists
- [ ] Can access backends directly (bypassing load balancer)

## ✅ Troubleshooting Steps Taken

<!-- What have you tried so far? -->

- [ ] Ran `make check-prerequisites-dev` (or prod)
- [ ] Tested nginx configuration with `nginx -t`
- [ ] Checked nginx error logs
- [ ] Checked docker logs
- [ ] Restarted containers
- [ ] Verified backend services are accessible

## 📎 Additional Context

<!-- Add any other context about the problem here -->

## 🔗 Related Issues

<!-- Link to any related issues -->
