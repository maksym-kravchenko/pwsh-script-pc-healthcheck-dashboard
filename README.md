# PC Gaming Health Dashboard

A lightweight, real-time system monitor for Windows — built as a single PowerShell script with a native WPF UI. No installation, no background services, no third-party apps required.

---

## Overview

PC Gaming Health Dashboard displays live CPU, RAM, GPU, disk, Wi-Fi, and system stats in a clean dashboard window. It refreshes every second and alerts you when any metric exceeds safe thresholds.

It runs entirely from one `.ps1` file using built-in Windows APIs (WMI/CIM, WPF, Performance Counters) — nothing to install for basic use.

---

## Features

- **CPU** — utilization %, temperature (requires OpenHardwareMonitor)
- **RAM** — usage %, used/total GB, memory speed
- **GPU** — utilization % for NVIDIA, AMD, and Intel GPUs; temperature for NVIDIA and OpenHardwareMonitor setups
- **Disk** — C: drive usage %, used and free space
- **Wi-Fi** — connected SSID, signal strength %, live download/upload speeds
- **System** — OS, hostname, uptime
- **Alert bar** — warns when CPU/RAM/Disk exceed 90% or GPU temperature exceeds 85 °C
- **Two themes** — Dark (GitHub-dark) and Light, toggled with one click
- **No external dependencies** for core metrics — GPU temperature is the only optional feature

---

## Quick Start

```powershell
powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
```

That's it. The window opens immediately and starts updating.

---

## For Users

### Requirements

