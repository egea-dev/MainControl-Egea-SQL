# Script de exportación de datos de Supabase
$ErrorActionPreference = "Stop"

Write-Host "`n🚀 Exportando datos de Supabase..." -ForegroundColor Cyan

# Leer configuración
$config = Get-Content "config.json" | ConvertFrom-Json

# Crear carpeta
$tempDir = "data_export_json"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Función de exportación
function Export-Table {
    param($url, $key, $table, $file)
    
    Write-Host "Exportando $table..."
    
    $headers = @{
        "apikey"        = $key
        "Authorization" = "Bearer $key"
    }
    
    try {
        $data = Invoke-RestMethod -Uri "$url/rest/v1/$table" -Headers $headers -Method Get
        $data | ConvertTo-Json -Depth 10 | Out-File $file -Encoding UTF8
        Write-Host "  ✓ $($data.Count) registros" -ForegroundColor Green
        return $data.Count
    }
    catch {
        Write-Host "  ⚠ Error: $_" -ForegroundColor Red
        return 0
    }
}

# Exportar MAIN
Write-Host "`n--- MAIN ---" -ForegroundColor Yellow
$tablesMain = @("profiles", "groups", "profile_groups", "screens", "screen_data", "vehicles", "task_vehicles", "system_config", "audit_logs")

$mainTotal = 0
foreach ($t in $tablesMain) {
    $count = Export-Table -url $config.main.url -key $config.main.key -table $t -file "$tempDir/main_$t.json"
    $mainTotal += $count
}

# Exportar PRODUCTIVITY
Write-Host "`n--- PRODUCTIVITY ---" -ForegroundColor Yellow
$tablesProd = @("comercial_customers", "comercial_orders", "produccion_work_orders", "almacen_inventory", "almacen_shipments", "shipment_packages")

$prodTotal = 0
foreach ($t in $tablesProd) {
    $count = Export-Table -url $config.productivity.url -key $config.productivity.key -table $t -file "$tempDir/prod_$t.json"
    $prodTotal += $count
}

Write-Host "`n✅ COMPLETADO" -ForegroundColor Green
Write-Host "MAIN: $mainTotal registros" -ForegroundColor Cyan
Write-Host "PRODUCTIVITY: $prodTotal registros" -ForegroundColor Cyan
Write-Host "`nArchivos en: $tempDir" -ForegroundColor White
