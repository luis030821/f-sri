@echo off
REM Script de utilidad para Docker Compose (Windows)
REM Uso: deploy.bat [comando]

setlocal enabledelayedexpansion

REM Colores (usando chcp 65001 para UTF-8)
chcp 65001 >nul 2>&1

if "%1"=="" (
    call :show_help
    exit /b 0
)

if "%1"=="build" (
    call :build
) else if "%1"=="start" (
    call :start
) else if "%1"=="stop" (
    call :stop
) else if "%1"=="restart" (
    call :restart
) else if "%1"=="status" (
    call :status
) else if "%1"=="logs" (
    call :logs %2
) else if "%1"=="rebuild" (
    call :rebuild
) else if "%1"=="clean" (
    call :clean
) else if "%1"=="health" (
    call :health
) else if "%1"=="mongo" (
    call :mongo_cli
) else if "%1"=="shell" (
    call :app_shell
) else if "%1"=="secrets" (
    call :generate_secrets
) else if "%1"=="help" (
    call :show_help
) else (
    echo [ERROR] Comando desconocido: %1
    call :show_help
    exit /b 1
)

exit /b 0

:check_docker
echo [INFO] Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker no esta instalado o no esta en el PATH
    exit /b 1
)
docker --version
echo [OK] Docker encontrado
exit /b 0

:check_docker_compose
echo [INFO] Verificando Docker Compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose no esta instalado
    exit /b 1
)
docker-compose --version
echo [OK] Docker Compose encontrado
exit /b 0

:check_env_file
if not exist ".env" (
    echo [ADVERTENCIA] .env no existe. Creando desde .env.docker...
    if not exist ".env.docker" (
        echo [ERROR] Archivo .env.docker no encontrado
        exit /b 1
    )
    copy .env.docker .env >nul
    echo [ADVERTENCIA] IMPORTANTE: Edita .env con valores especificos para tu entorno
)
echo [OK] Archivo .env encontrado
exit /b 0

:build
echo.
echo ========================================
echo   Construyendo imagenes Docker
echo ========================================
call :check_docker
if errorlevel 1 exit /b 1
call :check_docker_compose
if errorlevel 1 exit /b 1
docker-compose build
echo [OK] Imagenes construidas
exit /b 0

:start
echo.
echo ========================================
echo   Iniciando servicios
echo ========================================
call :check_docker
if errorlevel 1 exit /b 1
call :check_docker_compose
if errorlevel 1 exit /b 1
call :check_env_file
if errorlevel 1 exit /b 1
docker-compose up -d
echo [ADVERTENCIA] Esperando a que MongoDB este disponible...
timeout /t 5 /nobreak
call :status
echo [OK] Servicios iniciados
exit /b 0

:stop
echo.
echo ========================================
echo   Deteniendo servicios
echo ========================================
call :check_docker
if errorlevel 1 exit /b 1
call :check_docker_compose
if errorlevel 1 exit /b 1
docker-compose down
echo [OK] Servicios detenidos
exit /b 0

:restart
echo.
echo ========================================
echo   Reiniciando servicios
echo ========================================
call :stop
if errorlevel 1 exit /b 1
call :start
if errorlevel 1 exit /b 1
exit /b 0

:status
echo.
echo ========================================
echo   Estado de los servicios
echo ========================================
docker-compose ps
exit /b 0

:logs
echo.
echo ========================================
echo   Mostrando logs
echo ========================================
if "%~1"=="" (
    docker-compose logs -f
) else (
    docker-compose logs -f %~1
)
exit /b 0

:rebuild
echo.
echo ========================================
echo   Reconstruyendo aplicacion
echo ========================================
call :check_env_file
if errorlevel 1 exit /b 1
docker-compose down
if errorlevel 1 exit /b 1
docker-compose build
if errorlevel 1 exit /b 1
docker-compose up -d
if errorlevel 1 exit /b 1
echo [OK] Aplicacion reconstruida e iniciada
exit /b 0

:clean
echo.
echo ========================================
echo   Limpiando espacios y volumenes
echo ========================================
echo [ADVERTENCIA] Esto eliminara todos los datos de la base de datos
set /p confirm="Estas seguro? (s/n): "
if /i "%confirm%"=="s" (
    docker-compose down -v
    echo [OK] Limpieza completada
) else (
    echo [ADVERTENCIA] Limpieza cancelada
)
exit /b 0

:health
echo.
echo ========================================
echo   Comprobando salud del sistema
echo ========================================
call :check_docker
if errorlevel 1 exit /b 1
call :check_docker_compose
if errorlevel 1 exit /b 1

echo [INFO] Estado de los contenedores:
docker-compose ps
echo.

echo [INFO] Comprobando salud de la aplicacion:
timeout /t 2 /nobreak >nul
for /f "tokens=*" %%A in ('curl -s http://localhost:3000/health 2^>nul') do (
    if "%%A" neq "" (
        echo %%A
        echo [OK] API disponible
    )
)
exit /b 0

:mongo_cli
echo.
echo ========================================
echo   Accediendo a MongoDB CLI
echo ========================================
docker-compose exec mongodb mongosh -u sriuser -p sripassword --authenticationDatabase admin
exit /b 0

:app_shell
echo.
echo ========================================
echo   Accediendo a shell de la aplicacion
echo ========================================
docker-compose exec app sh
exit /b 0

:generate_secrets
echo.
echo ========================================
echo   Generando variables de seguridad
echo ========================================
echo [INFO] Nota: Asegúrate de tener OpenSSL instalado
echo [INFO] Genera valores seguros:
echo.
echo Opción 1: Usar PowerShell (Windows 10+)
echo   JWT_SECRET: ^[Convert^]::ToHexString(^[System.Security.Cryptography.RandomNumberGenerator^]::GetBytes(32^)^)
echo   ENCRYPTION_KEY: ^[Convert^]::ToHexString(^[System.Security.Cryptography.RandomNumberGenerator^]::GetBytes(16^)^)
echo.
echo Opción 2: Usar online (NO recomendado en producción)
echo   https://www.uuidgenerator.net/
exit /b 0

:show_help
echo.
echo Script de utilidad para F-SRI Docker
echo.
echo Uso: %0 [comando]
echo.
echo Comandos disponibles:
echo   build              Construir imagenes Docker
echo   start              Iniciar servicios
echo   stop               Detener servicios
echo   restart            Reiniciar servicios
echo   status             Ver estado de los servicios
echo   logs [servicio]    Ver logs (app, mongodb, o todos)
echo   rebuild            Reconstruir y reiniciar
echo   clean              Limpiar todo (CUIDADO: elimina datos)
echo   health             Comprobacion de salud del sistema
echo   mongo              Acceder a MongoDB CLI
echo   shell              Acceder a shell de la aplicacion
echo   secrets            Generar variables de seguridad
echo   help               Mostrar esta ayuda
echo.
echo Ejemplos:
echo   %0 start           :: Iniciar servicios
echo   %0 logs app        :: Ver logs de la aplicacion
echo   %0 logs mongodb    :: Ver logs de MongoDB
echo.
exit /b 0
