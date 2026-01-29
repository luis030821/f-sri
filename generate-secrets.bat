@echo off
REM Script para generar variables de seguridad para F-SRI (Windows)
REM Uso: generate-secrets.bat

setlocal enabledelayedexpansion

cls

echo.
echo ========================================
echo   Generador de Variables de Seguridad
echo   F-SRI
echo ========================================
echo.

REM Generar valores aleatorios
echo Generando variables de seguridad...
echo.

echo Los siguientes valores deben copiarse a tu archivo .env:
echo.

echo ========================================
echo VARIABLES DE SEGURIDAD
echo ========================================
echo.

REM En Windows, generar valores aleatorios es más complejo
REM Opción 1: Usar PowerShell (recomendado en Windows 7+)
REM Opción 2: Usar valores de ejemplo

echo [IMPORTANTE] Para generar valores seguros, abre PowerShell y ejecuta:
echo.
echo 1. Para JWT_SECRET ^(32 caracteres hex^):
echo    [Convert]::ToHexString([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(16))
echo.

echo 2. Para ENCRYPTION_KEY ^(32 caracteres hex^):
echo    [Convert]::ToHexString([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(16))
echo.

echo 3. Para MONGO_PASSWORD ^(contraseña fuerte^):
echo    Usa una contraseña fuerte o genera con:
echo    [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(24))
echo.

echo 4. Para MASTER_REGISTRATION_KEY ^(16 caracteres hex^):
echo    [Convert]::ToHexString([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(8))
echo.

echo ========================================
echo EJEMPLO DE FORMATO
echo ========================================
echo.

echo Agrega lo siguiente a tu archivo .env:
echo.
echo JWT_SECRET=^<valor_generado_en_powershell^>
echo ENCRYPTION_KEY=^<valor_generado_en_powershell^>
echo MONGO_PASSWORD=^<contraseña_fuerte^>
echo MASTER_REGISTRATION_KEY=^<valor_generado_en_powershell^>
echo.

echo ========================================
echo ALTERNATIVA: Generar con OpenSSL
echo ========================================
echo.

echo Si tienes OpenSSL instalado, ejecuta:
echo.
echo   openssl rand -hex 32
echo   openssl rand -hex 32
echo   openssl rand -base64 32
echo   openssl rand -hex 16
echo.

echo ========================================
echo NOTAS IMPORTANTES
echo ========================================
echo.
echo [!] Mantén estos valores confidenciales
echo [!] NO los compartas en correos o chats
echo [!] NO los commits en Git
echo [!] Guarda una copia segura
echo [!] Úsalos en producción
echo.

REM Ofrecer abrir el archivo .env
echo ========================================
echo PRÓXIMOS PASOS
echo ========================================
echo.

set /p response="Deseas abrir el archivo .env para editar? (s/n): "
if /i "%response%"=="s" (
    if exist .env (
        start .env
    ) else (
        echo .
        echo Creando .env desde .env.docker...
        copy .env.docker .env
        start .env
    )
) else (
    echo.
    echo Para editar manualmente:
    echo   1. Abre el archivo .env
    echo   2. Agrega los valores generados
    echo   3. Guarda el archivo
    echo   4. Ejecuta: docker-compose up -d
)

echo.
pause
