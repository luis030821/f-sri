#!/bin/bash

# Script para generar variables de seguridad para F-SRI
# Uso: ./generate-secrets.sh

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Verificar que openssl está instalado
check_openssl() {
    if ! command -v openssl &> /dev/null; then
        echo -e "${RED}✗ OpenSSL no está instalado${NC}"
        echo "Por favor instala OpenSSL:"
        echo "  macOS: brew install openssl"
        echo "  Ubuntu/Debian: sudo apt-get install openssl"
        exit 1
    fi
    print_success "OpenSSL encontrado"
}

generate_secrets() {
    print_header "Generando Variables de Seguridad para F-SRI"
    
    check_openssl
    echo ""
    
    # Generar secretos
    print_warning "Generando secretos seguros..."
    echo ""
    
    JWT_SECRET=$(openssl rand -hex 32)
    ENCRYPTION_KEY=$(openssl rand -hex 32)
    MONGO_PASSWORD=$(openssl rand -base64 32)
    MASTER_KEY=$(openssl rand -hex 16)
    
    echo -e "${BLUE}Variables generadas:${NC}"
    echo ""
    
    echo -e "${YELLOW}JWT_SECRET=${NC}${GREEN}${JWT_SECRET}${NC}"
    echo -e "${YELLOW}ENCRYPTION_KEY=${NC}${GREEN}${ENCRYPTION_KEY}${NC}"
    echo -e "${YELLOW}MONGO_PASSWORD=${NC}${GREEN}${MONGO_PASSWORD}${NC}"
    echo -e "${YELLOW}MASTER_REGISTRATION_KEY=${NC}${GREEN}${MASTER_KEY}${NC}"
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Archivo de Configuración Generado${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Crear archivo temporal
    TEMP_ENV=$(mktemp)
    
    cat > "$TEMP_ENV" << EOF
# Variables de Seguridad Generadas Automáticamente
# Fecha: $(date)
# IMPORTANTE: Mantén estos valores confidenciales

# JWT Secret para firmar tokens (64 caracteres hex)
JWT_SECRET=${JWT_SECRET}

# Clave de encriptación para datos sensibles (64 caracteres hex)
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# Contraseña para MongoDB (base64)
MONGO_PASSWORD=${MONGO_PASSWORD}

# Clave maestra para registrar usuarios (32 caracteres hex)
MASTER_REGISTRATION_KEY=${MASTER_KEY}
EOF
    
    print_success "Archivo generado: $TEMP_ENV"
    echo ""
    echo -e "${YELLOW}Contenido del archivo:${NC}"
    cat "$TEMP_ENV"
    echo ""
    
    # Preguntar si guardar en .env
    echo ""
    read -p "¿Deseas agregar estos valores a tu archivo .env? (s/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if [ -f ".env" ]; then
            echo -e "${YELLOW}Haciendo backup de .env a .env.backup${NC}"
            cp .env .env.backup
            print_success "Backup creado"
        fi
        
        # Agregar valores
        echo "" >> .env
        echo "# Secretos generados - $(date)" >> .env
        echo "JWT_SECRET=${JWT_SECRET}" >> .env
        echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env
        echo "MONGO_PASSWORD=${MONGO_PASSWORD}" >> .env
        echo "MASTER_REGISTRATION_KEY=${MASTER_KEY}" >> .env
        
        print_success "Variables agregadas a .env"
    else
        echo -e "${YELLOW}Copia manualmente los valores del archivo: $TEMP_ENV${NC}"
    fi
    
    echo ""
    print_header "Checklist de Seguridad"
    echo ""
    echo "✓ JWT_SECRET: 64 caracteres (hex)"
    echo "✓ ENCRYPTION_KEY: 64 caracteres (hex)"
    echo "✓ MONGO_PASSWORD: Base64 (fuerte)"
    echo "✓ MASTER_REGISTRATION_KEY: 32 caracteres (hex)"
    echo ""
    echo -e "${YELLOW}⚠ IMPORTANTE:${NC}"
    echo "  1. Nunca compartas estos valores"
    echo "  2. Guarda una copia segura"
    echo "  3. NO los commits en Git"
    echo "  4. Úsalos en producción"
    echo ""
}

# Main
generate_secrets
