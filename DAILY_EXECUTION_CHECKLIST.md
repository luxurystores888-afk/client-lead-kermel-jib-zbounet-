# Daily Execution Checklist (Until First Client)

## Start Of Day (5 min)
- Run:
	- `powershell -ExecutionPolicy Bypass -File .\sales\RUN_TODAY.ps1`
- Confirm files opened:
	- `sales/READY_TO_SEND_MESSAGES.txt`
	- `sales/LEADS_TRACKER.csv`

## Block A (45 min)
- Add 20 real leads (name + contact) in `LEADS_TRACKER.csv`.
- Run:
	- `powershell -ExecutionPolicy Bypass -File .\sales\QUICK_PERSONALIZER.ps1`
- Send first 20 messages from `READY_TO_SEND_MESSAGES.txt`.
- Update each row status to `SENT`.

## Block B (45 min)
- Call 5 leads with clear pain points.
- Send 10 follow-ups to no-replies.
- Update tracker statuses:
	- `REPLIED`, `CALL_SCHEDULED`, `NO_REPLY`, `BOOKED`.

## Block C (45 min)
- Send final 10 messages for the day.
- Push warm leads to one of two slots only:
	- "today 6 PM" or "tomorrow 11 AM".
- Confirm next-day visit slots.

## KPI Targets
- 40 outreaches/day
- 10 calls/day
- 2 qualified conversations/day
- 1 paid job in <= 48 hours

## Minimum Close Rule
If lead says "maybe later", reply:
- "I can do quick check today 6 PM or tomorrow 11 AM. Which one suits you?"
