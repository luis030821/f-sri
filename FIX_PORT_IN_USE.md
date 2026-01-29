# 🔧 Solución: Puerto 3000 Ya Está en Uso

## Problema

```
Bind for :::3000 failed: port is already allocated
Error: failed to set up container networking
```

## Causa

El puerto 3000 está siendo usado por otra aplicación o contenedor Docker.

---

## ✅ Solución Rápida (3 opciones)

### Opción 1: Usar un Puerto Diferente (RECOMENDADO)

**1. Editar `.env`**

```bash
# Cambiar la línea:
PORT=3000

# A:
PORT=3001  # o 8000, 8080, 9000, etc.
```

**2. Detener y reconstruir**

```bash
docker-compose down
docker-compose up -d
```

**3. Verificar**

```bash
curl http://localhost:3001/health
# Debe funcionar con el nuevo puerto
```

✅ **Ventaja:** Simple, no interfiere con otras aplicaciones

---

### Opción 2: Liberar el Puerto 3000 (Linux/Mac)

**1. Ver qué está usando puerto 3000**

```bash
lsof -i :3000
# O en algunos sistemas:
netstat -tulpn | grep :3000
```

**2. Matar el proceso**

```bash
# Linux/Mac
kill -9 <PID>

# Ejemplo si el resultado es "node 12345":
kill -9 12345
```

**3. Iniciar Docker nuevamente**

```bash
docker-compose up -d
```

✅ **Ventaja:** Recupera el puerto 3000

⚠️ **Desventaja:** Requiere identificar qué está usando el puerto

---

### Opción 3: Liberar el Puerto en Windows

**1. Abrir PowerShell como administrador**

**2. Ver qué está usando puerto 3000**

```powershell
netstat -ano | findstr :3000
```

**3. Matar el proceso**

```powershell
# Ejemplo: taskkill /PID 12345 /F
taskkill /PID <PID> /F
```

**4. Iniciar Docker nuevamente**

```bash
docker-compose up -d
```

✅ **Ventaja:** Recupera el puerto 3000

⚠️ **Desventaja:** Requiere privilegios de administrador

---

## 🚀 Opción Recomendada: Puerto Diferente

Es la más segura y rápida:

```bash
# 1. Editar .env
nano .env

# Cambiar:
PORT=3000
# A:
PORT=3001

# 2. Reconstruir
docker-compose down
docker-compose up -d

# 3. Verificar
docker-compose ps
curl http://localhost:3001/health
```

---

## 📊 Puertos Alternativos Sugeridos

| Puerto | Tipo       | Recomendación        |
| ------ | ---------- | -------------------- |
| 3000   | Desarrollo | Ocupado actualmente  |
| 3001   | Desarrollo | ✅ Próxima opción    |
| 8000   | Desarrollo | ✅ Común             |
| 8080   | Web        | ✅ Muy usado         |
| 9000   | Desarrollo | ✅ Seguro            |
| 5000   | Flask      | ⚠️ Posible conflicto |

---

## 🔍 Verificar Conflictos

### Linux/Mac

```bash
# Buscar todos los procesos en puertos comunes
lsof -i :3000
lsof -i :3001
lsof -i :8000
lsof -i :8080
```

### Windows PowerShell

```powershell
netstat -ano | findstr :3000
netstat -ano | findstr :3001
netstat -ano | findstr :8000
netstat -ano | findstr :8080
```

---

## ⚠️ Casos Comunes

### Caso 1: Otro Contenedor Docker usa el Puerto

```bash
# Ver todos los contenedores
docker ps -a

# Detener el contenedor conflictivo
docker stop <container-name>

# O eliminar si no lo necesitas
docker rm <container-name>
```

### Caso 2: Node.js/npm previo corre en ese puerto

```bash
# Buscar procesos node
ps aux | grep node

# Matar proceso específico
kill -9 <PID>
```

### Caso 3: Otra aplicación usa el puerto

- Cambiar el puerto (Opción 1 - RECOMENDADO)
- O cambiar el puerto de la otra aplicación

---

## ✅ Verificación Final

Después de resolver, verificar:

```bash
# 1. Puerto debe estar libre
docker-compose ps
# f-sri-app debe mostrar puerto correcto

# 2. API debe responder
curl http://localhost:3001/health
# Retorna: {"status":"OK",...}

# 3. MongoDB debe estar healthy
docker-compose logs mongodb | grep "healthy"
```

---

## 🎯 Resumen de Pasos

**Si eliges Opción 1 (RECOMENDADA):**

```bash
# 1. Editar .env
nano .env
# Cambiar PORT=3000 a PORT=3001

# 2. Reconstruir
docker-compose down
docker-compose up -d

# 3. Esperar 60 segundos
sleep 60

# 4. Verificar
docker-compose ps
curl http://localhost:3001/health
```

**Tiempo total:** 2-3 minutos

---

**Recomendación:** Usa la Opción 1 (puerto diferente).  
Es la más simple y no interfiere con otras aplicaciones.

---

**Archivo a editar:** `.env`  
**Línea a cambiar:** `PORT=3000` → `PORT=3001`  
**Estado:** ✅ Fácil de resolver
