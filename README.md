# PC Gaming Health Dashboard

A lightweight, real-time system monitor for Windows - built as a single PowerShell script with a native WPF UI. No installation, no background services, no third-party apps required.

---

## Overview

PC Gaming Health Dashboard displays live CPU, RAM, GPU, disk, Wi-Fi, and system stats in a clean dashboard window. It refreshes every second and alerts you when any metric exceeds safe thresholds.

It runs entirely from one `.ps1` file using built-in Windows APIs (WMI/CIM, WPF, Performance Counters) - nothing to install for basic use.

---

## Features

- **CPU** - utilization %, temperature (requires OpenHardwareMonitor)
- **RAM** - usage %, used/total GB, memory speed
- **GPU** - utilization % for NVIDIA, AMD, and Intel GPUs; temperature for NVIDIA and OpenHardwareMonitor setups
- **Disk** - C: drive usage %, used and free space
- **Wi-Fi** - connected SSID, signal strength %, live download/upload speeds
- **System** - OS, hostname, uptime
- **Alert bar** - warns when CPU/RAM/Disk exceed 90% or GPU temperature exceeds 85 °C
- **Two themes** - Dark (GitHub-dark) and Light, toggled with one click
- **No external dependencies** for core metrics - GPU temperature is the only optional feature

---

## Quick Start

```powershell
powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
```

That's it. The window opens immediately and starts updating.

---

## For Users

### Requirements

- Windows 10 or 11 with PowerShell 5.1+ (both built in - nothing extra to install)
- Optional, for temperatures only: NVIDIA drivers (`nvidia-smi`) or [OpenHardwareMonitor](https://openhardwaremonitor.org/) run as administrator

### Run it

Right-click `GamingDashboard.ps1` → **Run with PowerShell**, or from a terminal:

```powershell
powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
```

The window opens and updates every second. No further setup needed.

### Good to know

- Progress bars turn **yellow above 70%** and **red above 90%**.
- The alert bar reads "All systems nominal" normally, or lists any metric over its threshold.
- Click **THEME** in the top-right to switch between Dark and Light.
- GPU temperature needs NVIDIA drivers or OpenHardwareMonitor; without them the field shows `-- C`.

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

### Permissions

The script requires no elevated privileges for core metrics. The only exception is OpenHardwareMonitor itself, which must run as administrator to access hardware sensors - the dashboard just reads the WMI data OHM exposes.

### Security Considerations

- `netsh.exe` is resolved by absolute path (`$env:SystemRoot\System32\netsh.exe`) to prevent PATH-based hijacking
- `nvidia-smi` is called by name - ensure NVIDIA driver directories are not writable by untrusted users
- No network connections are made - all data comes from local OS APIs
- No credentials, tokens, or sensitive data are read or stored

---

## For Developers

### Project Structure

```
GamingDashboard.ps1    # Entry point - loads WPF assemblies, dot-sources the modules in order
pap.svg                # Program flow chart (PAP) of the update loop and data sources
README.md
src/
├── MainWindow.xaml    # WPF layout (pure XAML)
├── Themes.ps1         # Color palettes, brush cache, Apply-Theme
├── Monitors.ps1       # Hardware / network data collection (no UI dependencies)
└── Dashboard.ps1      # Window load, control binding, 1-second update loop, events
```

The entry point dot-sources the modules in dependency order: `Themes.ps1` → `Monitors.ps1` → `Dashboard.ps1`. `Monitors.ps1` depends on `Themes.ps1` (`Get-UsageBrush` uses `ConvertTo-Brush`), and `Dashboard.ps1` wires the loaded UI to both.

### Program Flow

See [`pap.svg`](pap.svg) for a full flow chart of startup, the 1-second update loop, and where each metric comes from.

### Development Setup

No build step required. Edit any file and run directly:

```powershell
powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
```

VS Code with the PowerShell extension (or PowerShell ISE) gives syntax highlighting and debugging.

### Tick-Rate Throttling

`Update-Dashboard` runs every second, but not every metric needs 1-second resolution:

| Cadence | Metrics |
|---|---|
| Every tick (1 s) | CPU %, RAM %, GPU %, network speeds, clock |
| Every 3rd tick (3 s) | CPU/GPU temperature, Wi-Fi SSID/signal |
| Every 5th tick (5 s) | Disk usage |
| Every 10th tick (10 s) | System uptime |

This keeps WMI load low while keeping fast-changing metrics responsive.

### Adding a Theme

Add a new entry to `$script:themes` in `src/Themes.ps1`, following the existing `DARK`/`LIGHT` blocks (every color key must be present). Then extend the toggle in `$btnTheme.Add_Click` in `src/Dashboard.ps1` to cycle through your theme list.

### Brush Caching

`ConvertTo-Brush` (in `src/Themes.ps1`) caches and freezes every `SolidColorBrush` it creates. Frozen brushes are immutable and thread-safe, and WPF skips change tracking when assigning them - which matters on a 1-second timer touching 30+ UI elements per tick.

### Contributing

1. Fork the repository and create a feature branch
2. Test on both DARK and LIGHT themes
3. Run the parser check on all `.ps1` files before submitting:
   ```powershell
   Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
       $e = $null; $t = $null
       [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$t, [ref]$e) | Out-Null
       if ($e) { "$($_.Name): $($e.Message)" } else { "$($_.Name): OK" }
   }
   ```
4. Open a pull request with a clear description of what changed and why
