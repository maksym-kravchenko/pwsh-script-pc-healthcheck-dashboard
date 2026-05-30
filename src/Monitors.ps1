# =============================================================================
#  MONITORS
#  Hardware and network data collection. Functions mostly return plain values
#  or hashtables; the exception is Get-UsageBrush, which maps a percentage to a
#  themed brush and therefore needs Themes.ps1 loaded first.
# =============================================================================
function Format-Bytes {
    param([double]$bytes)
    if ($bytes -ge 1GB) { return "{0:F1} GB" -f ($bytes / 1GB) }
    if ($bytes -ge 1MB) { return "{0:F1} MB" -f ($bytes / 1MB) }
    return "{0:F0} KB" -f ($bytes / 1KB)
}

function Format-Speed {
    param([double]$bps)
    if ($bps -ge 1GB) { return "{0:F2} GB/s" -f ($bps / 1GB) }
    if ($bps -ge 1MB) { return "{0:F1} MB/s" -f ($bps / 1MB) }
    if ($bps -ge 1KB) { return "{0:F0} KB/s" -f ($bps / 1KB) }
    return "0 KB/s"
}

# Red past 90%, amber past 70%, otherwise the card's own accent. The shared
# thresholds win over the accent so every card warns with the same colors.
function Get-UsageBrush {
    param([int]$pct, [string]$accent)
    if ($pct -ge 90) { return ConvertTo-Brush "#ff6188" }
    if ($pct -ge 70) { return ConvertTo-Brush "#ffd866" }
    return ConvertTo-Brush $accent
}

# --- CPU ---------------------------------------------------------------------

$cpuCounter = $null
try {
    $cpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
    $null = $cpuCounter.NextValue()   # first call always returns 0; discard it
} catch {
    $cpuCounter = $null
}

function Get-CpuPct {
    if ($cpuCounter) {
        try { return [int]$cpuCounter.NextValue() } catch { }
    }
    try {
        $row = Get-CimInstance `
            -Query "SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfOS_Processor WHERE Name='_Total'" `
            -ErrorAction Stop
        if ($row) { return [int]$row.PercentProcessorTime }
    } catch { }
    return 0
}

# --- GPU ---------------------------------------------------------------------

# The GPU perf-counter WMI class isn't present on every machine. Latch this off
# after the first failed query so we stop paying for it on each tick.
$script:gpuEngineAvailable = $true

function Get-GpuInfo {
    # 1) NVIDIA via nvidia-smi
    try {
        $smi = & nvidia-smi --query-gpu=utilization.gpu,temperature.gpu `
                            --format=csv,noheader,nounits 2>$null
        if ($smi) {
            $line = ($smi | Select-Object -First 1).Trim()
            if ($line) {
                $parts = $line -split ","
                return @{ Pct = [int]$parts[0].Trim(); Temp = [int]$parts[1].Trim() }
            }
        }
    } catch { }

    # 2) Windows GPU performance counters - AMD / Intel / NVIDIA on Win10+, no extra software
    if ($script:gpuEngineAvailable) {
        try {
            $engines = Get-CimInstance `
                -ClassName Win32_PerfFormattedData_GPUPerformanceCounters_GPUEngine `
                -ErrorAction Stop
            if ($engines) {
                # Prefer summing 3D engine instances; fall back to the busiest engine overall.
                $util = ($engines | Where-Object { $_.Name -like '*engtype_3D*' } |
                         Measure-Object -Property UtilizationPercentage -Sum).Sum
                if ($null -eq $util) {
                    $util = ($engines | Measure-Object -Property UtilizationPercentage -Maximum).Maximum
                }
                if ($null -ne $util) {
                    return @{ Pct = [int][math]::Min(100, [math]::Round($util)); Temp = $null }
                }
            }
        } catch {
            $script:gpuEngineAvailable = $false   # WMI class absent - skip future queries
        }
    }

    # 3) OpenHardwareMonitor - any GPU, requires OHM running as admin
    try {
        $sensors = Get-CimInstance -Namespace "root/OpenHardwareMonitor" `
                                   -ClassName "Sensor" -ErrorAction Stop
        $load = $sensors | Where-Object { $_.SensorType -eq "Load" -and $_.Name -match "GPU" } |
                Select-Object -First 1
        $temp = $sensors | Where-Object { $_.SensorType -eq "Temperature" -and $_.Name -match "GPU" } |
                Select-Object -First 1
        if ($load) {
            return @{
                Pct = [int][math]::Round($load.Value)
                Temp = if ($temp) { [int][math]::Round($temp.Value) } else { $null }
            }
        }
    } catch { }

    return $null
}

