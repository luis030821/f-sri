# Configuración Docker para F-SRI

## 📋 Archivos Creados/Modificados

### 1. **Dockerfile** - Imagen de la aplicación

- Compilación en dos etapas (multi-stage build) para optimizar tamaño
- Basado en `node:20-alpine` para imagen pequeña y ligera
- Usuario no-root (`nodejs`) por seguridad
- Health check automático en `/health`
- Manejo correcto de señales con `dumb-init`

**Características:**

- ✅ Compilación TypeScript separada
- ✅ Instalación optimizada de dependencias
- ✅ Usuario no-root por seguridad
- ✅ Health check incluido
- ✅ Logs correctamente configurados

### 2. **docker-compose.yml** - Orquestación de servicios

Define dos servicios:

#### MongoDB

- Imagen: `mongo:7.0-alpine`
- Puerto: 27017 (configurable)
- Volúmenes:
  - `mongodb_data`: datos persistentes
  - `mongodb_config`: configuración persistente
  - `init-mongo.js`: script de inicialización
- Health check automático
- Autenticación habilitada

#### Aplicación (app)

- Construida desde el Dockerfile
- Puerto: 3000 (configurable)
- Depende de MongoDB (espera a que esté listo)
- Variables de entorno completas
- Volúmenes para PDFs y logs
- Logging configurado (JSON-File)

### 3. **.env.docker** - Variables de entorno

Archivo plantilla con TODAS las variables necesarias:

**Secciones:**

- Configuración del servidor (NODE_ENV, PORT)
- Base de datos MongoDB (usuario, contraseña, puerto)
- Seguridad (JWT_SECRET, ENCRYPTION_KEY)
- Registro de usuarios
- CORS
- Email
- Integración SRI
- Almacenamiento de PDFs

### 4. **init-mongo.js** - Script de inicialización de MongoDB

Crear índices automáticamente en:

- `users`: email (único), ruc
- `issuingcompanies`: ruc (único), userId
- `clients`: ruc, email, companyId
- `products`: code, companyId
- `invoices`: número, companyId, clientId, estado, fecha
- `invoicedetails`: invoiceId, productId
- `invoicepdfs`: invoiceId (único), companyId
- `identificationtypes`: code (único)

### 5. **.dockerignore** - Archivos a ignorar

Reduce el tamaño de la imagen excluyendo:

- node_modules
- tests
- IDE
- documentación
- archivos temporales

### 6. **deploy.sh** - Script de utilidad (Linux/Mac)

Comandos disponibles:

```bash
./deploy.sh build      # Construir imágenes
./deploy.sh start      # Iniciar servicios
./deploy.sh stop       # Detener servicios
./deploy.sh restart    # Reiniciar
./deploy.sh status     # Ver estado
./deploy.sh logs [srv] # Ver logs
./deploy.sh rebuild    # Reconstruir y reiniciar
./deploy.sh clean      # Limpiar todo
./deploy.sh health     # Health check
./deploy.sh mongo      # CLI de MongoDB
./deploy.sh shell      # Shell de la app
./deploy.sh secrets    # Generar variables seguras
```

### 7. **deploy.bat** - Script de utilidad (Windows)

Mismo funcionalidad que deploy.sh pero para Windows:

```batch
deploy.bat build
deploy.bat start
deploy.bat logs
... etc
```

### 8. **DOCKER_DEPLOY.md** - Documentación completa

Guía detallada que incluye:

- Requisitos previos
- Pasos para desplegar
- Comandos útiles
- Variables de entorno
- Monitoreo y mantenimiento
- Solución de problemas
- Backup de base de datos
- Despliegue en producción

---

## 🚀 Inicio Rápido

### Opción 1: Usar scripts (Recomendado)

**En Linux/Mac:**

```bash
chmod +x deploy.sh
./deploy.sh build
./deploy.sh start
./deploy.sh status
```

**En Windows:**

```batch
deploy.bat build
deploy.bat start
deploy.bat status
```

### Opción 2: Comandos directos

```bash
# Copiar variables de entorno
cp .env.docker .env

# Editar .env con tus valores
nano .env  # (o tu editor favorito)

# Construir
docker-compose build

# Iniciar
docker-compose up -d

# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f
```

---

## 🔧 Variables de Entorno Principales

| Variable               | Predeterminado | Descripción                      |
| ---------------------- | -------------- | -------------------------------- |
| `NODE_ENV`             | production     | Entorno (development/production) |
| `PORT`                 | 3000           | Puerto de la aplicación          |
| `MONGO_USER`           | sriuser        | Usuario de MongoDB               |
| `MONGO_PASSWORD`       | sripassword    | Contraseña de MongoDB            |
| `MONGO_DB_NAME`        | f-sri          | Nombre de la BD                  |
| `JWT_SECRET`           | -              | **CAMBIAR** en producción        |
| `ENCRYPTION_KEY`       | -              | **CAMBIAR** en producción        |
| `ALLOWED_ORIGINS`      | localhost:4200 | Dominios CORS                    |
| `EMAIL_USER`           | -              | Usuario de correo                |
| `SRI_ENVIRONMENT`      | 1              | 1=Pruebas, 2=Producción          |
| `PDF_STORAGE_PROVIDER` | local          | cloudinary o local               |

