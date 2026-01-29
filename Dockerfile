# =============================================
# Etapa 1: Builder
# =============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY package-lock.json* ./
COPY tsconfig.json ./

# Instalar dependencias (npm install es más flexible que npm ci)
RUN npm install

# Copiar código fuente
COPY src ./src

# Compilar TypeScript a JavaScript
RUN npm run build

# =============================================
# Etapa 2: Runtime
# =============================================
FROM node:20-alpine

WORKDIR /app

# Instalar dumb-init para manejar signals correctamente
RUN apk add --no-cache dumb-init

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Copiar package.json para instalación de dependencias de producción
COPY package*.json ./
COPY package-lock.json* ./

# Instalar solo dependencias de producción
RUN npm install --only=production && npm cache clean --force

# Copiar código compilado desde el builder
COPY --from=builder /app/dist ./dist

# Cambiar propietario de los archivos
RUN chown -R nodejs:nodejs /app

# Cambiar al usuario no-root
USER nodejs

# Exponer puerto (puede ser sobrescrito por docker-compose)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => {if (res.statusCode !== 200) throw new Error(res.statusCode)}).on('error', (e) => {throw e})"

# Usar dumb-init para ejecutar la aplicación
ENTRYPOINT ["dumb-init", "--"]

# Comando por defecto
CMD ["node", "dist/index.js"]
