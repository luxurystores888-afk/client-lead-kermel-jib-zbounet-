# New Leads Only - Fast Mode

## Goal
Send only to new people (not your old contacts/chats).

## 1) Add old contacts to block list
Open `sales/EXCLUDED_NUMBERS.txt` and paste all old numbers (one per line).

## 2) Collect fresh leads from Maps
Use `sales/LEAD_SOURCES_BEIRUT.md`, collect businesses, and add them to:
- `sales/LEADS_TRACKER.csv`

Required columns:
- `business`
- `area`
- `phone_or_link`
- `status=NEW`

## 3) Open only new WhatsApp chats
Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\sales\OPEN_WHATSAPP_TABS.ps1 -MaxTabs 8 -ExcludeFile .\sales\EXCLUDED_NUMBERS.txt
```

## 4) After sending
Change sent rows in CSV from `NEW` to `SENT`.

## Quick rule
If a number is old, put it in `EXCLUDED_NUMBERS.txt` and it will never open again.
