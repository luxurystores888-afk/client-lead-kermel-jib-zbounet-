param(
  [string]$InputCsv = ".\\LEADS_TRACKER.csv",
  [string]$OutputTxt = ".\\READY_TO_SEND_MESSAGES.txt"
)

if (-not (Test-Path $InputCsv)) {
  Write-Error "Input CSV not found: $InputCsv"
  exit 1
}

$rows = Import-Csv -Path $InputCsv
if (-not $rows -or $rows.Count -eq 0) {
  Write-Error "No rows found in: $InputCsv"
  exit 1
}

$lines = @()
$lines += "READY MESSAGES - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$lines += ""

foreach ($r in $rows) {
  if ($r.status -notin @("NEW", "SENT", "FOLLOWUP")) {
    continue
  }

  $name = if ([string]::IsNullOrWhiteSpace($r.lead_name)) { "there" } else { $r.lead_name }
  $biz = if ([string]::IsNullOrWhiteSpace($r.business)) { "your business" } else { $r.business }
  $area = if ([string]::IsNullOrWhiteSpace($r.area)) { "Beirut" } else { $r.area }

  $angle = "weak Wi-Fi, internet drops, or slow speed"
  if (-not [string]::IsNullOrWhiteSpace($r.notes)) {
    if ($r.notes -notmatch "YellowPages UAE profile") {
      $angle = $r.notes
    }
  }

  $isUae = $false
  if ($area -match "Dubai|Abu Dhabi|Sharjah|Ajman") {
    $isUae = $true
  }

  if ($r.status -eq "NEW") {
    if ($isUae) {
      $msg = "Hi $name, I am Sam, Network Engineer (14+ years). I help businesses in $area solve $angle remotely (no onsite needed). I can do a free 15-min remote network check and send a clear fix plan in 24h. Better today 6 PM or tomorrow 11 AM UAE time?"
    }
    else {
      $msg = "Hi $name, ana Sam, Network Engineer b $area (14+ years). If $biz has $angle, I can do a free 15-min network check and send a clear fix plan. WhatsApp/Call: +961 70 841 009. Better today 6 PM aw bukra 11 AM?"
    }
  }
  elseif ($r.status -eq "SENT") {
    if ($isUae) {
      $msg = "Hi $name, quick follow-up on the free 15-min remote network check for $biz. Usually we can improve stability remotely without onsite visits. Better today 6 PM or tomorrow 11 AM UAE time?"
    }
    else {
      $msg = "Hi $name, quick follow-up on the free 15-min network check for $biz. Usually we can improve stability in one visit. Better today 6 PM aw bukra 11 AM?"
    }
  }
  else {
    if ($isUae) {
      $msg = "Hi $name, last quick check-in. I still have one slot for a free remote network diagnosis for $biz. Confirm today 6 PM or tomorrow 11 AM UAE time?"
    }
    else {
      $msg = "Hi $name, last quick check-in. I still have one slot for a free network diagnosis for $biz. Confirm today 6 PM aw bukra 11 AM?"
    }
  }

  $lines += "Lead: $($r.lead_name) | Business: $($r.business) | Channel: $($r.channel) | Contact: $($r.phone_or_link)"
  $lines += "Message: $msg"
  $lines += ""
}

Set-Content -Path $OutputTxt -Value $lines -Encoding UTF8
Write-Host "Generated messages: $OutputTxt"
