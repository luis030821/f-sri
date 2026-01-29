# ✅ Configuración Docker Completada para F-SRI

## 📁 Archivos Creados

### Configuración Docker

1. **Dockerfile** ✓
   - Multi-stage build (Builder + Runtime)
   - Node.js 20 Alpine (optimizado)
   - Usuario no-root para seguridad
   - Health check incluido
   - dumb-init para manejo de signals

2. **docker-compose.yml** ✓
   - Servicio MongoDB 7.0
   - Servicio App
   - Volúmenes persistentes
   - Network interno
   - Health checks automáticos
   - Todas las variables de entorno

3. **.env.docker** ✓
   - Variables de entorno documentadas
   - Valores por defecto seguros
   - Secciones organizadas

4. **.dockerignore** ✓
   - Reduce tamaño de imagen
   - Excluye archivos innecesarios

### Scripts de Utilidad

5. **deploy.sh** ✓ (Linux/Mac)
   - 11 comandos disponibles
   - Colores en terminal
   - Verificaciones previas

6. **deploy.bat** ✓ (Windows)
   - 11 comandos disponibles
   - Compatible con CMD/PowerShell

### Inicialización

7. **init-mongo.js** ✓
   - Crea índices automáticamente
   - Optimiza colecciones
   - 8 colecciones configuradas

### Documentación

8. **DOCKER_CONFIG.md** ✓
   - Resumen de configuración
   - Quick start
   - Solución de problemas
   - Checklist de despliegue

9. **DOCKER_DEPLOY.md** ✓
   - Guía detallada
   - Comandos útiles
   - Backup y restauración
   - Despliegue en producción

---

## 🎯 Variables de Entorno Configuradas

### Servidor

- ✅ NODE_ENV (development/production)
- ✅ PORT (3000 por defecto)

### Base de Datos MongoDB

- ✅ MONGO_URI (construida automáticamente)
- ✅ MONGO_USER
- ✅ MONGO_PASSWORD
- ✅ MONGO_DB_NAME
- ✅ MONGO_PORT

### Seguridad

- ✅ JWT_SECRET
- ✅ ENCRYPTION_KEY
- ✅ MASTER_REGISTRATION_KEY

### Registro

- ✅ ALLOWED_RUCS
- ✅ INVITATION_CODES
- ✅ DISABLE_REGISTRATION

### CORS

- ✅ ALLOWED_ORIGINS
- ✅ CORS_DISABLED

### Email

- ✅ EMAIL_SERVICE
- ✅ EMAIL_USER
- ✅ EMAIL_PASSWORD

### Integración SRI

- ✅ SRI_ENVIRONMENT
- ✅ SRI_RECEPCION_URL_PRUEBAS
- ✅ SRI_RECEPCION_URL_PRODUCCION

### Almacenamiento

- ✅ PDF_STORAGE_PROVIDER
- ✅ CLOUDINARY_CLOUD_NAME
- ✅ CLOUDINARY_API_KEY
- ✅ CLOUDINARY_API_SECRET

---

## 🚀 Próximos Pasos

### 1. Preparar Entorno

```bash
# Copiar variables de entorno
cp .env.docker .env

# Editar .env con tus valores
nano .env  # o tu editor favorito
```

### 2. Generar Secretos Seguros (Importante para Producción)

```bash
# JWT_SECRET (Linux/Mac)
openssl rand -hex 32

# ENCRYPTION_KEY (Linux/Mac)
openssl rand -hex 32

# O usar PowerShell (Windows)
[Convert]::ToHexString([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

### 3. Iniciar con Script

```bash
# Linux/Mac
chmod +x deploy.sh
./deploy.sh start

# Windows
deploy.bat start
```

### 4. Verificar

```bash
# Ver estado
docker-compose ps

# Health check
curl http://localhost:3000/health

