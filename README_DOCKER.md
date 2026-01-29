# 🎉 Configuración Docker Completada para F-SRI

## ✅ Archivos Creados/Configurados

### 🐳 Docker (3 archivos)

1. **Dockerfile** - Imagen multi-stage optimizada
2. **docker-compose.yml** - Orquestación completa (App + MongoDB)
3. **.dockerignore** - Optimización de imagen

### 🔧 Configuración (2 archivos)

4. **.env.docker** - Variables de entorno con documentación
5. **init-mongo.js** - Script de inicialización de MongoDB con índices

### 🚀 Scripts de Utilidad (2 archivos)

6. **deploy.sh** - Script para Linux/Mac (11 comandos)
7. **deploy.bat** - Script para Windows (11 comandos)

### 📚 Documentación (3 archivos)

8. **DOCKER_READY.md** - Este archivo: resumen de configuración
9. **DOCKER_DEPLOY.md** - Guía detallada de despliegue
10. **DOCKER_CONFIG.md** - Documentación técnica completa

---

## 🎯 Lo que está configurado

### ✨ Dockerfile

- ✅ Build multi-stage (Builder + Runtime)
- ✅ Node.js 20 Alpine (ligero y seguro)
- ✅ Usuario no-root (nodejs:nodejs)
- ✅ Instalación optimizada de dependencias
- ✅ Health check automático
- ✅ dumb-init para manejo de signals
- ✅ Compilación TypeScript incluida

### 🎯 docker-compose.yml

- ✅ **MongoDB 7.0** con almacenamiento persistente
  - Usuario/contraseña configurables
  - Health check automático
  - Volúmenes para data y config
  - Script de inicialización automático
- ✅ **Aplicación F-SRI** con todas las variables
  - Construida desde Dockerfile
  - Depende de MongoDB (espera health check)
  - Volúmenes para PDFs y logs
  - Logging centralizado
  - Network interno seguro

### 🔐 Seguridad

- ✅ Usuario no-root en contenedores
- ✅ Autenticación MongoDB habilitada
- ✅ Network interno (f-sri-network)
- ✅ Credenciales por variables de entorno
- ✅ Health checks automáticos

### 🗄️ Base de Datos

- ✅ MongoDB 7.0 Alpine
- ✅ Inicialización automática con índices:
  - users, issuingcompanies, clients
  - products, invoices, invoicedetails
  - invoicepdfs, identificationtypes
- ✅ Volúmenes persistentes
- ✅ Backup fácil

### 📡 Variables de Entorno (25 variables)

- ✅ Servidor (NODE_ENV, PORT)
- ✅ MongoDB (URI, USER, PASSWORD, etc.)
- ✅ Seguridad (JWT_SECRET, ENCRYPTION_KEY)
- ✅ Registro (MASTER_KEY, RUCS, CÓDIGOS)
- ✅ CORS (ALLOWED_ORIGINS, etc.)
- ✅ Email (SERVICE, USER, PASSWORD)
- ✅ SRI (ENVIRONMENT, URLs)
- ✅ Almacenamiento (PROVIDER, CLOUDINARY)

### 🚀 Scripts

- ✅ **deploy.sh** (11 comandos):
  - build, start, stop, restart
  - status, logs, rebuild, clean
  - health, mongo, shell, secrets

- ✅ **deploy.bat** (Windows equivalente)

---

## 🚀 Inicio Rápido

### Paso 1: Preparar variables

```bash
# Copiar archivo de variables
cp .env.docker .env

# Editar con tus valores
nano .env  # o tu editor favorito
```

### Paso 2: Generar secretos seguros (IMPORTANTE para producción)

```bash
# En Linux/Mac:
openssl rand -hex 32  # Para JWT_SECRET
openssl rand -hex 32  # Para ENCRYPTION_KEY

# En Windows PowerShell:
[Convert]::ToHexString([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

### Paso 3: Iniciar servicios

```bash
# Opción A: Con script (recomendado)
./deploy.sh start    # Linux/Mac
deploy.bat start     # Windows

# Opción B: Con docker-compose directo
docker-compose up -d
```

### Paso 4: Verificar

```bash
# Estado de servicios
docker-compose ps

# Health check
curl http://localhost:3000/health

# Logs en tiempo real
docker-compose logs -f app
```

---

## 📋 Valores Configurables

| Parámetro                | Archivo | Por Defecto    | Requerido cambiar            |
| ------------------------ | ------- | -------------- | ---------------------------- |
| **PORT**                 | `.env`  | 3000           | Solo si puerto en uso        |
| **NODE_ENV**             | `.env`  | development    | En producción: `production`  |
| **MONGO_USER**           | `.env`  | sriuser        | En producción: sí            |
| **MONGO_PASSWORD**       | `.env`  | sripassword    | **SÍ - Cambiar siempre**     |
| **MONGO_DB_NAME**        | `.env`  | f-sri          | Opcional                     |
| **JWT_SECRET**           | `.env`  | (vacío)        | **SÍ - Generar con openssl** |
| **ENCRYPTION_KEY**       | `.env`  | (vacío)        | **SÍ - Generar con openssl** |
| **ALLOWED_ORIGINS**      | `.env`  | localhost:4200 | En producción: tu dominio    |
| **EMAIL_USER**           | `.env`  | (vacío)        | Sí, para enviar emails       |
| **EMAIL_PASSWORD**       | `.env`  | (vacío)        | Sí, para enviar emails       |
| **SRI_ENVIRONMENT**      | `.env`  | 1              | En producción: `2`           |
| **PDF_STORAGE_PROVIDER** | `.env`  | local          | Si usas cloud: `cloudinary`  |

---

## 🔐 Seguridad en Producción

### ⚠️ OBLIGATORIO cambiar:

1. **MONGO_PASSWORD** - Contraseña fuerte para MongoDB
2. **JWT_SECRET** - Token secreto (32 hex chars)
3. **ENCRYPTION_KEY** - Clave encriptación (32 hex chars)
4. **MASTER_REGISTRATION_KEY** - Clave de registro
5. **ALLOWED_ORIGINS** - Tu dominio real (no localhost)
6. **EMAIL_USER / EMAIL_PASSWORD** - Credenciales reales

### Generar valores seguros:

```bash
# Linux/Mac
openssl rand -hex 32  # Para secretos de 32 chars hex

