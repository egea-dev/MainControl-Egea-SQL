# =====================================================================
# SCRIPT DE MIGRACIÓN: SUPABASE -> POSTGRESQL (COOLIFY)
# =====================================================================

$ErrorActionPreference = "Stop"

Write-Host "`n🚀 Iniciando preparación de migración de datos..." -ForegroundColor Cyan

# 1. Configuración de URLs
$POSTGRES_TARGET = "postgres://postgres:PHR3CVkDOXYCRwKPFRuh8FN8gtVuf76KGZqTrbaV3MJSo1V6hjKqSNmfmouFPPSs@bkcos4gcs84k8wc088o8448w:5432/postgres"

Write-Host "`n--- PASO 1: Credenciales de Supabase ---" -ForegroundColor Yellow
$SUPABASE_MAIN = Read-Host "Pega la Connection String de Supabase MAIN"
$SUPABASE_PROD = Read-Host "Pega la Connection String de Supabase PRODUCTIVITY"

if (-not $SUPABASE_MAIN -or -not $SUPABASE_PROD) {
    Write-Error "Debes proporcionar ambas URLs de Supabase para continuar."
}

# Crear carpeta temporal
$tempDir = "data_dump_temp"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# 2. Exportación de MAIN
Write-Host "`n--- PASO 2: Exportando datos de MAIN... ---" -ForegroundColor Yellow
$tablesMain = @("profiles", "groups", "profile_groups", "screens", "screen_data", "vehicles", "task_vehicles", "system_config", "audit_logs")

foreach ($table in $tablesMain) {
    Write-Host "Exportando $table..."
    # Usamos pg_dump para extraer solo los INSERTs de datos
    & pg_dump --data-only --inserts --column-inserts --table=$table $SUPABASE_MAIN --file="$tempDir/main_$table.sql"
    
    # Ajustar el esquema al nuevo destino 'main'
    $content = Get-Content "$tempDir/main_$table.sql"
    $content = $content -replace "INSERT INTO public\.$table", "INSERT INTO main.$table"
    Set-Content "$tempDir/main_$table.sql" $content
}

# 3. Exportación de PRODUCTIVITY
Write-Host "`n--- PASO 3: Exportando datos de PRODUCTIVITY... ---" -ForegroundColor Yellow
$tablesProd = @("comercial_customers", "comercial_orders", "produccion_work_orders", "almacen_inventory", "almacen_shipments", "shipment_packages")

foreach ($table in $tablesProd) {
    Write-Host "Exportando $table..."
    & pg_dump --data-only --inserts --column-inserts --table=$table $SUPABASE_PROD --file="$tempDir/prod_$table.sql"
    
    # Ajustar el esquema al nuevo destino 'productivity'
    $content = Get-Content "$tempDir/prod_$table.sql"
    $content = $content -replace "INSERT INTO public\.$table", "INSERT INTO productivity.$table"
    Set-Content "$tempDir/prod_$table.sql" $content
}

# 4. Importación
Write-Host "`n--- PASO 4: Importando a Nuevo PostgreSQL... ---" -ForegroundColor Yellow

# Desactivar triggers temporalmente para evitar problemas de FK
Write-Host "Desactivando triggers temporalmente..."
& psql $POSTGRES_TARGET -c "SET session_replication_role = 'replica';"

# Importar en orden de dependencia (Main primero)
foreach ($file in (Get-ChildItem "$tempDir/main_*.sql")) {
    Write-Host "Importando $($file.Name)..."
    & psql $POSTGRES_TARGET --file=$file.FullName > $null
}

# Importar Productivity
foreach ($file in (Get-ChildItem "$tempDir/prod_*.sql")) {
    Write-Host "Importando $($file.Name)..."
    & psql $POSTGRES_TARGET --file=$file.FullName > $null
}

# Reactivar triggers
Write-Host "Reactivando triggers..."
& psql $POSTGRES_TARGET -c "SET session_replication_role = 'origin';"

Write-Host "`n✅ ¡MIGRACIÓN COMPLETADA CON ÉXITO!" -ForegroundColor Green
Write-Host "Ya puedes borrar la carpeta '$tempDir' si todo está correcto."
