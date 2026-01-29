#!/bin/bash

# Script de utilidad para Docker Compose
# Uso: ./deploy.sh [comando]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Verificar que Docker esté instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado o no está en el PATH"
        exit 1
    fi
    print_success "Docker encontrado: $(docker --version)"
}

# Verificar que Docker Compose esté instalado
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose no está instalado"
        exit 1
    fi
    print_success "Docker Compose encontrado: $(docker-compose --version)"
}

# Verificar que el archivo .env exista
check_env_file() {
    if [ ! -f ".env" ]; then
        print_warning ".env no existe. Creando desde .env.docker..."
        if [ ! -f ".env.docker" ]; then
            print_error "Archivo .env.docker no encontrado"
            exit 1
        fi
        cp .env.docker .env
        print_warning "IMPORTANTE: Edita .env con valores específicos para tu entorno"
    fi
    print_success "Archivo .env encontrado"
}

# Construir imágenes
build() {
    print_header "Construyendo imágenes Docker"
    check_docker
    check_docker_compose
    docker-compose build
    print_success "Imágenes construidas"
}

# Iniciar servicios
start() {
    print_header "Iniciando servicios"
    check_docker
    check_docker_compose
    check_env_file
    docker-compose up -d
    print_success "Servicios iniciados"
    
    # Esperar a que MongoDB esté listo
    print_warning "Esperando a que MongoDB esté disponible..."
    sleep 5
    
    # Verificar estado
    status
}

# Detener servicios
stop() {
    print_header "Deteniendo servicios"
    check_docker
    check_docker_compose
    docker-compose down
    print_success "Servicios detenidos"
}

# Ver estado
status() {
    print_header "Estado de los servicios"
    docker-compose ps
}

# Ver logs
logs() {
    print_header "Mostrando logs"
    if [ -n "$1" ]; then
        docker-compose logs -f "$1"
    else
        docker-compose logs -f
    fi
}

# Reconstruir y reiniciar
rebuild() {
    print_header "Reconstruyendo aplicación"
    check_env_file
    docker-compose down
    docker-compose build
    docker-compose up -d
    print_success "Aplicación reconstruida e iniciada"
}

# Limpiar todo
clean() {
    print_header "Limpiando espacios y volúmenes"
    print_warning "Esto eliminará todos los datos de la base de datos"
    read -p "¿Estás seguro? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        docker-compose down -v
        print_success "Limpieza completada"
    else
        print_warning "Limpieza cancelada"
    fi
}

# Health check
health() {
    print_header "Comprobando salud del sistema"
    
    # Verificar Docker
    check_docker
    check_docker_compose
    
    # Verificar contenedores
    print_warning "Estado de los contenedores:"
    docker-compose ps
    
    # Verificar health de MongoDB
    print_warning "Health check de MongoDB:"
    docker-compose exec -T mongodb /bin/sh -c 'mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --eval "db.adminCommand(\"ping\")"' || print_error "MongoDB no responde"
    
    # Verificar salud de la app
    print_warning "Health check de la aplicación:"
    curl -s http://localhost:3000/health | grep -q "status" && print_success "API disponible" || print_error "API no disponible"
}

# Acceder a la CLI de MongoDB
mongo_cli() {
    print_header "Accediendo a MongoDB CLI"
    docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin
}

# Acceder a la shell del contenedor
app_shell() {
    print_header "Accediendo a shell de la aplicación"
    docker-compose exec app sh
}

# Generar variables de seguridad
generate_secrets() {
    print_header "Generando variables de seguridad"
    
    JWT_SECRET=$(openssl rand -hex 32)
    ENCRYPTION_KEY=$(openssl rand -hex 16)
    
    print_warning "Variables generadas (cópialas al archivo .env):"
    echo -e "${YELLOW}JWT_SECRET=${JWT_SECRET}${NC}"
    echo -e "${YELLOW}ENCRYPTION_KEY=${ENCRYPTION_KEY}${NC}"
}

# Mostrar ayuda
show_help() {
    echo -e "${BLUE}Script de utilidad para F-SRI Docker${NC}"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  build              Construir imágenes Docker"
    echo "  start              Iniciar servicios"
    echo "  stop               Detener servicios"
    echo "  restart            Reiniciar servicios"
    echo "  status             Ver estado de los servicios"
    echo "  logs [servicio]    Ver logs (app, mongodb, o todos)"
    echo "  rebuild            Reconstruir y reiniciar"
    echo "  clean              Limpiar todo (CUIDADO: elimina datos)"
    echo "  health             Comprobación de salud del sistema"
    echo "  mongo              Acceder a MongoDB CLI"
    echo "  shell              Acceder a shell de la aplicación"
    echo "  secrets            Generar variables de seguridad"
    echo "  help               Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start           # Iniciar servicios"
    echo "  $0 logs app        # Ver logs de la aplicación"
    echo "  $0 logs mongodb    # Ver logs de MongoDB"
}

# Main
main() {
    case "${1:-help}" in
        build)
            build
            ;;
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            stop
            start
            ;;
        status)
            status
            ;;
        logs)
            logs "$2"
            ;;
        rebuild)
            rebuild
            ;;
        clean)
            clean
            ;;
        health)
            health
            ;;
        mongo)
            mongo_cli
            ;;
        shell)
            app_shell
            ;;
        secrets)
            generate_secrets
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Comando desconocido: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
