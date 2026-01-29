# ✅ Checklist de Verificación Post-Fixes

## 📋 Antes de Iniciar

- [ ] Leer `FIXES_SUMMARY.txt` (este directorio)
- [ ] Leer `QUICK_START.md` (sección MongoDB Falla)
- [ ] Tener `docker-compose` instalado
- [ ] Tener `docker` en funcionamiento

## 🔧 Limpieza Previa (IMPORTANTE)

```bash
# Eliminar contenedores y volúmenes previos
docker-compose down -v

# Verificar que todo fue eliminado
docker volume ls         # no debe aparecer mongodb_data
docker ps -a            # no debe aparecer f-sri-*
```

- [ ] Ejecutado: `docker-compose down -v`
- [ ] Verificado que no quedan volúmenes

## 🏗️ Reconstrucción

```bash
# Reconstruir sin caché (obligatorio para aplicar fixes)
docker-compose build --no-cache

# Esto tardará 3-5 minutos
```

- [ ] Ejecutado: `docker-compose build --no-cache`
- [ ] Build completado sin errores (ver últimas líneas)
- [ ] No aparecen errores de "npm ci"
- [ ] No aparecen errores de "npm install"

## 🚀 Inicio de Servicios

```bash
# Iniciar servicios en background
docker-compose up -d

# Esto inicia ambos contenedores
```

- [ ] Ejecutado: `docker-compose up -d`
- [ ] Sin errores inmediatos

## ⏳ Espera Crítica

```bash
# MongoDB tarda ~60 segundos en iniciar
# Este es NORMAL, no detener
sleep 60

# O esperar manualmente mientras ves:
docker-compose logs -f mongodb
```

- [ ] Esperado: 60 segundos completos
- [ ] No interrumpir durante este tiempo

## 🔍 Verificación de Estado

```bash
# Ver estado de ambos contenedores
docker-compose ps
```

**RESULTADO ESPERADO:**

```
NAME                COMMAND             STATUS              PORTS
f-sri-app          "dumb-init -- node  Up (healthy)        0.0.0.0:3000->3000/tcp
f-sri-mongodb      "docker-entrypoint  Up (healthy)        0.0.0.0:27017->27017/tcp
```

- [ ] `f-sri-app` está "Up (healthy)" o "Up"
- [ ] `f-sri-mongodb` está "Up (healthy)"
- [ ] Ambos puertos expuestos correctamente
- [ ] No hay contenedores "Exited" ni "Unhealthy"

### Si MongoDB no es Healthy

```bash
# Ver logs para diagnosticar
docker-compose logs mongodb

# Buscar:
# - "initiated set" = OK
# - "waiting for connections" = OK
# - "error" = Problema
```

- [ ] Revisado: `docker-compose logs mongodb`
- [ ] Logs muestran inicialización exitosa
- [ ] No hay errores de autenticación

## 📡 Verificación de API

```bash
# Health check de la API
curl http://localhost:3000/health

# Resultado esperado:
# {"status":"OK","timestamp":"...","cors":"enabled","environment":"development"}
```

- [ ] Health check retorna OK
- [ ] Status es "OK"
- [ ] Puede conectar a http://localhost:3000

## 🗄️ Verificación de MongoDB

```bash
# Conectar a MongoDB
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin

# Dentro de mongosh, ejecutar:
# > db.adminCommand('ping')
# { ok: 1 }  ← Resultado esperado

# > use f-sri
# > show collections
# (ver colecciones creadas)

# Salir con: > exit
```

- [ ] Conectó a MongoDB sin errores
- [ ] `db.adminCommand('ping')` retorna `{ ok: 1 }`
- [ ] Puede ver colecciones en la BD "f-sri"
- [ ] Las colecciones incluyen índices esperados

## 📊 Verificación de Datos

```bash
# Dentro de MongoDB (mongosh):
db.users.count()              # Contar usuarios
db.invoices.count()           # Contar facturas
db.products.count()           # Contar productos
```

- [ ] Comandos ejecutados sin error
- [ ] Retornan números (0 es normal si es nueva BD)

## 📚 Verificación de API Docs

```bash
# Abrir en navegador:
http://localhost:3000/docs
```

- [ ] La página carga correctamente
- [ ] Muestra Swagger UI
- [ ] Puede ver endpoints listados
- [ ] Puede expandir endpoints

## 📋 Verificación de Logs

```bash
# Ver logs de la app
docker-compose logs -f app

# Presionar Ctrl+C para salir después de revisar

# Buscar:
# ✓ "🚀 Server running on port 3000"
# ✓ "🌐 Environment: development"
# ✓ "📄 API Docs: http://localhost:3000/docs"
# ✗ No debe haber errores críticos
```

- [ ] Logs de app muestran "Server running"
- [ ] No hay errores críticos
- [ ] No hay errores de conexión a MongoDB
- [ ] No hay errores de autenticación

## 🎯 Tests Rápidos

```bash
# Hacer un request a la API
curl -X GET http://localhost:3000/health \
  -H "Content-Type: application/json"

# Debe retornar JSON con status OK
```

- [ ] GET /health → Retorna 200 OK
- [ ] JSON es válido
- [ ] Status es "OK"

## ⚠️ Problemas Comunes y Soluciones

### Problema: "Container ... is unhealthy"

**Solución:**

1. Ver logs: `docker-compose logs mongodb`
2. Esperar más tiempo (a veces tarda >60s)
3. Reconstruir: `docker-compose build --no-cache && docker-compose up -d`

- [ ] Revisado logs si aplica

### Problema: "Cannot connect to MongoDB"

**Solución:**

1. Verificar credenciales en `.env`
2. Verificar hostname es "mongodb" (no localhost)
3. Verificar que MongoDB esté healthy: `docker-compose ps`

- [ ] Verificadas credenciales si aplica

### Problema: "Port 3000 already in use"

**Solución:**

1. Cambiar en `.env`: `PORT=3001`
2. Reconstruir: `docker-compose up -d`

- [ ] Cambiado puerto si aplica

## 🎉 Verificación Final

Todos los checks anteriores deben estar marcados (✓) y sin problemas.

**ANTES DE CONSIDERAR COMPLETADO:**

- [ ] `docker-compose ps` muestra ambos "healthy"
- [ ] `curl http://localhost:3000/health` retorna OK
- [ ] Puede acceder a http://localhost:3000/docs
- [ ] Puede conectar a MongoDB con mongosh
- [ ] Los logs no muestran errores críticos
- [ ] Ha esperado al menos 60 segundos después de up -d

## ✅ Estado Final

Si todos los items están marcados:

```
✅ CONFIGURACIÓN COMPLETADA Y FUNCIONAL
✅ LISTO PARA DESARROLLO/DESPLIEGUE
```

---

## 🔄 Próximos Pasos

1. **Para Desarrollo:**
   - Usa `docker-compose logs -f app` para ver logs en vivo
   - API disponible en `http://localhost:3000`
   - Documentación en `http://localhost:3000/docs`

2. **Para Producción:**
   - Lee `DOCKER_DEPLOY.md`
   - Actualiza variables de entorno
   - Configura backups
   - Implementa monitoreo

3. **Para Debugging:**
   - Ver logs: `docker-compose logs [servicio]`
   - Acceder a shell: `docker-compose exec app sh`
   - Acceder a MongoDB: `docker-compose exec mongodb mongosh ...`

---

**Fecha:** 28 de enero de 2026  
**Versión:** 1.0.0  
**Estado:** ✅ Verificación Completa
