# 🚀 INSTRUCCIONES PARA INICIAR F-SRI CON DOCKER

## ⚡ Inicio Rápido (5 minutos)

### Paso 1: Preparar Variables de Entorno

```bash
# Copiar plantilla
cp .env.docker .env
```

### Paso 2: Generar Secretos Seguros

```bash
# En Linux/Mac con script
chmod +x generate-secrets.sh
./generate-secrets.sh

# En Windows (abre PowerShell y copia los comandos que aparecen)
generate-secrets.bat

# O generar manualmente
openssl rand -hex 32  # JWT_SECRET
openssl rand -hex 32  # ENCRYPTION_KEY
```

### Paso 3: Editar .env

```bash
# Editar el archivo .env con tus valores
# IMPORTANTE: Al menos cambiar:
# - MONGO_PASSWORD
# - JWT_SECRET (pegar valor generado)
# - ENCRYPTION_KEY (pegar valor generado)

nano .env  # O tu editor favorito
```

### Paso 4: Iniciar Servicios

```bash
# Con script (recomendado)
./deploy.sh start        # Linux/Mac
deploy.bat start         # Windows

# O con docker-compose directo
docker-compose up -d
```

### Paso 5: Verificar

```bash
# Ver estado (esperar ~60 segundos para que MongoDB sea healthy)
docker-compose ps

# Ver logs de MongoDB si hay problemas
docker-compose logs mongodb

# Health check de la API (cuando MongoDB esté healthy)
curl http://localhost:3000/health

# Ver logs de la app
docker-compose logs -f app

# API docs
open http://localhost:3000/docs
```

---

## ⚠️ Si Puerto 3000 Está en Uso

Si ves: `Bind for :::3000 failed: port is already allocated`

```bash
# 1. Cambiar puerto en .env
nano .env
# Cambiar: PORT=3000
# A: PORT=3001

# 2. Reconstruir
docker-compose down
docker-compose up -d

# 3. Acceder con nuevo puerto
curl http://localhost:3001/health
```

Ver: `FIX_PORT_IN_USE.md` para más opciones.

---

## ⚠️ Si MongoDB Falla (unhealthy)

Si ves: `Container f-sri-mongodb is unhealthy`

```bash
# 1. Ver logs de MongoDB
docker-compose logs mongodb

# 2. Esperar más tiempo (hasta 60 segundos)
# MongoDB puede tardar en iniciar

# 3. Si sigue fallando, reconstruir:
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

# 4. Esperar y verificar:
docker-compose ps  # MongoDB debe mostrar "healthy"
```

Ver: `FIX_MONGODB_HEALTH.md` para más detalles.

---

## 📋 Archivos Principales

### 🐳 Docker

- `Dockerfile` - Imagen de la aplicación
- `docker-compose.yml` - Configuración de servicios
- `.dockerignore` - Archivos a ignorar

### 🔧 Configuración

- `.env.docker` - Plantilla de variables (RENOMBRA A `.env`)
- `init-mongo.js` - Inicialización de MongoDB

### 🚀 Scripts

- `deploy.sh` - Linux/Mac (11 comandos útiles)
- `deploy.bat` - Windows (11 comandos útiles)
- `Makefile` - Linux/Mac (comandos make)
- `generate-secrets.sh` - Generar secretos (Linux/Mac)
- `generate-secrets.bat` - Generar secretos (Windows)

### 📚 Documentación

- `README_DOCKER.md` - Inicio rápido
- `DOCKER_READY.md` - Resumen ejecutivo
- `DOCKER_DEPLOY.md` - Guía completa
- `DOCKER_CONFIG.md` - Documentación técnica
- `SETUP_COMPLETE.md` - Estado de configuración

---

## 🎯 Comandos Más Usados

### Iniciar/Detener

```bash
# Iniciar
docker-compose up -d

# Detener
docker-compose down

# Reconstruir y reiniciar
docker-compose build
docker-compose up -d
```

### Ver Información

```bash
# Estado
docker-compose ps

# Logs en tiempo real
docker-compose logs -f app

# Health check
curl http://localhost:3000/health
```

### Acceso a Servicios

```bash
# MongoDB CLI
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin

# Shell de la app
docker-compose exec app sh
```

---

## 🔐 Variables Críticas para Producción

| Variable          | Acción  | Comando                |
| ----------------- | ------- | ---------------------- |
| `JWT_SECRET`      | Generar | `openssl rand -hex 32` |
| `ENCRYPTION_KEY`  | Generar | `openssl rand -hex 32` |
| `MONGO_PASSWORD`  | Cambiar | Contraseña fuerte      |
| `ALLOWED_ORIGINS` | Cambiar | Tu dominio real        |
| `NODE_ENV`        | Cambiar | `production`           |
| `SRI_ENVIRONMENT` | Cambiar | `2` (para producción)  |

---

## 📍 Endpoints Disponibles

```
API Health:        http://localhost:3000/health
API Docs:          http://localhost:3000/docs
Swagger JSON:      http://localhost:3000/swagger.json
API Base:          http://localhost:3000/api/v1
```

---

## 🆘 Solución de Problemas

### Puerto 3000 ya está en uso

```bash
# Cambiar en .env: PORT=3001
# Luego reconstruir
docker-compose down
docker-compose up -d
```

### MongoDB no inicia

```bash
# Ver logs
docker-compose logs mongodb

# Limpiar y reiniciar
docker-compose down -v
docker-compose up -d
```

### App no puede conectar a MongoDB

```bash
# Verificar credenciales en .env
# El hostname DEBE ser "mongodb"
# Ver logs: docker-compose logs app
```

---

## ✅ Checklist

- [ ] `.env` creado desde `.env.docker`
- [ ] Secretos generados (JWT_SECRET, ENCRYPTION_KEY)
- [ ] MONGO_PASSWORD cambiada
- [ ] ALLOWED_ORIGINS configurada
- [ ] EMAIL_USER y EMAIL_PASSWORD configuradas (si aplica)
- [ ] `docker-compose up -d` ejecutado
- [ ] `docker-compose ps` muestra 2 contenedores
- [ ] `curl http://localhost:3000/health` responde OK
- [ ] Logs no muestran errores
- [ ] API docs accesible en http://localhost:3000/docs

---

## 📞 Documentación

Para más información, consulta:

- `README_DOCKER.md` - Quick start
- `DOCKER_DEPLOY.md` - Guía completa
- `DOCKER_CONFIG.md` - Detalles técnicos

---

## 🎉 ¡Listo!

Ya está todo configurado. Ahora puedes:

1. **Desarrollar localmente** con `docker-compose up -d`
2. **Desplegar en producción** cambiando variables de entorno
3. **Escalar servicios** agregando más contenedores
4. **Monitorear** con los logs y health checks

Para ayuda detallada, lee los archivos de documentación.
