# =============================================================================
#  DASHBOARD
#  Window loading, control binding, update loop, and event wiring.
#  Depends on: Themes.ps1, Monitors.ps1 (must be dot-sourced first).
# =============================================================================

# --- Load window -------------------------------------------------------------

$xamlPath = Join-Path $PSScriptRoot "MainWindow.xaml"
$window   = [Windows.Markup.XamlReader]::Load(
                [System.Xml.XmlReader]::Create($xamlPath))

function Find { param($name) $window.FindName($name) }

# --- Control references ------------------------------------------------------

$rootGrid    = Find "rootGrid"
$gridTitle   = Find "gridTitle"
$gridAlert   = Find "gridAlert"
$txtTitle    = Find "txtTitle"
$txtClock    = Find "txtClock"
$btnTheme    = Find "btnTheme"

$borderCpu   = Find "borderCpu"
$borderRam   = Find "borderRam"
$borderGpu   = Find "borderGpu"
$borderDisk  = Find "borderDisk"
$borderWifi  = Find "borderWifi"
$borderSys   = Find "borderSys"

$hdrCpu      = Find "hdrCpu"
$hdrRam      = Find "hdrRam"
$hdrGpu      = Find "hdrGpu"
$hdrDisk     = Find "hdrDisk"
$hdrWifi     = Find "hdrWifi"
$hdrSys      = Find "hdrSys"

$txtCpuPct   = Find "txtCpuPct"
$txtCpuTemp  = Find "txtCpuTemp"
$txtCpuName  = Find "txtCpuName"
$pbCpu       = Find "pbCpu"

$txtRamPct   = Find "txtRamPct"
$txtRamUsed  = Find "txtRamUsed"
$txtRamTotal = Find "txtRamTotal"
$txtRamSpeed = Find "txtRamSpeed"
$pbRam       = Find "pbRam"

$txtGpuPct   = Find "txtGpuPct"
$txtGpuTemp  = Find "txtGpuTemp"
$txtGpuName  = Find "txtGpuName"
$pbGpu       = Find "pbGpu"

$txtDiskPct  = Find "txtDiskPct"
$txtDiskUsed = Find "txtDiskUsed"
$txtDiskFree = Find "txtDiskFree"
$pbDisk      = Find "pbDisk"

$txtSsid     = Find "txtSsid"
$txtSignalPct= Find "txtSignalPct"
$pbSignal    = Find "pbSignal"
$txtNetDown  = Find "txtNetDown"
$txtNetUp    = Find "txtNetUp"

$txtUptime   = Find "txtUptime"
$txtOS       = Find "txtOS"
$txtHost     = Find "txtHost"
$txtFPS      = Find "txtFPS"
$txtStatus   = Find "txtStatus"

$lblAlerts     = Find "lblAlerts"
$txtAlerts     = Find "txtAlerts"
$txtLastUpdate = Find "txtLastUpdate"

# All secondary-text elements repainted in bulk by Apply-Theme with the DimText color.
$dimLabels = @(
    (Find "lblCpuTemp"), (Find "lblGpuTemp"),
    (Find "lblRamSlash"), (Find "lblSsid"), (Find "lblSignal"),
    (Find "lblDown"), (Find "lblUp"),
    (Find "lblUptime"), (Find "lblOS"), (Find "lblHost"),
    (Find "lblFPS"), (Find "lblStatus"),
    (Find "lblDiskUsed"), (Find "lblDiskFree"),
    (Find "txtRamTotal"), (Find "txtDiskFree"), (Find "txtCpuName"),
    (Find "txtGpuName"), (Find "txtRamSpeed"), (Find "txtLastUpdate")
)

# Seed the network baseline before the first tick so the first rate display is accurate.
Initialize-Network

# --- Initialization ----------------------------------------------------------

