# Watch Session Event Simulator

[![tests](https://github.com/atonyhonesto/watch-session-event-simulator/actions/workflows/tests.yml/badge.svg)](https://github.com/atonyhonesto/watch-session-event-simulator/actions/workflows/tests.yml) ![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)

A PowerShell script that plays a **two-minute wrestling match** as 11 player events and posts them to either build of the watch-session tracker, taking one session through every state.

Companion code for my LinkedIn article **[Three Stakeholders, One Proof of Concept: Building a Real-Time Watch Session Tracker](https://www.linkedin.com/pulse/three-stakeholders-one-proof-concept-tony-honesto-rvkqc/)**. The article covers the design trade-offs: a 45-second activity window against a 10–15 second target, event-ID deduplication, two clocks, and why it was built twice.

| Repo | What it is |
|---|---|
| [Lightweight build](https://github.com/atonyhonesto/watch-session-tracker-lightweight) | Node `http`, no runtime dependencies |
| [Common-libraries build](https://github.com/atonyhonesto/watch-session-tracker-express-zod) | Express, Zod, Supertest |
| **[Event simulator](https://github.com/atonyhonesto/watch-session-event-simulator)** ← you are here | PowerShell, a simulated two-minute wrestling match |

---

Small VS Code-friendly PowerShell app that simulates a **2-minute wrestling match** and posts sample watch-session events to a running app at:

`http://localhost:3000/events`

It uses the sample event shape from the requirement notes, including:
- `sessionId`
- `userId`
- `eventType`
- `eventId`
- `eventTimestamp`
- `receivedAt`
- `payload.eventId`
- `payload.position`
- `payload.quality`

## Event flow in this sample

The script sends this sequence for a 120-second match:
1. `start`
2. `heartbeat` at 30 seconds
3. `quality_change` at 45 seconds
4. `heartbeat` at 60 seconds
5. `buffer_start` at 70 seconds
6. `buffer_end` at 73 seconds
7. `heartbeat` at 90 seconds
8. `pause` at 100 seconds
9. `resume` at 108 seconds
10. `seek` at 115 seconds
11. `end` at 120 seconds

## Files

- `send-wrestling-events.ps1` - main script
- `README.md` - usage notes

## How to run

Open the folder in VS Code, then open a PowerShell terminal.

### Dry run

```powershell
.\send-wrestling-events.ps1 -DryRun
```

### Send to local app

```powershell
.\send-wrestling-events.ps1
```

### Explicit URI

```powershell
.\send-wrestling-events.ps1 -Uri "http://localhost:3000/events"
```

### Slow down or speed up the simulation

Default is `60`, which means the 2-minute match finishes in about 2 real seconds.

```powershell
.\send-wrestling-events.ps1 -SpeedMultiplier 10
```

That would make the simulation take about 12 real seconds.

## Notes

- The script generates a new GUID for each outgoing `eventId`.
- `eventTimestamp` is based on the simulated match timeline.
- `receivedAt` is the actual send time in UTC.
- The payload stays aligned to the event examples in the requirement notes.
