# ==============================================================================
# Expense Manager - Load Balancer Makefile
# ==============================================================================
# This Makefile manages the Nginx Load Balancer container
# 
# Prerequisites:
# - API and App containers must be running first
# - expense-manager-network-{development|production} network must exist
#
# Usage:
#   make dev                    - Start development load balancer
#   make prod                   - Start production load balancer
#   make dev-down               - Stop development load balancer
#   make prod-down              - Stop production load balancer
#   make help                   - Show this help message
# ==============================================================================

.PHONY: help dev dev-down dev-restart dev-logs dev-status dev-reload prod prod-down prod-restart prod-logs prod-status prod-reload check-network-dev check-network-prod check-dependencies-dev check-dependencies-prod check-health-endpoints-dev check-health-endpoints-prod maintenance-enable maintenance-disable maintenance-status check-prerequisites-dev check-prerequisites-prod check-docker check-docker-compose

# Default target
.DEFAULT_GOAL := help

# Compose files
COMPOSE_FILE_DEV := docker-compose.development.yml
COMPOSE_FILE_PROD := docker-compose.production.yml
CONTAINER_NAME_DEV := expense-manager-nginx-development
CONTAINER_NAME_PROD := expense-manager-nginx-production

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

## help: Show this help message
help:
	@echo ""
	@echo "$(BLUE)Expense Manager Load Balancer - Available Commands$(NC)"
	@echo "======================================================"
	@echo ""
	@echo "$(GREEN)Development Commands:$(NC)"
	@echo "  make dev                    - Start development load balancer"
	@echo "  make dev-down               - Stop development load balancer"
	@echo "  make dev-restart            - Restart development load balancer"
	@echo "  make dev-logs               - View development logs"
	@echo "  make dev-status             - Check development status"
	@echo "  make dev-reload             - Reload config without downtime"
	@echo ""
	@echo "$(GREEN)Production Commands:$(NC)"
	@echo "  make prod                   - Start production load balancer"
	@echo "  make prod-down              - Stop production load balancer"
	@echo "  make prod-restart           - Restart production load balancer"
	@echo "  make prod-logs              - View production logs"
	@echo "  make prod-status            - Check production status"
	@echo "  make prod-reload            - Reload config without downtime"
	@echo ""
	@echo "$(GREEN)Maintenance Commands:$(NC)"
	@echo "  make maintenance-enable     - Enable maintenance mode (prod)"
	@echo "  make maintenance-disable    - Disable maintenance mode (prod)"
	@echo "  make maintenance-status     - Check maintenance mode status (prod)"
	@echo ""
	@echo "$(GREEN)Prerequisite Check Commands:$(NC)"
	@echo "  make check-docker           - Check if Docker is installed and running"
	@echo "  make check-docker-compose   - Check if Docker Compose is available"
	@echo "  make check-prerequisites-dev  - Check all development prerequisites"
	@echo "  make check-prerequisites-prod - Check all production prerequisites"
	@echo ""
	@echo "$(YELLOW)Prerequisites:$(NC)"
	@echo "  - API and App containers must be running (creates network)"
	@echo ""

# ==============================================================================
# Prerequisite Checks
# ==============================================================================

