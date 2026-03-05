$ErrorActionPreference = "Stop"

Write-Host "[1/3] Generating personalized messages..."
& ".\\QUICK_PERSONALIZER.ps1"

Write-Host "[2/3] Opening key files..."
$files = @(
  ".\\READY_TO_SEND_MESSAGES.txt",
  ".\\LEADS_TRACKER.csv",
  ".\\DAILY_EXECUTION_CHECKLIST.md"
)

foreach ($f in $files) {
  if (Test-Path $f) {
    Start-Process $f
  }
}

Write-Host "[3/3] Done. Execute outreach block now: 20 sends, 5 calls, 10 follow-ups."

