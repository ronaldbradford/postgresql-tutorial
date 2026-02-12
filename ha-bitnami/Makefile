.PHONY: start stop build up down check-no-containers check-pg-containers

COMPOSE := docker compose

start: check-no-containers build up check-pg-containers

stop: down

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down -v

check-no-containers:
	@count=$$(docker ps -q | wc -l | tr -d ' '); \
	if [ "$$count" -ne 0 ]; then \
		echo "Error: $$count containers already running. Stop them first."; \
		exit 1; \
	fi
	@echo "OK: No containers running"

check-pg-containers:
	@count=$$(docker ps -q --filter "expose=5432" | wc -l | tr -d ' '); \
	if [ "$$count" -ne 2 ]; then \
		echo "Error: Expected 2 PostgreSQL containers, found $$count"; \
		exit 1; \
	fi
	@echo "OK: 2 PostgreSQL containers running"
