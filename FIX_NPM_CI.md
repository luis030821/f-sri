# 🔧 Solución: Error de npm ci en Docker

## Problema

```
npm error The `npm ci` command can only install with an existing package-lock.json
```

## Causa

El Dockerfile estaba usando `npm ci` que requiere un `package-lock.json` preexistente. Si no existe, falla.

## Solución Aplicada ✅

Se actualizó el Dockerfile para usar `npm install` que es más flexible:

```dockerfile
# Antes (❌ Fallaba)
RUN npm ci

# Después (✅ Funciona)
RUN npm install
```

Y se agregó la copia explícita del `package-lock.json`:

```dockerfile
COPY package*.json ./
COPY package-lock.json* ./  # ← Agregado
```

## Por qué funciona ahora

1. **`npm install`** - Funciona con o sin `package-lock.json`
2. **`COPY package-lock.json*`** - El asterisco hace que sea opcional
3. **`npm install --only=production`** - En el runtime para optimizar

## Verificar que funcione

```bash
# Reconstruir imagen
docker-compose build

# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f app
```

## Diferencia: npm ci vs npm install

| Comando       | Con package-lock.json | Sin package-lock.json |
| ------------- | --------------------- | --------------------- |
| `npm ci`      | ✅ Funciona           | ❌ Falla              |
| `npm install` | ✅ Funciona           | ✅ Funciona           |

**Conclusión:** `npm install` es más flexible para CI/CD en Docker.

---

**Archivo actualizado:** Dockerfile  
**Cambios:** Líneas 13 y 38  
**Estado:** ✅ Resuelto
