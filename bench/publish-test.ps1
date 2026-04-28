param(
    [int]$Messages = 1,
    [int]$Rows = 1,
    [string]$Broker = "host.docker.internal",
    [int]$Port = 1883,
    [string]$Topic = "sensor",
    [string]$RuntimeFile = "..\data\nodered_runtime.json",
    [string]$MapRuntimeFile = "..\data\map_runtime.json"
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

    $msg = ($lines -join "`r`n") + "`r`n"

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

$lastEntries = $entries |
    Where-Object { $_.packet -eq "publish" } |
    Select-Object -Last $Messages

if ($lastEntries.Count -eq 0) {
    Write-Host ""
    Write-Host "No Runtime entries found."
    exit 1
}

$avgPublishPreprocessing = ($lastEntries | Measure-Object publish_preprocessing_ms -Average).Average
$avgQueueAndBatch = ($lastEntries | Measure-Object queue_and_batch_ms -Average).Average
$avgMapper = ($lastEntries | Measure-Object mapper_ms -Average).Average
$avgNodeRedTotal = ($lastEntries | Measure-Object nodered_total_ms -Average).Average
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
Write-Host ("Avg Node-RED total:                  {0:N2} ms" -f $avgNodeRedTotal)
Write-Host ("Avg batch_size:             {0:N2}" -f $avgBatchSize)
Write-Host "------------------"

$timeoutSeconds = 120
$pollIntervalSeconds = 2
$deadline = (Get-Date).AddSeconds($timeoutSeconds)

$lastMapEntries = @()
$failedPublishMapEntries = @()

do {
    Start-Sleep -Seconds $pollIntervalSeconds

    if (Test-Path $MapRuntimeFile) {
        $mapEntries = Get-Content $MapRuntimeFile |
            Where-Object { $_.Trim() -ne "" } |
            ForEach-Object { $_ | ConvertFrom-Json }

        $lastMapEntries = $mapEntries |
            Where-Object { $_.packet -eq "publish" -and $_.status -eq "ok" } |
            Select-Object -Last $Messages

        $failedPublishMapEntries = $mapEntries |
            Where-Object { $_.packet -eq "publish" -and $_.status -ne "ok" } |
            Select-Object -Last $Messages

        Write-Host "Waiting for GraphDB uploads: $($lastMapEntries.Count)/$Messages"
    }

} while (
    $lastMapEntries.Count -lt $Messages -and
    (Get-Date) -lt $deadline
)

if ($lastMapEntries.Count -lt $Messages) {
    Write-Host ""
    Write-Host "Timeout: Only $($lastMapEntries.Count)/$Messages publish map runs completed."
}

if ($lastMapEntries.Count -gt 0) {
    $avgMapping = ($lastMapEntries | Measure-Object mapping_ms -Average).Average
    $avgGraphDb = ($lastMapEntries | Measure-Object graphdb_post_ms -Average).Average
    $avgShellTotal = ($lastMapEntries | Measure-Object shell_total_ms -Average).Average

    Write-Host ""
    Write-Host "Mapping + GraphDB Results"
    Write-Host "------------------"
    Write-Host "Evaluated Map Runs:        $($lastMapEntries.Count)"
    Write-Host ("Avg mapping to TTL:        {0:N2} ms" -f $avgMapping)
    Write-Host ("Avg GraphDB POST:          {0:N2} ms" -f $avgGraphDb)
    Write-Host ("Avg shell total:           {0:N2} ms" -f $avgShellTotal)
    Write-Host "Failed Publish Map Runs:   $($failedPublishMapEntries.Count)"
    Write-Host "------------------"
    
    $combinedTotal = $avgNodeRedTotal + $avgShellTotal

    Write-Host ""
    Write-Host "End-to-End Results"
    Write-Host "------------------"
    Write-Host ("Avg Node-RED total:        {0:N2} ms" -f $avgNodeRedTotal)
    Write-Host ("Avg Mapping total:         {0:N2} ms" -f $avgShellTotal)
    Write-Host ("Avg End-to-End total:      {0:N2} ms" -f $combinedTotal)
    Write-Host "------------------"
}
else {
    Write-Host ""
    Write-Host "No successful publish map_runtime entries found."
}