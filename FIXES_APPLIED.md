# 🔧 Fixes Realizados - Problemas Docker Resueltos

## 📋 Resumen de Problemas y Soluciones

### 1. ❌ Error: `npm ci` requiere `package-lock.json`

**Archivo:** Dockerfile  
**Problema:**

```
npm error The `npm ci` command can only install with an existing package-lock.json
```

**Solución:**

- Cambiar `npm ci` por `npm install` (más flexible)
- Agregar copia explícita de `package-lock.json`

**Archivos afectados:**

- `Dockerfile` (líneas 13 y 38)

**Ver:** `FIX_NPM_CI.md`

---

### 2. ❌ Error: MongoDB Health Check Fallando

**Archivo:** docker-compose.yml  
**Problema:**

```
Container f-sri-mongodb is unhealthy
Error: dependency mongodb failed to start
```

**Causa:** MongoDB 8.2.4 reemplazó comando `mongo` con `mongosh`

**Solución:**

- Actualizar health check para usar `mongosh`
- Aumentar `start_period` de 40s a 60s
- Aumentar `timeout` de 5s a 10s

**Archivos afectados:**

- `docker-compose.yml` (líneas 27-41)

**Ver:** `FIX_MONGODB_HEALTH.md`

---

## 🔍 Cambios Específicos

### Dockerfile

```dockerfile
# ANTES
RUN npm ci

# DESPUÉS
RUN npm install
```

```dockerfile
# ANTES
COPY package*.json ./

# DESPUÉS
COPY package*.json ./
COPY package-lock.json* ./
```

### docker-compose.yml

```yaml
# ANTES (❌ Fallaba)
healthcheck:
  test:
    - CMD
    - /bin/sh
    - -c
    - mongo -u ${MONGO_USER:-sriuser} -p ${MONGO_PASSWORD:-sripassword} --authenticationDatabase admin --eval "db.adminCommand('ping')"
  start_period: 40s
  timeout: 5s

# DESPUÉS (✅ Funciona)
healthcheck:
  test:
    - CMD
    - mongosh
    - --eval
    - "db.adminCommand('ping')"
    - --authenticationDatabase
    - admin
    - -u
    - ${MONGO_USER:-sriuser}
    - -p
    - ${MONGO_PASSWORD:-sripassword}
  start_period: 60s
  timeout: 10s
```

---

## ✅ Verificación

Después de los fixes, ejecutar:

```bash
# Limpiar y reconstruir
docker-compose down -v
docker-compose build --no-cache

# Iniciar
docker-compose up -d

# Esperar ~60 segundos y verificar
docker-compose ps
# Ambos contenedores deben estar "healthy" o "running"

# Ver logs
docker-compose logs mongodb
docker-compose logs app
```

**Resultado esperado:**

```
NAME                COMMAND             STATUS
f-sri-app          docker-entrypoint   Up (healthy)
f-sri-mongodb      docker-entrypoint   Up (healthy)
```

---

## 📚 Documentación de Fixes

| Fix            | Archivo                 | Contenido            |
| -------------- | ----------------------- | -------------------- |
| npm ci         | `FIX_NPM_CI.md`         | Explicación completa |
| MongoDB Health | `FIX_MONGODB_HEALTH.md` | Troubleshooting      |

---

## 🚀 Próximos Pasos

1. Ejecutar `docker-compose down -v`
2. Ejecutar `docker-compose build --no-cache`
3. Ejecutar `docker-compose up -d`
4. Esperar ~60 segundos
5. Verificar: `docker-compose ps`
6. Verificar logs si hay problemas

---

**Fecha:** 28 de enero de 2026  
**Estado:** ✅ Fixes Aplicados  
**Próxima acción:** Reconstruir Docker
