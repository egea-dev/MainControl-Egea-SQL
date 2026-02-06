# =====================================================================
# SCRIPT DE MIGRACIÓN ALTERNATIVO: SUPABASE -> POSTGRESQL (COOLIFY)
# Sin necesidad de pg_dump/psql instalados localmente
# =====================================================================

$ErrorActionPreference = "Stop"

Write-Host "`n🚀 Iniciando migración de datos (Método Alternativo)..." -ForegroundColor Cyan
Write-Host "Este script usa la API de Supabase para extraer datos y SQL directo para importar.`n" -ForegroundColor Yellow

# Configuración automática desde .env
$SUPABASE_MAIN_URL = "https://jyaudpctcqcuskzwmism.supabase.co"
$SUPABASE_MAIN_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5YXVkcGN0Y3FjdXNrendtaXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTQwMTksImV4cCI6MjA4MTk3MDAxOX0.axwqydev8DYfkhqK1eUsgl0x_9yI41OXicnHcaqeXNs"
$SUPABASE_PROD_URL = "https://zslcblcetrhbsdirkvza.supabase.co"
$SUPABASE_PROD_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzbGNibGNldHJoYnNkaXJrdnphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzNTMxMzUsImV4cCI6MjA4MTkyOTEzNX0.-w4DP6Y3VbBy9cXgWYClv5IBu2JNhgtWBYlP2WzpKPY"

Write-Host "Usando credenciales del .env..." -ForegroundColor Green

# Crear carpeta temporal
$tempDir = "data_export_json"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Función para exportar tabla vía API REST
function Export-SupabaseTable {
    param($url, $key, $table, $outputFile)
    
    Write-Host "Exportando $table..."
    
    $headers = @{
        "apikey"        = $key
        "Authorization" = "Bearer $key"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$url/rest/v1/$table" -Headers $headers -Method Get
        $response | ConvertTo-Json -Depth 10 | Out-File $outputFile -Encoding UTF8
        Write-Host "  ✓ $($response.Count) registros exportados" -ForegroundColor Green
        return $response.Count
    }
    catch {
        Write-Host "  ⚠ Error al exportar $table : $_" -ForegroundColor Red
        return 0
    }
}

# Exportar tablas de MAIN
Write-Host "`n--- PASO 1: Exportando datos de MAIN... ---" -ForegroundColor Yellow
$tablesMain = @("profiles", "groups", "profile_groups", "screens", "screen_data", "vehicles", "task_vehicles", "system_config", "audit_logs")

$mainCounts = @{}
foreach ($table in $tablesMain) {
    $count = Export-SupabaseTable -url $SUPABASE_MAIN_URL -key $SUPABASE_MAIN_KEY -table $table -outputFile "$tempDir/main_$table.json"
    $mainCounts[$table] = $count
}

# Exportar tablas de PRODUCTIVITY
Write-Host "`n--- PASO 2: Exportando datos de PRODUCTIVITY... ---" -ForegroundColor Yellow
$tablesProd = @("comercial_customers", "comercial_orders", "produccion_work_orders", "almacen_inventory", "almacen_shipments", "shipment_packages")

$prodCounts = @{}
foreach ($table in $tablesProd) {
    $count = Export-SupabaseTable -url $SUPABASE_PROD_URL -key $SUPABASE_PROD_KEY -table $table -outputFile "$tempDir/prod_$table.json"
    $prodCounts[$table] = $count
}

# Resumen
Write-Host "`n--- RESUMEN DE EXPORTACIÓN ---" -ForegroundColor Cyan
Write-Host "`nMAIN:"
$mainCounts.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key): $($_.Value) registros" }
Write-Host "`nPRODUCTIVITY:"
$prodCounts.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key): $($_.Value) registros" }

Write-Host "`n✅ Exportación completada. Los archivos JSON están en '$tempDir'." -ForegroundColor Green
Write-Host "`n📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host "  Los datos se han exportado a JSON. Ahora ejecuta el script de conversión a SQL." -ForegroundColor White
Write-Host "  Comando: .\convert_json_to_sql.ps1" -ForegroundColor Cyan