| Requirement | Details |
|---|---|
| OS | Windows 10 or Windows 11 |
| PowerShell | 5.1 or newer (built into Windows) |
| .NET / WPF | Included with Windows — no extra install |
| GPU temperature | NVIDIA: `nvidia-smi` (included with NVIDIA drivers) |
| CPU/GPU temperature | Any GPU: [OpenHardwareMonitor](https://openhardwaremonitor.org/) running as administrator |

### Installation

1. Download or clone this repository
2. Right-click `GamingDashboard.ps1` → **Run with PowerShell**

   Or from a terminal:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\GamingDashboard.ps1"
   ```

3. The dashboard window opens. No further setup needed.

### Reading the Dashboard

The window is split into two rows of three cards:

**Top row**

| Card | What it shows |
|---|---|
| CPU | Utilization % · Temperature (OHM required) · Processor model |
| RAM | Usage % · Used / Total GB · Memory speed |
| GPU | Utilization % · Temperature · GPU model |

**Bottom row**

| Card | What it shows |
|---|---|
| DISK | C: drive usage % · Used · Free |
| WI-FI | Connected SSID · Signal % · Download/Upload speed |
| SYSTEM | Uptime · OS version · Hostname |

**Progress bars** turn yellow above 70% and red above 90%.

**Alert bar** (bottom strip) shows "All systems nominal" normally, or a warning message listing any metric over its threshold.

### Switching Themes

Click **THEME: DARK** / **THEME: LIGHT** in the top-right corner to toggle between themes.

### GPU Temperature

- **NVIDIA GPUs**: temperature appears automatically if NVIDIA drivers are installed (via `nvidia-smi`)
- **AMD / Intel GPUs**: install [OpenHardwareMonitor](https://openhardwaremonitor.org/), run it as administrator before launching the dashboard
- If neither is available, the temperature field shows `-- C`

---

## For Admins

### Execution Policy

The script must be allowed to run. The safest way without permanently changing system policy:

```powershell
powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
```

To allow it permanently for the current user only:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Running at Windows Startup

1. Press `Win + R`, type `shell:startup`, press Enter
2. Create a shortcut in that folder pointing to:
   ```
   powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\path\to\GamingDashboard.ps1"
   ```

### GPU Temperature with OpenHardwareMonitor

OpenHardwareMonitor (OHM) exposes a WMI namespace (`root/OpenHardwareMonitor`) that the dashboard reads. OHM must be running with administrator rights before the dashboard starts. The dashboard queries it every 3 seconds to keep WMI load low.

### Permissions

The script requires no elevated privileges for core metrics. The only exception is OpenHardwareMonitor itself, which must run as administrator to access hardware sensors — the dashboard just reads the WMI data OHM exposes.

### Deployment / Maintenance

- The entire application is one file — copy `GamingDashboard.ps1` to deploy
- No registry keys, no scheduled tasks, no installed files
- To update: replace the `.ps1` file

### Security Considerations

- `netsh.exe` is resolved by absolute path (`$env:SystemRoot\System32\netsh.exe`) to prevent PATH-based hijacking
- `nvidia-smi` is called by name — ensure NVIDIA driver directories are not writable by untrusted users
- No network connections are made — all data comes from local OS APIs
- No credentials, tokens, or sensitive data are read or stored

---

## For Developers

### Project Structure

```
GamingDashboard.ps1     # Entire application — UI + logic in one file
README.md
```

The script is organized into clearly marked sections:

| Section | Lines | Purpose |
|---|---|---|
| XAML | ~15–343 | WPF window definition (layout, controls, initial colors) |
| Load Window | ~345–429 | Parse XAML, bind all named controls to PowerShell variables |
| Theme Definitions | ~431–498 | Color palettes for DARK and LIGHT themes |
| Core Utilities | ~500–611 | `ConvertTo-Brush`, `Apply-Theme`, `Format-Bytes/Speed`, `Get-UsageBrush` |
| Data Collectors | ~612–779 | `Initialize-StaticInfo`, `Initialize-Network`, `Get-CpuPct`, `Get-GpuInfo`, `Get-WifiInfo` |
| Update Loop | ~781–914 | `Update-Dashboard` — called every second by a DispatcherTimer |
| Event Wiring | ~916–945 | Timer setup, window Loaded/Closing handlers, theme button click |

### Development Setup

No build step required. Edit the file in any editor and run directly:

```powershell
powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
```

PowerShell ISE or VS Code with the PowerShell extension both provide syntax highlighting and debugging.

### GPU Detection Chain

`Get-GpuInfo` tries three sources in order and returns the first one that succeeds:

1. **`nvidia-smi`** — returns utilization + temperature, NVIDIA only
2. **`Win32_PerfFormattedData_GPUPerformanceCounters_GPUEngine`** — Windows 10+ built-in counters, works for AMD / Intel / NVIDIA without extra software; returns utilization only (sums `engtype_3D` engine instances, falls back to the busiest engine if no 3D instances exist)
3. **OpenHardwareMonitor WMI** (`root/OpenHardwareMonitor`) — returns utilization + temperature, any GPU, requires OHM running as admin

The `$script:gpuEngineAvailable` flag prevents repeated failed WMI queries if the GPU counter class is missing on the system.

### Tick-Rate Throttling

`Update-Dashboard` runs every second but not every metric needs 1-second resolution:

| Cadence | Metrics |
|---|---|
| Every tick (1 s) | CPU %, RAM %, GPU %, network speeds, clock |
| Every 3rd tick (3 s) | CPU/GPU temperature, Wi-Fi SSID/signal |
| Every 5th tick (5 s) | Disk usage |
| Every 10th tick (10 s) | System uptime |

This keeps WMI load low while keeping fast-changing metrics responsive.

### Adding a Theme

Add a new entry to `$script:themes` following the existing pattern:

```powershell
"MYTHEME" = @{
    WinBg       = "#..."   # window background
    CardBg      = "#..."   # card background
    TitleBg     = "#..."   # title bar background
    AlertBg     = "#..."   # alert bar background
    PbBg        = "#..."   # progress bar track

    CpuAccent   = "#..."   # CPU card accent (border, header, value text)
    RamAccent   = "#..."
    GpuAccent   = "#..."
    DiskAccent  = "#..."
    WifiAccent  = "#..."
    SysAccent   = "#..."

    TitleText   = "#..."   # dashboard title
    ClockText   = "#..."   # clock
    TempText    = "#..."   # temperature values
    DimText     = "#..."   # secondary labels
    MidText     = "#..."   # tertiary values (total RAM, free disk, etc.)
    AlertLabel  = "#..."   # "ALERTS:" label
    AlertOk     = "#..."   # nominal state message
    AlertWarn   = "#..."   # warning state message
    NetDownText = "#..."
    NetUpText   = "#..."
    ThemeBtnBg  = "#..."
    ThemeBtnFg  = "#..."
    ThemeBtnBdr = "#..."
}
```

Then update the toggle in `$btnTheme.Add_Click` to cycle through your theme list.

### Brush Caching

`ConvertTo-Brush` caches and freezes every `SolidColorBrush` it creates (`$script:brushCache`). Frozen brushes are immutable and thread-safe; WPF skips layout invalidation when assigning them. This matters on a 1-second timer touching 30+ UI elements per tick.

### Contributing

1. Fork the repository and create a feature branch
2. Keep all logic in `GamingDashboard.ps1` — no additional files unless genuinely necessary
3. Test on both DARK and LIGHT themes
4. Run the parser check before submitting:
   ```powershell
   $e = $null; $t = $null
   [System.Management.Automation.Language.Parser]::ParseFile(
       '.\GamingDashboard.ps1', [ref]$t, [ref]$e) | Out-Null
   $e   # should be empty
   ```
5. Open a pull request with a clear description of what changed and why
