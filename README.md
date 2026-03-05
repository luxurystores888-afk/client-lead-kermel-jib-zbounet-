# Client Lead Workspace 🚀

Organized lead-generation workspace with ready CSV files, automation scripts, and execution docs. 📁

## Main Folder Files 📂
- `LEADS_TRACKER.csv`: active working tracker.
- `LEADS_TRACKER_1000_UAE.csv`: generated 1000 UAE leads dataset.
- `READY_TO_SEND_MESSAGES.txt`: latest generated outreach text.
- `EXCLUDED_NUMBERS.txt`: numbers to always skip.

## Scripts 🛠️
- `BUILD_1000_UAE_LEADS.ps1`: builds up to 1000 UAE leads from profile sources.
- `QUICK_PERSONALIZER.ps1`: generates personalized messages from CSV.
- `OPEN_WHATSAPP_TABS.ps1`: opens WhatsApp tabs for `NEW` leads.
- `RUN_TODAY.ps1`: quick daily launcher.

## Organized Exports ✅
Inside `organized/`:
- `LEADS_ALL_1000_SORTED.csv`: fully sorted master file.
- `LEADS_MOBILE_ONLY.csv`: mobile subset.
- `LEADS_Dubai.csv`, `LEADS_Abu_Dhabi.csv`, etc.
- `SUMMARY.txt`: lead counts by area.

## Quick Start (PowerShell) ⚡
Run from repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\BUILD_1000_UAE_LEADS.ps1 -Target 1000 -MaxProfilesToScan 8000
powershell -ExecutionPolicy Bypass -File .\QUICK_PERSONALIZER.ps1 -InputCsv .\LEADS_TRACKER.csv -OutputTxt .\READY_TO_SEND_MESSAGES.txt
powershell -ExecutionPolicy Bypass -File .\OPEN_WHATSAPP_TABS.ps1 -InputCsv .\organized\LEADS_MOBILE_ONLY.csv -MaxTabs 20 -ExcludeFile .\EXCLUDED_NUMBERS.txt -OnlyUaeMobile
```