## check-docker: Check if Docker is installed and running
check-docker:
	@which docker >/dev/null 2>&1 || { echo "$(RED)❌ Error: Docker is not installed!$(NC)"; echo "$(YELLOW)Install Docker from: https://docs.docker.com/get-docker/$(NC)"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "$(RED)❌ Error: Docker daemon is not running!$(NC)"; echo "$(YELLOW)Please start Docker Desktop or Docker daemon$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Docker is installed and running$(NC)"

## check-docker-compose: Check if Docker Compose is available
check-docker-compose:
	@docker compose version >/dev/null 2>&1 || { echo "$(RED)❌ Error: Docker Compose is not available!$(NC)"; echo "$(YELLOW)Docker Compose is required (comes with Docker Desktop)$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Docker Compose is available$(NC)"

## check-network-dev: Check if development network exists
check-network-dev:
	@echo "$(BLUE)Checking for expense-manager-network-development...$(NC)"
	@if docker network inspect expense-manager-network-development >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Network exists$(NC)"; \
	else \
		echo "$(RED)✗ Network does not exist!$(NC)"; \
		echo "$(YELLOW)Please start the API containers first:$(NC)"; \
		echo "  cd ../expense-manager-apis && make dev"; \
		exit 1; \
	fi

## check-network-prod: Check if production network exists
check-network-prod:
	@echo "$(BLUE)Checking for expense-manager-network-production...$(NC)"
	@if docker network inspect expense-manager-network-production >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Network exists$(NC)"; \
	else \
		echo "$(RED)✗ Network does not exist!$(NC)"; \
		echo "$(YELLOW)Please start the API containers first:$(NC)"; \
		echo "  cd ../expense-manager-apis && make prod"; \
		exit 1; \
	fi

## check-dependencies-dev: Check if API and App containers are running (development)
check-dependencies-dev:
	@echo "$(BLUE)Checking development dependencies...$(NC)"
	@echo -n "  API container: "
	@if docker ps --filter "name=expense-manager-api-development" --format "{{.Names}}" | grep -q "expense-manager-api-development"; then \
		echo "$(GREEN)✓ Running$(NC)"; \
	else \
		echo "$(RED)✗ Not running$(NC)"; \
		echo "$(YELLOW)Please start the API containers first:$(NC)"; \
		echo "  cd ../expense-manager-apis && make dev"; \
		exit 1; \
	fi
	@echo -n "  App container: "
	@if docker ps --filter "name=expense-manager-app-development" --format "{{.Names}}" | grep -q "expense-manager-app-development"; then \
		echo "$(GREEN)✓ Running$(NC)"; \
	else \
		echo "$(RED)✗ Not running$(NC)"; \
		echo "$(YELLOW)Please start the App containers first:$(NC)"; \
		echo "  cd ../expense-manager-app && make dev"; \
		exit 1; \
	fi
	@$(MAKE) check-network-dev

## check-dependencies-prod: Check if API and App containers are running (production)
check-dependencies-prod:
	@echo "$(BLUE)Checking production dependencies...$(NC)"
	@echo -n "  API container: "
	@if docker ps --filter "name=expense-manager-api-production" --format "{{.Names}}" | grep -q "expense-manager-api-production"; then \
		echo "$(GREEN)✓ Running$(NC)"; \
	else \
		echo "$(RED)✗ Not running$(NC)"; \
		echo "$(YELLOW)Please start the API containers first:$(NC)"; \
		echo "  cd ../expense-manager-apis && make prod"; \
		exit 1; \
	fi
	@echo -n "  App container: "
	@if docker ps --filter "name=expense-manager-app-production" --format "{{.Names}}" | grep -q "expense-manager-app-production"; then \
		echo "$(GREEN)✓ Running$(NC)"; \
	else \
		echo "$(RED)✗ Not running$(NC)"; \
		echo "$(YELLOW)Please start the App containers first:$(NC)"; \
		echo "  cd ../expense-manager-app && make prod"; \
		exit 1; \
	fi
	@$(MAKE) check-network-prod

## check-prerequisites-dev: Check all prerequisites for development
check-prerequisites-dev: check-docker check-docker-compose check-dependencies-dev
	@echo "$(GREEN)✅ All development prerequisites are met!$(NC)"

## check-prerequisites-prod: Check all prerequisites for production
check-prerequisites-prod: check-docker check-docker-compose check-dependencies-prod
	@echo "$(GREEN)✅ All production prerequisites are met!$(NC)"

# ==============================================================================
# Development Environment
# ==============================================================================

## dev: Start development load balancer
dev: check-prerequisites-dev
	@echo "$(BLUE)Starting Development Load Balancer...$(NC)"
	@docker compose -f $(COMPOSE_FILE_DEV) up -d
	@echo "$(GREEN)✓ Development load balancer started successfully$(NC)"
	@echo ""
	@echo "Access points:"
	@echo "  - HTTP:  http://localhost:80"
	@echo "  - API:   http://localhost:80/api"
	@echo "  - App:   http://localhost:80"
	@echo ""
	@$(MAKE) dev-status

## dev-down: Stop development load balancer
dev-down:
	@echo "$(BLUE)Stopping Development Load Balancer...$(NC)"
	@docker compose -f $(COMPOSE_FILE_DEV) down
	@echo "$(GREEN)✓ Development load balancer stopped successfully$(NC)"

## dev-restart: Restart development load balancer
dev-restart:
	@echo "$(BLUE)Restarting Development Load Balancer...$(NC)"
	@docker compose -f $(COMPOSE_FILE_DEV) restart
	@echo "$(GREEN)✓ Development load balancer restarted successfully$(NC)"
	@$(MAKE) dev-status

## dev-logs: View development logs
dev-logs:
	@echo "$(BLUE)Viewing Development Logs (Ctrl+C to exit)...$(NC)"
	@docker logs $(CONTAINER_NAME_DEV) -f

## dev-status: Check development status
dev-status:
	@echo "$(BLUE)Development Load Balancer Status:$(NC)"
	@docker ps --filter "name=$(CONTAINER_NAME_DEV)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "$(RED)✗ Load balancer is not running$(NC)"

## dev-reload: Reload development configuration without downtime
dev-reload:
	@echo "$(BLUE)Reloading Development Configuration...$(NC)"
	@docker exec $(CONTAINER_NAME_DEV) nginx -t && docker exec $(CONTAINER_NAME_DEV) nginx -s reload
	@echo "$(GREEN)✓ Configuration reloaded successfully$(NC)"

# ==============================================================================
# Production Environment
# ==============================================================================

## prod: Start production load balancer
prod: check-prerequisites-prod
	@echo "$(BLUE)Starting Production Load Balancer...$(NC)"
	@docker compose -f $(COMPOSE_FILE_PROD) up -d
	@echo "$(GREEN)✓ Production load balancer started successfully$(NC)"
	@echo ""
	@echo "Access points:"
	@echo "  - HTTP:  http://localhost:80"
	@echo "  - HTTPS: https://localhost:443"
	@echo "  - API:   https://your-domain.com/api"
	@echo "  - App:   https://your-domain.com"
	@echo ""
	@$(MAKE) prod-status

## prod-down: Stop production load balancer
prod-down:
	@echo "$(BLUE)Stopping Production Load Balancer...$(NC)"
	@docker compose -f $(COMPOSE_FILE_PROD) down
	@echo "$(GREEN)✓ Production load balancer stopped successfully$(NC)"

## prod-restart: Restart production load balancer
prod-restart:
	@echo "$(BLUE)Restarting Production Load Balancer...$(NC)"
	@docker compose -f $(COMPOSE_FILE_PROD) restart
	@echo "$(GREEN)✓ Production load balancer restarted successfully$(NC)"
	@$(MAKE) prod-status

## prod-logs: View production logs
prod-logs:
	@echo "$(BLUE)Viewing Production Logs (Ctrl+C to exit)...$(NC)"
	@docker logs $(CONTAINER_NAME_PROD) -f

## prod-status: Check production status
prod-status:
	@echo "$(BLUE)Production Load Balancer Status:$(NC)"
	@docker ps --filter "name=$(CONTAINER_NAME_PROD)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "$(RED)✗ Load balancer is not running$(NC)"

## prod-reload: Reload production configuration without downtime
prod-reload:
	@echo "$(BLUE)Reloading Production Configuration...$(NC)"
	@docker exec $(CONTAINER_NAME_PROD) nginx -t && docker exec $(CONTAINER_NAME_PROD) nginx -s reload
	@echo "$(GREEN)✓ Configuration reloaded successfully$(NC)"

## maintenance-enable: Enable maintenance mode
maintenance-enable:
	@echo "$(YELLOW)Enabling maintenance mode...$(NC)"
	@docker exec $(CONTAINER_NAME_PROD) touch /etc/nginx/maintenance.flag
	@docker exec $(CONTAINER_NAME_PROD) nginx -s reload
	@echo "$(GREEN)✓ Maintenance mode enabled$(NC)"
	@echo "$(YELLOW)All requests will now show the maintenance page$(NC)"

## maintenance-disable: Disable maintenance mode
maintenance-disable:
	@echo "$(BLUE)Disabling maintenance mode...$(NC)"
	@docker exec $(CONTAINER_NAME_PROD) rm -f /etc/nginx/maintenance.flag
	@docker exec $(CONTAINER_NAME_PROD) nginx -s reload
	@echo "$(GREEN)✓ Maintenance mode disabled$(NC)"
	@echo "$(GREEN)Services are now accessible$(NC)"

## maintenance-status: Check maintenance mode status
maintenance-status:
	@echo "$(BLUE)Maintenance Mode Status:$(NC)"
	@if docker exec $(CONTAINER_NAME_PROD) test -f /etc/nginx/maintenance.flag 2>/dev/null; then \
		echo "$(YELLOW)⚠ Maintenance mode is ENABLED$(NC)"; \
		echo "To disable: make maintenance-disable"; \
	else \
		echo "$(GREEN)✓ Maintenance mode is DISABLED (normal operation)$(NC)"; \
		echo "To enable: make maintenance-enable"; \
	fi
