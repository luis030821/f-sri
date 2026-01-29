# 🔧 Solución: MongoDB Health Check Fallando

## Problema

```
Container f-sri-mongodb is unhealthy
dependency failed to start: container f-sri-mongodb is unhealthy
```

## Causa

MongoDB 8.2.4 reemplazó el comando `mongo` legacy con `mongosh` (MongoDB Shell).

El health check estaba usando:

```bash
mongo -u user -p pass --authenticationDatabase admin --eval "db.adminCommand('ping')"
```

Pero `mongo` ya no existe en MongoDB 8.2.4, causando que el health check fallara.

## Solución Aplicada ✅

Se actualizó el health check en `docker-compose.yml` para usar `mongosh`:

**Antes:**

```yaml
healthcheck:
  test:
    - CMD
    - /bin/sh
    - -c
    - mongo -u ${MONGO_USER:-sriuser} -p ${MONGO_PASSWORD:-sripassword} --authenticationDatabase admin --eval "db.adminCommand('ping')"
  start_period: 40s
```

**Después:**

```yaml
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

## Cambios Realizados

1. **Comando:** `mongo` → `mongosh`
2. **Sintaxis:** Shell command string → Array de parámetros (más robusto)
3. **Start Period:** 40s → 60s (más tiempo para iniciar MongoDB)
4. **Timeout:** 5s → 10s (más tolerancia en slow systems)

## Por qué funciona ahora

- ✅ `mongosh` es el cliente correcto para MongoDB 8.2+
- ✅ Array de parámetros es más compatible
- ✅ 60 segundos dan tiempo suficiente a MongoDB de iniciar
- ✅ El timeout de 10s es más realista

## Verificar que funcione

```bash
# Ver logs de MongoDB
docker-compose logs mongodb

# Si MongoDB está corriendo pero health check falla:
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin --eval "db.adminCommand('ping')"

# Si retorna: { ok: 1 } → MongoDB está bien

# Reconstruir y reiniciar
docker-compose down
docker-compose up -d

# Verificar estado
docker-compose ps
# mongodb debe mostrar "healthy" después de ~60 segundos
```

## Versiones de MongoDB

| Versión | Cliente   | Disponible                     |
| ------- | --------- | ------------------------------ |
| < 6.0   | `mongo`   | ✅ Incluido                    |
| 6.0-7.x | `mongo`   | ✅ Incluido                    |
| 8.0+    | `mongosh` | ✅ Incluido (mongo deprecated) |

**Conclusión:** MongoDB 8.2.4 usa `mongosh` por defecto.

---

**Archivo actualizado:** docker-compose.yml  
**Cambios:** Líneas 27-41  
**Estado:** ✅ Resuelto
