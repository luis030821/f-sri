# 📑 Tabla de Contenidos - Configuración Docker F-SRI

## 📌 Comienza Aquí (El Mínimo Necesario)

| Archivo                  | Tiempo | Propósito                 | Acción   |
| ------------------------ | ------ | ------------------------- | -------- |
| **00_LEEME_PRIMERO.txt** | 2 min  | Introducción visual       | Leer     |
| **QUICK_START.md**       | 5 min  | 4 pasos para empezar      | Ejecutar |
| **.env.docker**          | N/A    | Variables (copiar a .env) | Copiar   |
| **generate-secrets.sh**  | 1 min  | Generar secretos          | Ejecutar |
| **deploy.sh start**      | 2 min  | Iniciar servicios         | Ejecutar |

---

## 📚 Documentación por Nivel

### 🟢 NIVEL 1: Principiante (Quiero empezar YA)

| Archivo          | Líneas | Tiempo | Contenido          |
| ---------------- | ------ | ------ | ------------------ |
| QUICK_START.md   | 120    | 5 min  | Pasos para empezar |
| README_DOCKER.md | 280    | 8 min  | Resumen visual     |

**Resultado esperado:** Servicios corriendo en 15 minutos

---

### 🟡 NIVEL 2: Intermedio (Quiero entender)

| Archivo          | Líneas | Tiempo | Contenido         |
| ---------------- | ------ | ------ | ----------------- |
| DOCKER_READY.md  | 350    | 10 min | Qué se configuró  |
| DOCKER_CONFIG.md | 450    | 20 min | Detalles técnicos |

**Resultado esperado:** Entender la arquitectura completa

---

### 🔴 NIVEL 3: Avanzado (Voy a producción)

| Archivo           | Líneas | Tiempo | Contenido       |
| ----------------- | ------ | ------ | --------------- |
| DOCKER_DEPLOY.md  | 400    | 20 min | Guía detallada  |
| SETUP_COMPLETE.md | 350    | 15 min | Checklist final |

**Resultado esperado:** Listo para desplegar en producción

---

### ⚫ NIVEL 4: Referencia (Índices y tablas)

| Archivo              | Líneas | Tiempo | Contenido      |
| -------------------- | ------ | ------ | -------------- |
| INDEX.md             | 300    | 10 min | Índice maestro |
| FINAL_SUMMARY.md     | 250    | 8 min  | Resumen final  |
| 00_LEEME_PRIMERO.txt | 200    | 5 min  | Introducción   |

**Resultado esperado:** Navegar fácilmente la documentación

---

## 🐳 Archivos Docker (Qué hace cada uno)

| Archivo                | Líneas | Propósito            | Cuándo tocarlo          |
| ---------------------- | ------ | -------------------- | ----------------------- |
| **Dockerfile**         | 61     | Construir imagen App | Cambiar Node.js version |
| **docker-compose.yml** | 114    | Orquestar servicios  | Agregar servicios       |
| **.dockerignore**      | 43     | Optimizar imagen     | Excluir archivos        |

---

## 🔧 Configuración (Variables y Scripts de Inicio)

| Archivo           | Tipo     | Propósito               | Editar?                   |
| ----------------- | -------- | ----------------------- | ------------------------- |
| **.env.docker**   | Template | 25 variables de entorno | Sí (copiar a .env)        |
| **init-mongo.js** | Script   | Inicializar MongoDB     | Solo si necesitas cambiar |

---

## 🚀 Scripts Disponibles

### Linux/Mac

| Script                  | Comandos | Requisito | Uso                     |
| ----------------------- | -------- | --------- | ----------------------- |
| **deploy.sh**           | 11       | bash      | `./deploy.sh [comando]` |
| **Makefile**            | 20+      | make      | `make [target]`         |
| **generate-secrets.sh** | 1        | openssl   | Generar secretos        |

### Windows

| Script                   | Comandos | Requisito  | Uso                    |
| ------------------------ | -------- | ---------- | ---------------------- |
| **deploy.bat**           | 11       | cmd.exe    | `deploy.bat [comando]` |
| **generate-secrets.bat** | 1        | PowerShell | Guía interactiva       |

