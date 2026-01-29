# Guía de Despliegue con Docker

## Requisitos Previos

- Docker Desktop instalado (https://www.docker.com/products/docker-desktop)
- Docker Compose (incluido en Docker Desktop)
- Git (para clonar el repositorio)

## Estructura de Archivos para Deploy

```
f-sri/
├── .env.docker              # Variables de entorno (copiar y personalizar)
├── .dockerignore            # Archivos a ignorar en la imagen Docker
├── Dockerfile               # Imagen Docker de la aplicación
├── docker-compose.yml       # Orquestación de contenedores
├── init-mongo.js            # Script de inicialización de MongoDB
├── package.json
├── tsconfig.json
├── src/
├── storage/
│   └── pdfs/                # Almacenamiento local de PDFs (se crea automáticamente)
└── logs/                    # Logs de la aplicación (se crea automáticamente)
```

## Pasos para Desplegar

### 1. Preparar el Entorno

```bash
# Copiar el archivo de variables de entorno
cp .env.docker .env

# IMPORTANTE: Editar .env con valores específicos para tu entorno
# En producción, CAMBIAR TODOS los valores de seguridad
```

### 2. Construir las Imágenes

```bash
# Construir las imágenes de Docker
docker-compose build

# Si necesitas reconstruir sin caché:
docker-compose build --no-cache
```

### 3. Iniciar los Servicios

```bash
# Inicia MongoDB y la aplicación en modo detached
docker-compose up -d

# Ver logs en tiempo real:
docker-compose logs -f

# Ver logs solo de la aplicación:
docker-compose logs -f app

# Ver logs solo de MongoDB:
docker-compose logs -f mongodb
```

### 4. Verificar el Estado

```bash
# Ver estado de los contenedores
docker-compose ps

# Prueba el endpoint de health
curl http://localhost:3000/health

# Ver documentación de la API
open http://localhost:3000/docs
```

## Comandos Útiles

### Gestión de Contenedores

```bash
# Detener los servicios
docker-compose down

# Detener y eliminar volúmenes (CUIDADO: elimina datos)
docker-compose down -v

# Reiniciar los servicios
docker-compose restart

# Reiniciar solo la aplicación
docker-compose restart app

# Ejecutar comandos en el contenedor
docker-compose exec app sh
```

### MongoDB

```bash
# Acceder a la línea de comandos de MongoDB
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin

# Dentro de mongosh:
# Cambiar a la BD
use f-sri

# Ver colecciones
show collections

# Contar documentos
db.users.countDocuments()
```

### Logs y Debugging

```bash
# Ver logs de todo
docker-compose logs

# Ver últimas 100 líneas
docker-compose logs --tail 100

# Seguir logs en tiempo real
docker-compose logs -f

# Ver solo errores
docker-compose logs | grep -i error
```

## Variables de Entorno Importantes

| Variable                        | Descripción                      | Ejemplo                            |
| ------------------------------- | -------------------------------- | ---------------------------------- |
| `NODE_ENV`                      | Entorno (development/production) | `production`                       |
| `PORT`                          | Puerto de la aplicación          | `3000`                             |
| `MONGO_URI`                     | URI de conexión a MongoDB        | Se genera automáticamente          |
| `JWT_SECRET`                    | Clave para firmar tokens JWT     | Generar con `openssl rand -hex 32` |
| `ENCRYPTION_KEY`                | Clave de encriptación (32 chars) | Generar con `openssl rand -hex 16` |
| `ALLOWED_ORIGINS`               | Dominios permitidos para CORS    | `https://tu-dominio.com`           |
| `EMAIL_USER` / `EMAIL_PASSWORD` | Credenciales de correo           | Gmail App Password                 |
| `SRI_ENVIRONMENT`               | Ambiente SRI (1=pruebas, 2=prod) | `2`                                |
| `PDF_STORAGE_PROVIDER`          | Proveedor de almacenamiento      | `local` o `cloudinary`             |

## Monitoreo y Mantenimiento

### Health Checks

El docker-compose incluye health checks automáticos:

- MongoDB: verifica conectividad cada 10 segundos
- App: verifica el endpoint `/health` cada 30 segundos

### Logs Persistentes

Los logs se guardan automáticamente en:

```
- Aplicación: formato JSON-File, máx 10MB por archivo, máx 3 archivos
- Ruta: `/var/lib/docker/containers/[container-id]/[container-id]-json.log`
```

### Backup de Base de Datos

```bash
# Hacer backup de MongoDB
docker-compose exec mongodb mongodump --uri="mongodb://sriuser:sripassword@localhost:27017/f-sri?authSource=admin" --out=/tmp/backup

# Restaurar desde backup
docker-compose exec mongodb mongorestore --uri="mongodb://sriuser:sripassword@localhost:27017" /tmp/backup
```

## Solución de Problemas

### La aplicación no puede conectarse a MongoDB

```bash
# Verificar que MongoDB está corriendo
docker-compose ps

# Ver logs de MongoDB
docker-compose logs mongodb

# Verificar la URI de conexión en .env
# El hostname DEBE ser "mongodb" (nombre del servicio en docker-compose.yml)
```

### Puertos Ya en Uso

```bash
# Cambiar puertos en .env o en docker-compose.yml
# Ejemplo: usar puerto 3001 en lugar de 3000
PORT=3001

# Luego reconstruir:
docker-compose down
docker-compose up -d
```

### Errores de Permisos

```bash
# Si hay problemas con directorios:
docker-compose exec app mkdir -p /app/storage/pdfs /app/logs
docker-compose exec app chown -R nodejs:nodejs /app/storage /app/logs
```

### Limpiar Espacios en Disco

```bash
# Eliminar contenedores detenidos
docker container prune

# Eliminar imágenes no usadas
docker image prune

# Eliminar volúmenes no usados
docker volume prune

# Limpieza completa (CUIDADO!)
docker system prune -a
```

## Despliegue en Producción

### Cambios Recomendados

1. **Seguridad:**
   - Generar valores aleatorios seguros para `JWT_SECRET` y `ENCRYPTION_KEY`
   - Usar contraseña fuerte para MongoDB
   - Configurar `ALLOWED_ORIGINS` con dominios reales
   - Habilitar autenticación en MongoDB

2. **Performance:**
   - Establecer `NODE_ENV=production`
   - Aumentar límites de recursos en docker-compose si es necesario
   - Usar un reverse proxy (nginx) frente a la aplicación

3. **Respaldos:**
   - Configurar respaldos automáticos de MongoDB
   - Usar almacenamiento externo para PDFs (Cloudinary, S3, etc.)

4. **Monitoreo:**
   - Implementar monitoreo con Prometheus/Grafana
   - Configurar alertas para errores críticos
   - Usar centralizador de logs (ELK, Datadog, etc.)

## Actualizar la Aplicación

```bash
# 1. Actualizar el código
git pull origin main

# 2. Reconstruir la imagen
docker-compose build

# 3. Reiniciar los servicios
docker-compose down
docker-compose up -d

# 4. Verificar
docker-compose logs -f app
```

## Recursos Adicionales

- [Documentación de Docker](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
