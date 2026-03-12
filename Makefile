.DEFAULT_GOAL := help

.PHONY: help build test lint clean deploy

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the project
	docker compose build

test: ## Run tests
	docker compose run --rm app pytest -v

lint: ## Run linters
	pre-commit run --all-files

clean: ## Remove build artifacts and caches
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	docker compose down --volumes --remove-orphans

deploy: ## Deploy to production (requires SSH_HOST)
	bash deploy.sh $(SSH_HOST)
