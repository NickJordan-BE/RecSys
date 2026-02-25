# Makefile

.PHONY: setup dev clean

setup: ## Run full environmental setup
		@chmod +x scripts/setup.sh
		@./scripts/setup.sh

dev: ## Deploy applications to the cluster via Tilt
		cd dev && tilt up

clean: ## Destroy Kind Cluster and clean environment
		@kind delete cluster --name recsys-cluster-dev
