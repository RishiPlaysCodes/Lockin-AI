# ============================================================
# Focus Guardian AI - Makefile
# Common development and deployment commands
# ============================================================

.PHONY: help install dev test lint format migrate run docker-up docker-down clean

PYTHON := python
PIP := pip
MANAGE := $(PYTHON) src/manage.py
DOCKER_COMPOSE := docker compose

# Default target
help: ## Show this help message
	@echo "Focus Guardian AI - Available Commands:"
	@echo "========================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ============================================================
# Development
# ============================================================

install: ## Install all dependencies
	$(PIP) install -r requirements/development.txt

dev: ## Run development server
	$(MANAGE) runserver 0.0.0.0:8000

shell: ## Open Django shell
	$(MANAGE) shell_plus --ipython 2>/dev/null || $(MANAGE) shell

# ============================================================
# Database
# ============================================================

migrate: ## Run database migrations
	$(MANAGE) makemigrations
	$(MANAGE) migrate

migrations: ## Create new migrations
	$(MANAGE) makemigrations

reset-db: ## Reset database (DESTRUCTIVE)
	$(MANAGE) flush --noinput
	$(MANAGE) migrate

createsuperuser: ## Create admin superuser
	$(MANAGE) createsuperuser

# ============================================================
# Testing
# ============================================================

test: ## Run all tests
	pytest

test-verbose: ## Run tests with verbose output
	pytest -v --tb=long

test-cov: ## Run tests with coverage report
	pytest --cov=core --cov-report=term-missing --cov-report=html

test-fast: ## Run tests excluding slow tests
	pytest -m "not slow"

# ============================================================
# Code Quality
# ============================================================

lint: ## Run linters
	ruff check src/ tests/
	ruff format --check src/ tests/

format: ## Auto-format code
	ruff format src/ tests/
	ruff check --fix src/ tests/

typecheck: ## Run type checking
	mypy src/

# ============================================================
# Docker
# ============================================================

docker-build: ## Build Docker image
	docker build -t focus-guardian-ai .

docker-up: ## Start all services with docker compose
	$(DOCKER_COMPOSE) up -d

docker-down: ## Stop all services
	$(DOCKER_COMPOSE) down

docker-logs: ## View docker logs
	$(DOCKER_COMPOSE) logs -f web

docker-dev: ## Start development environment
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml up -d

docker-dev-down: ## Stop development environment
	$(DOCKER_COMPOSE) -f docker-compose.dev.yml down

# ============================================================
# Production
# ============================================================

collectstatic: ## Collect static files
	$(MANAGE) collectstatic --noinput

check-deploy: ## Run Django deployment checks
	$(MANAGE) check --deploy

# ============================================================
# Cleanup
# ============================================================

clean: ## Clean up generated files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache htmlcov .coverage
	rm -rf src/staticfiles
