param(
  [string]$InputCsv = ".\\LEADS_TRACKER.csv",
  [int]$MaxTabs = 8,
  [string]$ExcludeFile = ".\\EXCLUDED_NUMBERS.txt",
  [switch]$OnlyUaeMobile
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $InputCsv)) {
  Write-Error "Input CSV not found: $InputCsv"
  exit 1
}

function Normalize-Phone {
  param([string]$Phone)
  if ([string]::IsNullOrWhiteSpace($Phone)) { return $null }

  $digits = ($Phone -replace "[^0-9]", "")
  if ([string]::IsNullOrWhiteSpace($digits)) { return $null }

  if ($digits.StartsWith("00")) {
    $digits = $digits.Substring(2)
  }

  return $digits
}

$rows = Import-Csv -Path $InputCsv -Delimiter ";"
$opened = 0

$excluded = @{}
if (Test-Path $ExcludeFile) {
  $excludeLines = Get-Content -Path $ExcludeFile
  foreach ($line in $excludeLines) {
    $n = Normalize-Phone -Phone $line
    if ($n) {
      $excluded[$n] = $true
    }
  }
}

foreach ($r in $rows) {
  if ($opened -ge $MaxTabs) { break }
  if ($r.status -ne "NEW") { continue }

  $phone = Normalize-Phone -Phone $r.phone_or_link
  if (-not $phone) { continue }
  if ($excluded.ContainsKey($phone)) { continue }
  if ($OnlyUaeMobile -and $phone -notmatch '^9715\d{8}$') { continue }

  $name = if ([string]::IsNullOrWhiteSpace($r.lead_name)) { "there" } else { $r.lead_name }
  $biz = if ([string]::IsNullOrWhiteSpace($r.business)) { "your business" } else { $r.business }
  $area = if ([string]::IsNullOrWhiteSpace($r.area)) { "Beirut" } else { $r.area }
  $pain = if ([string]::IsNullOrWhiteSpace($r.notes)) { "weak Wi-Fi or internet drops" } else { $r.notes }

  $msg = "Hi $name, ana Sam, Network Engineer b $area (14+ years). If $biz has $pain, I can do a free 15-min network check and send a clear fix plan. Better today 6 PM aw bukra 11 AM?"
  $encoded = [uri]::EscapeDataString($msg)
  $url = "https://wa.me/$phone?text=$encoded"

  Start-Process $url
  $opened++
  Start-Sleep -Milliseconds 250
}

Write-Host "Opened $opened WhatsApp tab(s)."
if ($opened -eq 0) {
  Write-Host "Tip: fill phone_or_link with valid new numbers, keep status = NEW, and check EXCLUDED_NUMBERS.txt."
}
