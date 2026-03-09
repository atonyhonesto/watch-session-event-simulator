param(
    [string]$Uri = "http://localhost:3000/events",
    [string]$SessionId = "session-wrestling-001",
    [string]$UserId = "user-demo-001",
    [string]$EventStreamId = "event-2026-wrestling-finals",
    [int]$SpeedMultiplier = 60,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ($SpeedMultiplier -lt 1) {
    throw "SpeedMultiplier must be 1 or greater."
}

$matchStart = (Get-Date).ToUniversalTime()

$timeline = @(
    @{ offset = 0;   type = "start";          payload = @{ eventId = $EventStreamId; position = 0.0;   quality = "720p"  } },
    @{ offset = 30;  type = "heartbeat";      payload = @{ eventId = $EventStreamId; position = 30.0;  quality = "720p"  } },
    @{ offset = 45;  type = "quality_change"; payload = @{ eventId = $EventStreamId; position = 45.0;  quality = "1080p" } },
    @{ offset = 60;  type = "heartbeat";      payload = @{ eventId = $EventStreamId; position = 60.0;  quality = "1080p" } },
    @{ offset = 70;  type = "buffer_start";   payload = @{ eventId = $EventStreamId; position = 70.0;  quality = "1080p" } },
    @{ offset = 73;  type = "buffer_end";     payload = @{ eventId = $EventStreamId; position = 73.0;  quality = "1080p" } },
    @{ offset = 90;  type = "heartbeat";      payload = @{ eventId = $EventStreamId; position = 90.0;  quality = "1080p" } },
    @{ offset = 100; type = "pause";          payload = @{ eventId = $EventStreamId; position = 100.0; quality = "1080p" } },
    @{ offset = 108; type = "resume";         payload = @{ eventId = $EventStreamId; position = 100.0; quality = "1080p" } },
    @{ offset = 115; type = "seek";           payload = @{ eventId = $EventStreamId; position = 112.0; quality = "1080p"; fromPosition = 107.0; toPosition = 112.0 } },
    @{ offset = 120; type = "end";            payload = @{ eventId = $EventStreamId; position = 120.0; quality = "1080p" } }
)

Write-Host "Starting simulated wrestling match event stream..." -ForegroundColor Cyan
Write-Host "Target URI: $Uri"
Write-Host "SessionId : $SessionId"
Write-Host "UserId    : $UserId"
Write-Host "EventId   : $EventStreamId"
Write-Host "Duration  : 120 seconds simulated"
Write-Host "Speed     : 1 real second = $SpeedMultiplier simulated seconds"
Write-Host "DryRun    : $DryRun"
Write-Host ""

$previousOffset = 0

foreach ($item in $timeline) {
    $currentOffset = [int]$item.offset
    $gap = $currentOffset - $previousOffset

    if ($gap -gt 0) {
        $sleepSeconds = [math]::Max([math]::Round($gap / $SpeedMultiplier, 2), 0)
        if ($sleepSeconds -gt 0) {
            Start-Sleep -Seconds $sleepSeconds
        }
    }

    $eventTimestamp = $matchStart.AddSeconds($currentOffset)
    $receivedAt = (Get-Date).ToUniversalTime()
    $eventId = [guid]::NewGuid().ToString()

    $body = [ordered]@{
        sessionId = $SessionId
        userId = $UserId
        eventType = $item.type
        eventId = $eventId
        eventTimestamp = $eventTimestamp.ToString("o")
        receivedAt = $receivedAt.ToString("o")
        payload = $item.payload
    }

    $jsonBody = $body | ConvertTo-Json -Depth 6

    Write-Host "[$($item.type)] sending @ simulated second $currentOffset" -ForegroundColor Yellow
    Write-Host $jsonBody

    if (-not $DryRun) {
        try {
            $response = Invoke-RestMethod -Uri $Uri -Method Post -ContentType "application/json" -Body $jsonBody
            if ($null -ne $response) {
                Write-Host "Response: $($response | ConvertTo-Json -Depth 6 -Compress)" -ForegroundColor Green
            }
            else {
                Write-Host "Response: <empty body>" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "Request failed for event type '$($item.type)': $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
    }
    else {
        Write-Host "Dry run only. Request not sent." -ForegroundColor DarkGray
    }

    Write-Host ""
    $previousOffset = $currentOffset
}

Write-Host "Completed simulated 2-minute wrestling match event stream." -ForegroundColor Cyan