---

## 📊 Resumen de Variables de Entorno (25)

### Por Categoría

#### 🖥️ Servidor (2)

```
NODE_ENV                    → development/production
PORT                        → 3000 (por defecto)
```

#### 🗄️ Base de Datos (5)

```
MONGO_URI                   → Construida automáticamente
MONGO_USER                  → sriuser
MONGO_PASSWORD              → [CAMBIAR EN PRODUCCIÓN]
MONGO_DB_NAME               → f-sri
MONGO_PORT                  → 27017
```

#### 🔐 Seguridad (4)

```
JWT_SECRET                  → [GENERAR CON openssl]
ENCRYPTION_KEY              → [GENERAR CON openssl]
MASTER_REGISTRATION_KEY     → [CAMBIAR]
DISABLE_REGISTRATION        → false/true
```

#### 👥 Registro (3)

```
ALLOWED_RUCS                → [Opcional]
INVITATION_CODES            → [Opcional]
DISABLE_REGISTRATION        → false/true
```

#### 🌐 CORS (2)

```
ALLOWED_ORIGINS             → localhost:4200,localhost:3000
CORS_DISABLED               → false/true
```

#### 📧 Email (3)

```
EMAIL_SERVICE               → gmail/outlook/etc
EMAIL_USER                  → [TU CORREO]
EMAIL_PASSWORD              → [TU PASSWORD O APP PASSWORD]
```

#### 🇪🇨 Integración SRI (3)

```
SRI_ENVIRONMENT             → 1 (pruebas) / 2 (producción)
SRI_RECEPCION_URL_PRUEBAS   → [URL SRI]
SRI_RECEPCION_URL_PRODUCCION→ [URL SRI]
```

#### 💾 Almacenamiento (3)

```
PDF_STORAGE_PROVIDER        → local / cloudinary
CLOUDINARY_CLOUD_NAME       → [Si usa Cloudinary]
CLOUDINARY_API_KEY          → [Si usa Cloudinary]
CLOUDINARY_API_SECRET       → [Si usa Cloudinary]
```

---

## ✅ Checklist de Implementación

### Archivos Creados

- [x] Dockerfile (61 líneas)
- [x] docker-compose.yml (114 líneas)
- [x] .dockerignore (43 líneas)
- [x] .env.docker (plantilla)
- [x] init-mongo.js (script)
- [x] deploy.sh (Linux/Mac)
- [x] deploy.bat (Windows)
- [x] Makefile (Linux/Mac)
- [x] generate-secrets.sh (Linux/Mac)
- [x] generate-secrets.bat (Windows)

### Documentación Creada

- [x] QUICK_START.md
- [x] README_DOCKER.md
- [x] DOCKER_READY.md
- [x] DOCKER_DEPLOY.md
- [x] DOCKER_CONFIG.md
- [x] SETUP_COMPLETE.md
- [x] INDEX.md
- [x] FINAL_SUMMARY.md
- [x] 00_LEEME_PRIMERO.txt
- [x] TABLE_OF_CONTENTS.md (este archivo)

### Modificados

- [x] .gitignore (actualizado)

---

## 🎯 Flujos de Trabajo Recomendados

### Workflow: Inicio Rápido ⚡ (15 minutos)

```
1. cp .env.docker .env
2. ./generate-secrets.sh
3. Editar .env
4. ./deploy.sh start
5. Verificar: docker-compose ps
```

### Workflow: Entendimiento Completo 📖 (1 hora)

```
1. Leer: QUICK_START.md
2. Leer: README_DOCKER.md
3. Leer: DOCKER_READY.md
4. Ejecutar: ./deploy.sh start
5. Leer: DOCKER_CONFIG.md
6. Explorar: docker-compose logs -f
```

### Workflow: Despliegue Producción 🚀 (2 horas)

