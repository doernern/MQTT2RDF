param(
    [int]$Messages = 1,
    [int]$Rows = 1,
    [string]$Broker = "host.docker.internal",
    [int]$Port = 1883,
    [string]$Topic = "sensor",
    [string]$RuntimeFile = "..\data\runtime.json"
)

$header = "RFID;JobStart;JobEnd;GripPoint_X;GripPoint_Y;GripPoint_Z;Sensor;Actuator"

for ($m = 1; $m -le $Messages; $m++) {

    $lines = @()
    $lines += $header

    for ($r = 1; $r -le $Rows; $r++) {
        $id = "{0:D6}" -f (($m - 1) * $Rows + $r)

        $start = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        Start-Sleep -Milliseconds 5
        $end = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

        $x = [math]::Round(150 + (Get-Random -Minimum 0 -Maximum 500) / 100, 2)
        $y = [math]::Round(85 + (Get-Random -Minimum 0 -Maximum 500) / 100, 2)
        $z = [math]::Round(30 + (Get-Random -Minimum 0 -Maximum 500) / 100, 2)

        $lines += "RFID_$id;$start;$end;$x;$y;$z;Sensor_37b;Actuator_20a"
    }

    $msg = $lines -join "`n"

    docker run --rm eclipse-mosquitto mosquitto_pub `
        -h $Broker `
        -p $Port `
        -t $Topic `
        -m "$msg"

    Write-Host "Send: $m/$Messages Messag(es) with $Rows Rows"
}

Start-Sleep -Milliseconds 500

if (-not (Test-Path $RuntimeFile)) {
    Write-Host ""
    Write-Host "No Runtime file found: $RuntimeFile"
    exit 1
}

$entries = Get-Content $RuntimeFile |
    Where-Object { $_.Trim() -ne "" } |
    ForEach-Object { $_ | ConvertFrom-Json }

$lastEntries = $entries | Select-Object -Last $Messages

if ($lastEntries.Count -eq 0) {
    Write-Host ""
    Write-Host "No Runtime entries found."
    exit 1
}

$avgPublishPreprocessing = ($lastEntries | Measure-Object publish_preprocessing_ms -Average).Average
$avgQueueAndBatch = ($lastEntries | Measure-Object queue_and_batch_ms -Average).Average
$avgMapper = ($lastEntries | Measure-Object mapper_ms -Average).Average
$avgTotal = ($lastEntries | Measure-Object total_ms -Average).Average
$avgBatchSize = ($lastEntries | Measure-Object batch_size -Average).Average

Write-Host "------------------"
Write-Host "Benchmark Results for Publish Messages"
Write-Host "------------------"
Write-Host "Messages:                  $Messages"
Write-Host "Rows per Message:           $Rows"
Write-Host ""
Write-Host "Evaluated Packages:         $($lastEntries.Count)"
Write-Host ""
Write-Host ("Avg publish_preprocessing:  {0:N2} ms" -f $avgPublishPreprocessing)
Write-Host ("Avg queue_and_batch:        {0:N2} ms" -f $avgQueueAndBatch)
Write-Host ("Avg mapper:                 {0:N2} ms" -f $avgMapper)
Write-Host ("Avg total:                  {0:N2} ms" -f $avgTotal)
Write-Host ("Avg batch_size:             {0:N2}" -f $avgBatchSize)
Write-Host "------------------"