function Initialize-StaticInfo {
    try {
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        if ($cpu -and $cpu.Name) { $txtCpuName.Text = $cpu.Name -replace "\s{2,}", " " }
    } catch { $txtCpuName.Text = "Unknown CPU" }

    try {
        $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop | Select-Object -First 1
        if ($ram -and $ram.Speed) { $txtRamSpeed.Text = "$($ram.Speed) MHz" }
    } catch { }

    try {
        # Prefer a real adapter over Microsoft Basic Display / Remote Desktop virtual adapters.
        $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop
        $gpu  = $gpus | Where-Object { $_.Name -notmatch 'Basic Display|Remote Display' } |
                Select-Object -First 1
        if (-not $gpu) { $gpu = $gpus | Select-Object -First 1 }
        if ($gpu) { $txtGpuName.Text = $gpu.Name }
    } catch { $txtGpuName.Text = "Unknown GPU" }

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $txtOS.Text = $os.Caption -replace "Microsoft Windows ", "Win "
    } catch { $txtOS.Text = "Windows" }

    $txtHost.Text = $env:COMPUTERNAME
}

# --- Update loop -------------------------------------------------------------

$script:tick = 0

function Update-Dashboard {
  try {
    $script:tick++
    $t      = $script:themes[$script:currentTheme]
    $alerts = @()

    $txtClock.Text = Get-Date -Format "HH:mm:ss"

    # CPU
    $cpuPct = Get-CpuPct
    $txtCpuPct.Text       = "$cpuPct%"
    $pbCpu.Value          = $cpuPct
    $pbCpu.Foreground     = Get-UsageBrush $cpuPct $t.CpuAccent
    $txtCpuPct.Foreground = $pbCpu.Foreground
    if ($cpuPct -ge 90) { $alerts += "CPU $cpuPct%" }

    # CPU temp - polled every 3 s; WMI round-trips are expensive and temp changes slowly.
    if ($script:tick % 3 -eq 0) {
        try {
            $sensor = Get-CimInstance -Namespace "root/OpenHardwareMonitor" `
                          -ClassName "Sensor" -ErrorAction Stop |
                      Where-Object { $_.SensorType -eq "Temperature" -and $_.Name -match "CPU" } |
                      Select-Object -First 1
            $txtCpuTemp.Text = if ($sensor) { "$([math]::Round($sensor.Value)) C" } else { "OHM needed" }
        } catch { $txtCpuTemp.Text = "OHM needed" }
    }

    # RAM
    $osNow    = Get-CimInstance Win32_OperatingSystem
    $ramTotal = $osNow.TotalVisibleMemorySize * 1KB
    $ramFree  = $osNow.FreePhysicalMemory * 1KB
    $ramUsed  = $ramTotal - $ramFree
    $ramPct   = [math]::Round(($ramUsed / $ramTotal) * 100)

    $txtRamPct.Text       = "$ramPct%"
    $txtRamUsed.Text      = Format-Bytes $ramUsed
    $txtRamTotal.Text     = Format-Bytes $ramTotal
    $pbRam.Value          = $ramPct
    $pbRam.Foreground     = Get-UsageBrush $ramPct $t.RamAccent
    $txtRamPct.Foreground = $pbRam.Foreground
    if ($ramPct -ge 90) { $alerts += "RAM $ramPct%" }

    # GPU
    $gpu = Get-GpuInfo
    if ($gpu) {
        $txtGpuPct.Text       = "$($gpu.Pct)%"
        $pbGpu.Value          = $gpu.Pct
        $pbGpu.Foreground     = Get-UsageBrush $gpu.Pct $t.GpuAccent
        $txtGpuPct.Foreground = $pbGpu.Foreground
        if ($null -ne $gpu.Temp) {
            $txtGpuTemp.Text = "$($gpu.Temp) C"
            if ($gpu.Temp -ge 85) { $alerts += "GPU TEMP $($gpu.Temp)C" }
        } else {
            $txtGpuTemp.Text = "-- C"
        }
        if ($gpu.Pct -ge 95) { $alerts += "GPU $($gpu.Pct)%" }
    } else {
        $txtGpuPct.Text       = "N/A"
        $txtGpuPct.Foreground = ConvertTo-Brush $t.GpuAccent
        $pbGpu.Value          = 0
        $txtGpuTemp.Text      = "-- C"
    }

    # Disk - polled every 5 s; disk usage doesn't change fast enough to justify every second.
    if ($script:tick % 5 -eq 0 -or $script:tick -eq 1) {
        try {
            $drive  = Get-PSDrive C -ErrorAction Stop
            $dUsed  = [double]$drive.Used
            $dFree  = [double]$drive.Free
            $dTotal = $dUsed + $dFree
            if ($dTotal -gt 0) {
                $dPct = [math]::Round(($dUsed / $dTotal) * 100)
                $txtDiskPct.Text       = "$dPct%"
                $txtDiskUsed.Text      = Format-Bytes $dUsed
                $txtDiskFree.Text      = Format-Bytes $dFree
                $pbDisk.Value          = $dPct
                $pbDisk.Foreground     = Get-UsageBrush $dPct $t.DiskAccent
                $txtDiskPct.Foreground = $pbDisk.Foreground
                if ($dPct -ge 90) { $alerts += "DISK $dPct%" }
            }
        } catch { $txtDiskPct.Text = "N/A" }
    }

    # Network speeds (every tick - users expect real-time throughput)
    $net = Get-NetworkSpeeds
    $txtNetDown.Text = Format-Speed $net.Rx
    $txtNetUp.Text   = Format-Speed $net.Tx

    # Wi-Fi SSID / signal - polled every 3 s; netsh is slow (~200 ms per call).
    if ($script:tick % 3 -eq 0 -or $script:tick -eq 1) {
        $wifi = Get-WifiInfo
        $txtSsid.Text      = $wifi.SSID
        $txtSignalPct.Text = "$($wifi.Signal) %"
        $pbSignal.Value    = $wifi.Signal
    }

    # System uptime - polled every 10 s; it changes by exactly 1 second per second.
    if ($script:tick % 10 -eq 0 -or $script:tick -eq 1) {
        $boot   = $osNow.LastBootUpTime
        $uptime = [DateTime]::Now - $boot
        $txtUptime.Text = "{0}d {1:D2}h {2:D2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    }

    # Alerts
    if ($alerts.Count -eq 0) {
        $txtAlerts.Text       = "All systems nominal"
        $txtAlerts.Foreground = ConvertTo-Brush $t.AlertOk
    } else {
        $txtAlerts.Text       = "WARNING: " + ($alerts -join "  |  ")
        $txtAlerts.Foreground = ConvertTo-Brush $t.AlertWarn
    }

    $txtLastUpdate.Text = "Updated: " + (Get-Date -Format "HH:mm:ss.f")

  } catch {
    # Keep the timer alive even if a single tick throws.
    $txtAlerts.Text       = "WARNING: tick error - $($_.Exception.Message)"
    $txtAlerts.Foreground = ConvertTo-Brush $script:themes[$script:currentTheme].AlertWarn
  }
}

# --- Timer -------------------------------------------------------------------

$timer          = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$timer.Add_Tick({ Update-Dashboard })

# --- Window events -----------------------------------------------------------

$window.Add_Loaded({
    Apply-Theme $script:currentTheme
    Initialize-StaticInfo
    Update-Dashboard
    $timer.Start()
})

$window.Add_Closing({
    $timer.Stop()
    if ($cpuCounter) { try { $cpuCounter.Dispose() } catch { } }
})

$btnTheme.Add_Click({
    $script:currentTheme = if ($script:currentTheme -eq "DARK") { "LIGHT" } else { "DARK" }
    Apply-Theme $script:currentTheme
})

# ShowDialog blocks until the window is closed; $null suppresses the DialogResult output.
$null = $window.ShowDialog()