# --- Wi-Fi -------------------------------------------------------------------

# Resolve netsh by absolute path to prevent PATH-based executable hijacking.
$script:netshExe = Join-Path $env:SystemRoot "System32\netsh.exe"
if (-not (Test-Path $script:netshExe)) { $script:netshExe = "netsh.exe" }

function Get-WifiInfo {
    $ssid = ""
    $signal = 0
    $hasWifi = $false

    try {
        # netsh returns string[] - iterate line-by-line so $Matches is populated correctly. 
        # Using -match on the whole array silently drops captures.
        $raw = & $script:netshExe wlan show interfaces 2>$null
        if ($raw) {
            $hasWifi = $true
            foreach ($line in $raw) {
                # The leading 'S' excludes BSSID lines without extra regex complexity.
                if (-not $ssid -and $line -match '^\s*SSID\s*:\s*(.+?)\s*$') {
                    $ssid = $Matches[1]
                }
                # Signal is the only field in this output that ends with N% - language-neutral.
                elseif ($signal -eq 0 -and $line -match ':\s*(\d{1,3})\s*%\s*$') {
                    $signal = [math]::Min(100, [int]$Matches[1])
                }
            }
        }
    } catch { }

    # Fallback for non-English netsh labels or when SSID line is absent.
    if (-not $ssid) {
        try {
            $profile = Get-NetConnectionProfile -ErrorAction Stop |
                       Where-Object { $_.InterfaceAlias -match 'Wi-?Fi|Wireless|WLAN' } |
                       Select-Object -First 1
            if ($profile) { $ssid = $profile.Name; $hasWifi = $true }
        } catch { }
    }

    if (-not $ssid) {
        $ssid = if ($hasWifi) { "Not connected" } else { "No WiFi adapter" }
    }

    return @{ SSID = $ssid; Signal = $signal }
}

# --- Network speeds ----------------------------------------------------------

$script:netBaseline = @{}
$script:netTime = [DateTime]::Now

function Initialize-Network {
    $adapters = Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
                Where-Object { $_.ReceivedBytes -gt 0 }
    foreach ($a in $adapters) {
        $script:netBaseline[$a.Name] = @{ Rx = $a.ReceivedBytes; Tx = $a.SentBytes }
    }
    $script:netTime = [DateTime]::Now
}

# Returns @{ Rx = bytes/sec; Tx = bytes/sec } by diffing cumulative adapter counters
# against the previous snapshot and dividing by elapsed seconds.
function Get-NetworkSpeeds {
    $now = [DateTime]::Now
    $elapsed = ($now - $script:netTime).TotalSeconds
    if ($elapsed -lt 0.1) { $elapsed = 1 }   # guard against near-zero delta on first call

    $rx = 0.0
    $tx = 0.0

    $adapters = Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
                Where-Object { $_.ReceivedBytes -gt 0 }

    foreach ($a in $adapters) {
        if ($script:netBaseline.ContainsKey($a.Name)) {
            $rx += [math]::Max(0, ($a.ReceivedBytes - $script:netBaseline[$a.Name].Rx) / $elapsed)
            $tx += [math]::Max(0, ($a.SentBytes     - $script:netBaseline[$a.Name].Tx) / $elapsed)
        }
        $script:netBaseline[$a.Name] = @{ Rx = $a.ReceivedBytes; Tx = $a.SentBytes }
    }
    $script:netTime = $now

    return @{ Rx = $rx; Tx = $tx }
}
