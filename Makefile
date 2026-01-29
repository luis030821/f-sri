.PHONY: help build start stop restart status logs rebuild clean health mongo shell secrets env-check

# Variables
COMPOSE := docker-compose
APP := f-sri-app
MONGO := f-sri-mongodb

help:
	@echo "======================================"
	@echo "F-SRI Docker Makefile"
	@echo "======================================"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make build        - Construir imágenes Docker"
	@echo "  make start        - Iniciar servicios"
	@echo "  make stop         - Detener servicios"
	@echo "  make restart      - Reiniciar servicios"
	@echo "  make status       - Ver estado de servicios"
	@echo "  make logs         - Ver logs en tiempo real"
	@echo "  make logs-app     - Ver logs solo de app"
	@echo "  make logs-mongo   - Ver logs solo de MongoDB"
	@echo "  make rebuild      - Reconstruir y reiniciar"
	@echo "  make clean        - Limpiar volúmenes (CUIDADO: elimina datos)"
	@echo "  make health       - Verificar salud del sistema"
	@echo "  make mongo        - Acceder a MongoDB CLI"
	@echo "  make shell        - Acceder a shell de la app"
	@echo "  make secrets      - Generar variables de seguridad"
	@echo "  make env-check    - Verificar archivo .env"
	@echo "  make help         - Mostrar esta ayuda"
	@echo ""

env-check:
	@if [ ! -f ".env" ]; then \
		echo "⚠️  Archivo .env no existe"; \
		echo "Creando desde .env.docker..."; \
		cp .env.docker .env; \
		echo "✅ Archivo .env creado"; \
		echo "⚠️  IMPORTANTE: Edita .env con tus valores"; \
	else \
		echo "✅ Archivo .env existe"; \
	fi

build: env-check
	@echo "🔨 Construyendo imágenes..."
	$(COMPOSE) build
	@echo "✅ Construcción completada"

start: env-check
	@echo "🚀 Iniciando servicios..."
	$(COMPOSE) up -d
	@echo "⏳ Esperando a que MongoDB esté disponible..."
	@sleep 5
	@echo ""
	@echo "📊 Estado de servicios:"
	@$(COMPOSE) ps
	@echo ""
	@echo "✅ Servicios iniciados"
	@echo "📡 API disponible en: http://localhost:3000"
	@echo "📄 Documentación en: http://localhost:3000/docs"

stop:
	@echo "🛑 Deteniendo servicios..."
	$(COMPOSE) down
	@echo "✅ Servicios detenidos"

restart: stop start
	@echo "✅ Servicios reiniciados"

status:
	@echo "📊 Estado de servicios:"
	@$(COMPOSE) ps
	@echo ""
	@echo "🏥 Health check de la API:"
	@curl -s http://localhost:3000/health | grep -q "OK" && echo "✅ API disponible" || echo "❌ API no disponible"

logs:
	@$(COMPOSE) logs -f

logs-app:
	@$(COMPOSE) logs -f app

logs-mongo:
	@$(COMPOSE) logs -f mongodb

rebuild: clean build start
	@echo "✅ Aplicación reconstruida e iniciada"

clean:
	@echo "⚠️  CUIDADO: Esto eliminará todos los datos de la base de datos"
	@read -p "¿Estás seguro? (s/n): " confirm; \
	if [ "$$confirm" = "s" ]; then \
		$(COMPOSE) down -v; \
		echo "✅ Limpieza completada"; \
	else \
		echo "❌ Limpieza cancelada"; \
	fi

health:
	@echo "🏥 Verificando salud del sistema..."
	@echo ""
	@echo "📊 Estado de contenedores:"
	@$(COMPOSE) ps
	@echo ""
	@echo "🔍 Health check de MongoDB:"
	@$(COMPOSE) exec -T mongodb /bin/sh -c 'mongo -u sriuser -p sripassword --authenticationDatabase admin --eval "db.adminCommand(\"ping\")"' && echo "✅ MongoDB disponible" || echo "❌ MongoDB no disponible"
	@echo ""
	@echo "🔍 Health check de la API:"
	@curl -s http://localhost:3000/health && echo "" || echo "❌ API no disponible"

mongo:
	@echo "🗄️  Accediendo a MongoDB CLI..."
	@$(COMPOSE) exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin

shell:
	@echo "💻 Accediendo a shell de la aplicación..."
	@$(COMPOSE) exec app sh

secrets:
	@echo "🔐 Generando variables de seguridad..."
	@echo ""
	@echo "JWT_SECRET (32 hex chars):"
	@openssl rand -hex 32
	@echo ""
	@echo "ENCRYPTION_KEY (32 hex chars):"
	@openssl rand -hex 32
	@echo ""
	@echo "Copia estos valores a tu archivo .env"

# Comandos de desarrollo
dev-build:
	@echo "📦 Construyendo para desarrollo..."
	npm run build

dev-start:
	@echo "🚀 Iniciando servidor en desarrollo..."
	npm run dev

dev-test:
	@echo "🧪 Ejecutando tests..."
	npm run test

dev-lint:
	@echo "🔍 Ejecutando linter..."
	npm run lint

# Comandos de base de datos
db-backup:
	@echo "💾 Haciendo backup de MongoDB..."
	@mkdir -p ./backups
	@$(COMPOSE) exec mongodb mongodump \
		--uri="mongodb://sriuser:sripassword@localhost:27017/f-sri?authSource=admin" \
		--out=/tmp/backup
	@echo "✅ Backup completado en ./backups"

db-restore:
	@echo "📥 Restaurando base de datos..."
	@if [ -d "./backups" ]; then \
		$(COMPOSE) exec mongodb mongorestore \
			--uri="mongodb://sriuser:sripassword@localhost:27017" \
			/tmp/backup; \
		echo "✅ Restauración completada"; \
	else \
		echo "❌ No se encuentra directorio de backups"; \
	fi

db-shell:
	@echo "🗄️  Accediendo a MongoDB..."
	@$(COMPOSE) exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin

# Comandos de limpieza
prune-containers:
	@echo "🧹 Eliminando contenedores detenidos..."
	docker container prune -f

prune-images:
	@echo "🧹 Eliminando imágenes no usadas..."
	docker image prune -f

prune-volumes:
	@echo "🧹 Eliminando volúmenes no usados..."
	docker volume prune -f

prune-all: prune-containers prune-images prune-volumes
	@echo "✅ Limpieza completa realizada"

# Comandos de información
version:
	@echo "📦 Versiones:"
	@echo "Docker: $$(docker --version)"
	@echo "Docker Compose: $$(docker-compose --version)"
	@echo "Node (en imagen): node:20-alpine"
	@echo "MongoDB (en imagen): mongo:7.0-alpine"

ps:
	@$(COMPOSE) ps

config:
	@echo "🔧 Configuración actual:"
	@if [ -f ".env" ]; then \
		echo "Variables de entorno:"; \
		grep -E "^[^#]" .env | head -20; \
		echo "..."; \
	else \
		echo "⚠️  Archivo .env no existe"; \
	fi

# Atajos útiles
.DEFAULT_GOAL := help
