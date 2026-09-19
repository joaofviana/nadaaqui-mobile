# Sobe o app no Supabase live (nao WireMock).
# 1) Dashboard -> Settings -> API -> anon public
#    https://supabase.com/dashboard/project/hanqanaaimzthlqtrmks/settings/api
# 2) Copie dart_defines.json.example para dart_defines.json e cole a key.
# 3) .\tool\run_live.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$defines = Join-Path $root 'dart_defines.json'
if (-not (Test-Path $defines)) {
  Copy-Item (Join-Path $root 'dart_defines.json.example') $defines
  Write-Host "Criei dart_defines.json. Cole a anon key do dashboard e rode de novo."
  Write-Host "https://supabase.com/dashboard/project/hanqanaaimzthlqtrmks/settings/api"
  exit 1
}

$json = Get-Content $defines -Raw
if ($json -match 'COLE_AQUI' -or $json -notmatch 'SUPABASE_ANON_KEY"\s*:\s*"[A-Za-z0-9]') {
  Write-Host "dart_defines.json ainda nao tem a anon key. Cole do dashboard:"
  Write-Host "https://supabase.com/dashboard/project/hanqanaaimzthlqtrmks/settings/api"
  exit 1
}

Write-Host "flutter run --dart-define-from-file=dart_defines.json  (LIVE hanqanaaimzthlqtrmks)"
flutter run --dart-define-from-file=dart_defines.json @args
