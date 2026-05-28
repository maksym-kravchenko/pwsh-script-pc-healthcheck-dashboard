# =============================================================================
#  THEMES
#  To bound new 7 custom Theme go in Dashboard.ps1.
# =============================================================================

$script:currentTheme = "DARK"
$script:brushCache   = @{}

$script:themes = @{

    "DARK" = @{
        WinBg       = "#0d1117"
        CardBg      = "#161b22"
        TitleBg     = "#0d1117"
        AlertBg     = "#161b22"
        PbBg        = "#21262d"

        CpuAccent   = "#7ee787"
        RamAccent   = "#79c0ff"
        GpuAccent   = "#ff7b72"
        DiskAccent  = "#d2a8ff"
        WifiAccent  = "#f0b03c"
        SysAccent   = "#ffa657"

        TitleText   = "#58a6ff"
        ClockText   = "#8b949e"
        TempText    = "#f0b03c"
        DimText     = "#6e7681"
        MidText     = "#484f58"
        AlertLabel  = "#f0b03c"
        AlertOk     = "#7ee787"
        AlertWarn   = "#ff7b72"
        NetDownText = "#7ee787"
        NetUpText   = "#f0b03c"
        ThemeBtnBg  = "#21262d"
        ThemeBtnFg  = "#f0b03c"
        ThemeBtnBdr = "#30363d"
    }

    "LIGHT" = @{
        WinBg       = "#f6f8fa"
        CardBg      = "#ffffff"
        TitleBg     = "#f6f8fa"
        AlertBg     = "#ffffff"
        PbBg        = "#eaeef2"

        CpuAccent   = "#1a7f37"
        RamAccent   = "#0969da"
        GpuAccent   = "#cf222e"
        DiskAccent  = "#8250df"
        WifiAccent  = "#9a6700"
        SysAccent   = "#bc4c00"

        TitleText   = "#0969da"
        ClockText   = "#57606a"
        TempText    = "#9a6700"
        DimText     = "#57606a"
        MidText     = "#8c959f"
        AlertLabel  = "#9a6700"
        AlertOk     = "#1a7f37"
        AlertWarn   = "#cf222e"
        NetDownText = "#1a7f37"
        NetUpText   = "#9a6700"
        ThemeBtnBg  = "#ffffff"
        ThemeBtnFg  = "#0969da"
        ThemeBtnBdr = "#d0d7de"
    }
}

function ConvertTo-Brush {
    param([string]$hex)
    if ([string]::IsNullOrEmpty($hex)) { return $null }
    if ($script:brushCache.ContainsKey($hex)) { return $script:brushCache[$hex] }
    $h = $hex.TrimStart("#")
    $r = [Convert]::ToByte($h.Substring(0,2), 16)
    $g = [Convert]::ToByte($h.Substring(2,2), 16)
    $b = [Convert]::ToByte($h.Substring(4,2), 16)
    $brush = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.Color]::FromRgb($r, $g, $b))
    # IMPORTANT: Freeze makes the brush immutable: WPF skips layout invalidation on every
    # assignment, and the object is safe to share across the UI thread.
    $brush.Freeze()
    $script:brushCache[$hex] = $brush
    return $brush
}

function Apply-Theme {
    param([string]$name)
    $t = $script:themes[$name]

    $window.Background     = ConvertTo-Brush $t.WinBg
    $rootGrid.Background   = ConvertTo-Brush $t.WinBg
    $gridTitle.Background  = ConvertTo-Brush $t.TitleBg
    $gridAlert.Background  = ConvertTo-Brush $t.AlertBg

    foreach ($border in @($borderCpu, $borderRam, $borderGpu, $borderDisk, $borderWifi, $borderSys)) {
        $border.Background = ConvertTo-Brush $t.CardBg
    }

    $borderCpu.BorderBrush   = ConvertTo-Brush $t.CpuAccent
    $borderRam.BorderBrush   = ConvertTo-Brush $t.RamAccent
    $borderGpu.BorderBrush   = ConvertTo-Brush $t.GpuAccent
    $borderDisk.BorderBrush  = ConvertTo-Brush $t.DiskAccent
    $borderWifi.BorderBrush  = ConvertTo-Brush $t.WifiAccent
    $borderSys.BorderBrush   = ConvertTo-Brush $t.SysAccent

    $hdrCpu.Foreground       = ConvertTo-Brush $t.CpuAccent
    $hdrRam.Foreground       = ConvertTo-Brush $t.RamAccent
    $hdrGpu.Foreground       = ConvertTo-Brush $t.GpuAccent
    $hdrDisk.Foreground      = ConvertTo-Brush $t.DiskAccent
    $hdrWifi.Foreground      = ConvertTo-Brush $t.WifiAccent
    $hdrSys.Foreground       = ConvertTo-Brush $t.SysAccent

    $txtCpuPct.Foreground    = ConvertTo-Brush $t.CpuAccent
    $txtRamPct.Foreground    = ConvertTo-Brush $t.RamAccent
    $txtGpuPct.Foreground    = ConvertTo-Brush $t.GpuAccent
    $txtDiskPct.Foreground   = ConvertTo-Brush $t.DiskAccent
    $txtSsid.Foreground      = ConvertTo-Brush $t.WifiAccent
    $txtSignalPct.Foreground = ConvertTo-Brush $t.WifiAccent
    $txtRamUsed.Foreground   = ConvertTo-Brush $t.RamAccent
    $txtDiskUsed.Foreground  = ConvertTo-Brush $t.DiskAccent
    $txtUptime.Foreground    = ConvertTo-Brush $t.SysAccent
    $txtOS.Foreground        = ConvertTo-Brush $t.SysAccent
    $txtHost.Foreground      = ConvertTo-Brush $t.SysAccent

    $pbCpu.Foreground        = ConvertTo-Brush $t.CpuAccent
    $pbRam.Foreground        = ConvertTo-Brush $t.RamAccent
    $pbGpu.Foreground        = ConvertTo-Brush $t.GpuAccent
    $pbDisk.Foreground       = ConvertTo-Brush $t.DiskAccent
    $pbSignal.Foreground     = ConvertTo-Brush $t.WifiAccent

    foreach ($pb in @($pbCpu, $pbRam, $pbGpu, $pbDisk, $pbSignal)) {
        $pb.Background = ConvertTo-Brush $t.PbBg
    }

    $txtCpuTemp.Foreground   = ConvertTo-Brush $t.TempText
    $txtGpuTemp.Foreground   = ConvertTo-Brush $t.TempText
    $txtNetDown.Foreground   = ConvertTo-Brush $t.NetDownText
    $txtNetUp.Foreground     = ConvertTo-Brush $t.NetUpText
    $txtTitle.Foreground     = ConvertTo-Brush $t.TitleText
    $txtClock.Foreground     = ConvertTo-Brush $t.ClockText
    $lblAlerts.Foreground    = ConvertTo-Brush $t.AlertLabel
    $txtAlerts.Foreground    = ConvertTo-Brush $t.AlertOk

    $btnTheme.Background     = ConvertTo-Brush $t.ThemeBtnBg
    $btnTheme.Foreground     = ConvertTo-Brush $t.ThemeBtnFg
    $btnTheme.BorderBrush    = ConvertTo-Brush $t.ThemeBtnBdr
    $btnTheme.Content        = "THEME: $name"

    # All secondary-text elements repainted in bulk with the theme's dim color.
    $dimBrush = ConvertTo-Brush $t.DimText
    foreach ($lbl in $dimLabels) {
        if ($lbl) { $lbl.Foreground = $dimBrush }
    }
}