# Logs
docker-compose logs -f app
```

---

## 📊 Servicios Configurados

### MongoDB

| Propiedad    | Valor                  |
| ------------ | ---------------------- |
| Imagen       | mongo:7.0-alpine       |
| Puerto       | 27017 (configurable)   |
| Usuario      | sriuser (configurable) |
| BD           | f-sri (configurable)   |
| Volúmenes    | 2 (data + config)      |
| Health Check | ✓ Habilitado           |
| Reinicio     | unless-stopped         |

### Aplicación (App)

| Propiedad    | Valor                         |
| ------------ | ----------------------------- |
| Imagen       | Construida desde Dockerfile   |
| Puerto       | 3000 (configurable)           |
| Node.js      | 20 Alpine                     |
| Dependencia  | MongoDB (espera health check) |
| Volúmenes    | storage/pdfs + logs           |
| Health Check | ✓ Habilitado                  |
| Reinicio     | unless-stopped                |
| Usuario      | nodejs (no-root)              |

---

## 🔐 Seguridad Implementada

### Contenedores

- ✅ Usuario no-root (nodejs)
- ✅ Imágenes Alpine (reducen superficie de ataque)
- ✅ Instalación de solo dependencias de producción
- ✅ dumb-init para manejo seguro de signals

### Base de Datos

- ✅ Autenticación habilitada
- ✅ Usuario dedicado
- ✅ Health checks
- ✅ Índices de seguridad

### Network

- ✅ Red interna (f-sri-network)
- ✅ Solo app expone puertos externos
- ✅ MongoDB solo accesible desde app

### Volúmenes

- ✅ Datos persistentes
- ✅ Logs persistentes
- ✅ Scripts de inicialización

---

## 🛠️ Comandos Útiles Rápidos

### Iniciar

```bash
docker-compose up -d
```

### Ver estado

```bash
docker-compose ps
docker-compose logs -f app
```

### Detener

```bash
docker-compose down
```

### Limpiar (elimina datos)

```bash
docker-compose down -v
```

### Reconstruir

```bash
docker-compose build
docker-compose up -d
```

### MongoDB CLI

```bash
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin
```

### Shell de app

```bash
docker-compose exec app sh
```

---

## 📈 Performance

### Optimizaciones Realizadas

- ✅ Multi-stage build (reduce tamaño de imagen)
- ✅ Alpine Linux (imagen pequeña)
- ✅ npm ci (instalación reproducible)
- ✅ Índices en MongoDB (consultas rápidas)
- ✅ Logging centralizado

### Tamaño Esperado

- Imagen App: ~250-300MB
- Imagen MongoDB: ~100-150MB

---

## ✨ Características Especiales

### Health Checks

- MongoDB: verifica conectividad cada 10s
- App: verifica `/health` cada 30s
- Espera inteligente: app espera a que MongoDB esté healthy

### Inicialización Automática

- Script `init-mongo.js` crea índices automáticamente
- Base de datos lista para usar
- Índices optimizados para consultas

### Logs

- Formato JSON
- Máx 10MB por archivo
- Máx 3 archivos (rotación automática)
- Volumen persistente

### Escalabilidad

- Network facilitado para agregar servicios
- Volúmenes separados para datos y config
- Configuración flexible por variables de entorno

---

## 🎓 Recursos Adicionales

- **Documentación completa:** [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md)
- **Configuración rápida:** [DOCKER_CONFIG.md](DOCKER_CONFIG.md)
- **Dockerfile best practices:** https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- **Docker Compose documentation:** https://docs.docker.com/compose/

---

## ❓ Preguntas Frecuentes

### ¿Cómo cambio el puerto?

Edit `.env`: `PORT=3001`
Luego: `docker-compose down && docker-compose up -d`

### ¿Cómo cambio la contraseña de MongoDB?

Edit `.env`: `MONGO_PASSWORD=nueva_contraseña`
Luego: `docker-compose down -v && docker-compose up -d`
(Nota: `-v` elimina datos, hacer backup primero)

### ¿Cómo hago backup?

```bash
docker-compose exec mongodb mongodump \
  --uri="mongodb://sriuser:sripassword@localhost:27017/f-sri?authSource=admin" \
  --out=/backup
```

### ¿Cómo actualizo la app?

```bash
git pull origin main
docker-compose build
docker-compose down && docker-compose up -d
```

### ¿En qué puerto corre?

- App: 3000 (configurable)
- MongoDB: 27017 (configurable)
- Solo la app es accesible externamente

---

**Estado:** ✅ Completado
**Fecha:** 28 de enero de 2026
**Versión:** 1.0.0

Para comenzar a usar, sigue los pasos en la sección "Próximos Pasos".