```
1. Leer: DOCKER_DEPLOY.md (sección producción)
2. Leer: SETUP_COMPLETE.md
3. Leer: DOCKER_CONFIG.md (performance)
4. Generar secretos: ./generate-secrets.sh
5. Configurar .env (valores de producción)
6. Ejecutar: docker-compose build
7. Ejecutar: docker-compose up -d
8. Verificar: ./deploy.sh health
9. Configurar backups
10. Configurar monitoreo
```

---

## 🔍 Buscar Respuestas Rápidas

| Pregunta               | Dónde buscar        | Línea aprox |
| ---------------------- | ------------------- | ----------- |
| ¿Cómo empiezo?         | QUICK_START.md      | 30-60       |
| ¿Cómo despliego?       | DOCKER_DEPLOY.md    | 100-200     |
| ¿Qué variables hay?    | .env.docker         | 1-119       |
| ¿Cómo genero secretos? | generate-secrets.sh | 30-50       |
| ¿Qué servicios hay?    | docker-compose.yml  | 1-50        |
| ¿Cómo hago backup?     | DOCKER_DEPLOY.md    | 300-350     |
| ¿Qué es cada archivo?  | INDEX.md            | 70-150      |
| ¿Hay problemas?        | DOCKER_DEPLOY.md    | 400-500     |

---

## 📈 Estadísticas

### Cantidad

- **Archivos creados:** 15
- **Líneas de código:** ~2,600
- **Variables de entorno:** 25
- **Comandos script:** 30+

### Documentación

- **Archivos .md:** 9
- **Líneas totales:** ~3,000
- **Tiempo lectura total:** 90 minutos
- **Tiempo lectura rápido:** 15 minutos

### Docker

- **Servicios:** 2 (App + MongoDB)
- **Volúmenes:** 4
- **Networks:** 1
- **Health checks:** 2

---

## 🎓 Curva de Aprendizaje

```
Minuto  0: Lee 00_LEEME_PRIMERO.txt
Minuto  5: Lee QUICK_START.md
Minuto 10: Ejecuta: cp .env.docker .env
Minuto 12: Ejecuta: ./generate-secrets.sh
Minuto 15: Edita .env
Minuto 17: Ejecuta: ./deploy.sh start
Minuto 20: Verifica: docker-compose ps
Minuto 22: Verifica: curl http://localhost:3000/health
Minuto 25: ¡Listo! Ahora entender más...
Minuto 30: Lee DOCKER_READY.md
Minuto 60: Lee DOCKER_DEPLOY.md si necesitas producción
```

---

## 🚀 Comandos Quick Reference

```bash
# Preparación (primeros 5 minutos)
cp .env.docker .env
./generate-secrets.sh
nano .env

# Despliegue
./deploy.sh start         # Iniciar
docker-compose ps         # Estado
curl http://localhost:3000/health  # Verificar

# Mantenimiento
docker-compose logs -f app          # Ver logs
docker-compose exec mongodb mongosh # Acceso DB
./deploy.sh stop                    # Detener

# Para producción
./generate-secrets.sh     # Generar seguros
nano .env                 # Editar
docker-compose build      # Reconstruir
docker-compose up -d      # Iniciar
./deploy.sh health        # Verificar
```

---

## 📞 Soporte Rápido

| Problema             | Solución               | Documentación    |
| -------------------- | ---------------------- | ---------------- |
| "No sé cómo empezar" | QUICK_START.md         | L: 30-60         |
| "Puerto en uso"      | Cambiar PORT en .env   | DOCKER_DEPLOY.md |
| "MongoDB no inicia"  | Ver logs               | DOCKER_DEPLOY.md |
| "App no conecta"     | Verificar credenciales | DOCKER_DEPLOY.md |
| "¿Cómo hago backup?" | mongodump              | DOCKER_DEPLOY.md |
| "Tengo error X"      | DOCKER_DEPLOY.md       | L: 400-500       |

---

## 🎯 Próximos Pasos

**AHORA:** Abre **QUICK_START.md**

**LUEGO:** Sigue los 4 pasos

**DESPUÉS:** Explora los otros archivos según necesites

---

**Versión:** 1.0.0  
**Fecha:** 28 de enero de 2026  
**Estado:** ✅ Completo