---

## 🔐 Seguridad en Producción

**IMPORTANTE:** Cambiar estos valores:

1. **JWT_SECRET** (32 caracteres hexadecimales):

```bash
openssl rand -hex 32
```

2. **ENCRYPTION_KEY** (32 caracteres hexadecimales):

```bash
openssl rand -hex 32
```

3. **MONGO_PASSWORD** - Contraseña fuerte:

```bash
openssl rand -base64 32
```

4. **MASTER_REGISTRATION_KEY** - Clave única:

```bash
openssl rand -hex 16
```

---

## 📊 Verificación y Monitoreo

### Health Check

```bash
# Verificar que todo está funcionando
curl http://localhost:3000/health
```

Respuesta esperada:

```json
{
  "status": "OK",
  "timestamp": "2026-01-28T...",
  "cors": "enabled",
  "environment": "production"
}
```

### Ver Logs

```bash
# Todos los logs
docker-compose logs

# Solo de la app
docker-compose logs -f app

# Solo de MongoDB
docker-compose logs -f mongodb

# Últimas 50 líneas
docker-compose logs --tail 50
```

### Acceder a MongoDB

```bash
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin
```

### Acceder a la shell de la app

```bash
docker-compose exec app sh
```

---

## 🗄️ Base de Datos

### Colecciones creadas automáticamente

1. **users** - Usuarios registrados
2. **issuingcompanies** - Empresas emisoras
3. **clients** - Clientes
4. **products** - Productos/servicios
5. **invoices** - Facturas
6. **invoicedetails** - Detalles de facturas
7. **invoicepdfs** - PDFs generados
8. **identificationtypes** - Tipos de identificación

### Índices optimizados

Todos automáticamente creados por `init-mongo.js`

### Backup de datos

```bash
# Crear backup
docker-compose exec mongodb mongodump \
  --uri="mongodb://sriuser:sripassword@localhost:27017/f-sri?authSource=admin" \
  --out=/backup

# Restaurar desde backup
docker-compose exec mongodb mongorestore \
  --uri="mongodb://sriuser:sripassword@localhost:27017" \
  /backup
```

---

## 🚫 Solución de Problemas

### Puertos en uso

```bash
# En .env, cambiar puerto:
PORT=3001
MONGO_PORT=27018

# Luego reconstruir
docker-compose down
docker-compose up -d
```

### Permiso denegado (Linux)

```bash
# Agregar usuario actual al grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

### Volúmenes no se crean

```bash
# Crear directorios manualmente
mkdir -p storage/pdfs logs

# Establecer permisos
chmod 755 storage logs
```

### MongoDB no inicia

```bash
# Ver logs de MongoDB
docker-compose logs mongodb

# Limpiar y reiniciar
docker-compose down -v
docker-compose up -d mongodb
```

---

## 📦 Almacenamiento de PDFs

### Local (Por defecto)

```
storage/
  └── pdfs/
      └── [archivos PDF generados]
```

### Cloudinary (Nube)

```env
PDF_STORAGE_PROVIDER=cloudinary
CLOUDINARY_CLOUD_NAME=tu_cloud_name
CLOUDINARY_API_KEY=tu_api_key
CLOUDINARY_API_SECRET=tu_api_secret
```

---

## 🔄 Actualizar la Aplicación

```bash
# 1. Descargar cambios
git pull origin main

# 2. Reconstruir
docker-compose build

# 3. Reiniciar
docker-compose down
docker-compose up -d

# 4. Verificar
docker-compose logs -f app
```

---

## 📈 Performance en Producción

### Recomendaciones

1. Usar reverse proxy (nginx) frente a la app
2. Implementar caché (Redis)
3. Configurar backups automáticos
4. Monitoreo con Prometheus/Grafana
5. Logs centralizados (ELK Stack)
6. CDN para PDFs (CloudFront, Cloudinary)

### Ejemplo: Docker Compose con nginx

```yaml
nginx:
  image: nginx:alpine
  ports:
    - '80:80'
    - '443:443'
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf:ro
  depends_on:
    - app
```

---

## ✅ Checklist de Despliegue

- [ ] Variables de entorno configuradas en `.env`
- [ ] JWT_SECRET y ENCRYPTION_KEY generadas (producción)
- [ ] MONGO_PASSWORD cambiada
- [ ] ALLOWED_ORIGINS configurada con dominio real
- [ ] EMAIL_USER y EMAIL_PASSWORD configurados
- [ ] SRI_ENVIRONMENT = 2 (si es producción)
- [ ] Directorios `storage/pdfs` y `logs` creados
- [ ] Docker y Docker Compose instalados
- [ ] Firewall configurado para puertos 3000 y 27017
- [ ] Backups configurados
- [ ] Monitoreo/alertas configurado

---

## 🆘 Soporte

Para problemas específicos, consultar:

- [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md) - Documentación detallada
- [README.md](README.md) - Documentación del proyecto
- Logs: `docker-compose logs -f`
- GitHub Issues: https://github.com/XaviMontero/f-sri/issues