# Windows PowerShell
[Convert]::ToHexString([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

---

## 📊 Estructura de Directorios

Después de iniciar, se crean:

```
f-sri/
├── storage/
│   └── pdfs/           # PDFs generados (si PDF_STORAGE_PROVIDER=local)
├── logs/               # Logs de la aplicación
├── .env                # Variables de entorno (No commitear!)
└── dist/               # Código compilado (dentro del contenedor)
```

---

## 🐳 Comandos Útiles

### Gestión de Servicios

```bash
# Ver estado
docker-compose ps

# Iniciar
docker-compose up -d

# Detener
docker-compose down

# Reconstruir
docker-compose build
docker-compose up -d

# Reiniciar
docker-compose restart

# Logs
docker-compose logs -f app
docker-compose logs -f mongodb
```

### Acceso a Servicios

```bash
# MongoDB CLI
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin

# Shell de aplicación
docker-compose exec app sh

# Ejecutar comando en app
docker-compose exec app npm run build
```

### Mantenimiento

```bash
# Limpieza de volúmenes (CUIDADO: elimina datos)
docker-compose down -v

# Backup de MongoDB
docker-compose exec mongodb mongodump \
  --uri="mongodb://sriuser:sripassword@localhost:27017/f-sri?authSource=admin" \
  --out=/backup

# Ver uso de disco
docker system df
```

---

## 🆘 Solución de Problemas

### Puerto 3000 en uso

```bash
# Cambiar en .env: PORT=3001
# Luego: docker-compose down && docker-compose up -d
```

### MongoDB no inicia

```bash
# Ver logs: docker-compose logs mongodb
# Limpiar y reiniciar: docker-compose down -v && docker-compose up -d
```

### App no puede conectar a MongoDB

```bash
# Verificar hostname: debe ser "mongodb" (el nombre del servicio)
# Verificar credenciales en .env
# Ver logs: docker-compose logs app
```

### Permiso denegado (Linux)

```bash
# Agregar usuario a grupo docker:
sudo usermod -aG docker $USER
newgrp docker
```

---

## 📈 Monitoreo

### Health Check

```bash
# Revisar estado
curl http://localhost:3000/health

# Respuesta esperada:
# {"status":"OK","cors":"enabled","environment":"production"}
```

### Logs en Tiempo Real

```bash
# Todas las aplicaciones
docker-compose logs -f

# Solo app
docker-compose logs -f app

# Últimas 50 líneas
docker-compose logs --tail 50

# Con timestamps
docker-compose logs -f --timestamps
```

### Acceso a Base de Datos

```bash
# Conectar a MongoDB
docker-compose exec mongodb mongosh \
  -u sriuser -p sripassword \
  --authenticationDatabase admin

# Dentro de mongosh:
# > use f-sri
# > show collections
# > db.users.countDocuments()
```

---

## 🎓 Archivos de Documentación

### 1. **DOCKER_READY.md** (este archivo)

- Resumen ejecutivo
- Inicio rápido
- Solución de problemas básicos

### 2. **DOCKER_DEPLOY.md**

- Guía detallada paso a paso
- Comandos completos
- Despliegue en producción
- Backup y restauración

### 3. **DOCKER_CONFIG.md**

- Documentación técnica
- Detalles de cada archivo
- Performance y escalabilidad
- Checklist de despliegue

---

## ✨ Características Especiales

### Health Checks Automáticos

- MongoDB: verifica cada 10s
- App: verifica endpoint `/health` cada 30s
- App espera a que MongoDB esté listo

### Inicialización Automática

- Script `init-mongo.js` se ejecuta al iniciar MongoDB
- Crea índices automáticamente
- Base de datos lista para usar

### Logging Centralizado

- Formato JSON
- Máx 10MB por archivo
- Máx 3 archivos con rotación
- Volumen persistente

### Escalabilidad

- Network preparada para agregar servicios
- Volúmenes separados
- Configuración flexible

---

## 🎯 Próximos Pasos

1. ✅ Editars `.env` con tus valores
2. ✅ Generar secretos seguros (producción)
3. ✅ Ejecutar `./deploy.sh start` o `deploy.bat start`
4. ✅ Verificar con `docker-compose ps`
5. ✅ Probar health check: `curl http://localhost:3000/health`
6. ✅ Ver API docs: http://localhost:3000/docs
7. ✅ Consultar logs: `docker-compose logs -f app`

---

## 📞 Soporte

- **Documentación:** [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md)
- **Config técnica:** [DOCKER_CONFIG.md](DOCKER_CONFIG.md)
- **GitHub:** https://github.com/XaviMontero/f-sri/issues
- **Docker Docs:** https://docs.docker.com/

---

**¡Configuración lista para desplegar! 🚀**

**Estado:** ✅ Completado
**Fecha:** 28 de enero de 2026
**Versión:** 1.0.0
