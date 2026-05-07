# =============================================================================
#  PC GAMING HEALTH DASHBOARD - Alpha v1.1
# =============================================================================
#  HOW TO RUN:
#    powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
#
#  OPTIONAL temperatures : Run OpenHardwareMonitor as Administrator first
#  OPTIONAL NVIDIA GPU   : nvidia-smi must be in PATH (comes with drivers)
# =============================================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# =============================================================================
#  XAML
# =============================================================================
$xamlString = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PC Gaming Dashboard"
    Height="680" Width="1000"
    Background="#1e1e1e"
    WindowStyle="SingleBorderWindow"
    ResizeMode="CanMinimize">

  <Grid x:Name="rootGrid" Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="50"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="40"/>
    </Grid.RowDefinitions>

    <!-- ===== TITLE BAR ===== -->
    <Grid x:Name="gridTitle" Grid.Row="0" Background="#1e1e1e">
      <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
        <TextBlock x:Name="txtTitle"
                   Text="  GAMING PC DASHBOARD  |  Alpha v1.1"
                   Foreground="#a9dc76"
                   FontFamily="Consolas" FontSize="17" FontWeight="Bold"/>
      </StackPanel>
      <StackPanel Orientation="Horizontal" HorizontalAlignment="Right"
                  VerticalAlignment="Center">
        <TextBlock x:Name="txtClock"
                   Text="00:00:00"
                   Foreground="#6a6a6a"
                   FontFamily="Consolas" FontSize="15"
                   VerticalAlignment="Center" Margin="0,0,14,0"/>
        <Button x:Name="btnTheme"
                Content="THEME: MONOKAI"
                Background="#333333" Foreground="#ffd866"
                BorderBrush="#ffd866" BorderThickness="1"
                FontFamily="Consolas" FontSize="10" FontWeight="Bold"
                Padding="8,4" Cursor="Hand"/>
      </StackPanel>
    </Grid>

    <!-- ===== TOP ROW: CPU | RAM | GPU ===== -->
    <Grid Grid.Row="1" Margin="0,8,0,4">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- CPU CARD -->
      <Border x:Name="borderCpu" Grid.Column="0"
              Background="#252526" BorderBrush="#a9dc76"
              BorderThickness="1" Margin="4">
        <StackPanel Margin="14,12">
          <TextBlock x:Name="hdrCpu" Text="[ CPU ]"
                     Foreground="#a9dc76"
                     FontFamily="Consolas" FontSize="13" FontWeight="Bold"/>
          <TextBlock x:Name="txtCpuPct"
                     Text="0%" Foreground="#a9dc76"
                     FontFamily="Consolas" FontSize="48" FontWeight="Bold"
                     HorizontalAlignment="Center" Margin="0,4,0,4"/>
          <ProgressBar x:Name="pbCpu"
                       Minimum="0" Maximum="100" Value="0"
                       Height="12" Foreground="#a9dc76" Background="#333333"
                       Margin="0,0,0,8"/>
          <StackPanel Orientation="Horizontal">
            <TextBlock x:Name="lblCpuTemp" Text="TEMP: "
                       Foreground="#5a5a5a"
                       FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtCpuTemp" Text="-- C"
                       Foreground="#ffd866"
                       FontFamily="Consolas" FontSize="11" FontWeight="Bold"/>
          </StackPanel>
          <TextBlock x:Name="txtCpuName" Text="Loading..."
                     Foreground="#3a3a3a"
                     FontFamily="Consolas" FontSize="9"
                     TextWrapping="Wrap" Margin="0,6,0,0"/>
        </StackPanel>
      </Border>

      <!-- RAM CARD -->
      <Border x:Name="borderRam" Grid.Column="1"
              Background="#252526" BorderBrush="#78dce8"
              BorderThickness="1" Margin="4">
        <StackPanel Margin="14,12">
          <TextBlock x:Name="hdrRam" Text="[ RAM ]"
                     Foreground="#78dce8"
                     FontFamily="Consolas" FontSize="13" FontWeight="Bold"/>
          <TextBlock x:Name="txtRamPct"
                     Text="0%" Foreground="#78dce8"
                     FontFamily="Consolas" FontSize="48" FontWeight="Bold"
                     HorizontalAlignment="Center" Margin="0,4,0,4"/>
          <ProgressBar x:Name="pbRam"
                       Minimum="0" Maximum="100" Value="0"
                       Height="12" Foreground="#78dce8" Background="#333333"
                       Margin="0,0,0,8"/>
          <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
            <TextBlock x:Name="txtRamUsed" Text="0 GB"
                       Foreground="#78dce8"
                       FontFamily="Consolas" FontSize="13" FontWeight="Bold"/>
            <TextBlock x:Name="lblRamSlash" Text=" / "
                       Foreground="#3a3a3a"
                       FontFamily="Consolas" FontSize="13"/>
            <TextBlock x:Name="txtRamTotal" Text="0 GB"
                       Foreground="#3a3a3a"
                       FontFamily="Consolas" FontSize="13"/>
          </StackPanel>
          <TextBlock x:Name="txtRamSpeed" Text="-- MHz"
                     Foreground="#3a3a3a"
                     FontFamily="Consolas" FontSize="9"
                     HorizontalAlignment="Center" Margin="0,6,0,0"/>
        </StackPanel>
      </Border>

      <!-- GPU CARD -->
      <Border x:Name="borderGpu" Grid.Column="2"
              Background="#252526" BorderBrush="#ff6188"
              BorderThickness="1" Margin="4">
        <StackPanel Margin="14,12">
          <TextBlock x:Name="hdrGpu" Text="[ GPU ]"
                     Foreground="#ff6188"
                     FontFamily="Consolas" FontSize="13" FontWeight="Bold"/>
          <TextBlock x:Name="txtGpuPct"
                     Text="N/A" Foreground="#ff6188"
                     FontFamily="Consolas" FontSize="48" FontWeight="Bold"
                     HorizontalAlignment="Center" Margin="0,4,0,4"/>
          <ProgressBar x:Name="pbGpu"
                       Minimum="0" Maximum="100" Value="0"
                       Height="12" Foreground="#ff6188" Background="#333333"
                       Margin="0,0,0,8"/>
          <StackPanel Orientation="Horizontal">
            <TextBlock x:Name="lblGpuTemp" Text="TEMP: "
                       Foreground="#5a5a5a"
                       FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtGpuTemp" Text="-- C"
                       Foreground="#ffd866"
                       FontFamily="Consolas" FontSize="11" FontWeight="Bold"/>
          </StackPanel>
          <TextBlock x:Name="txtGpuName" Text="Detecting..."
                     Foreground="#3a3a3a"
                     FontFamily="Consolas" FontSize="9"
                     TextWrapping="Wrap" Margin="0,6,0,0"/>
        </StackPanel>
      </Border>
    </Grid>

    <!-- ===== BOTTOM ROW: DISK | WIFI | SYSTEM ===== -->
    <Grid Grid.Row="2" Margin="0,4,0,8">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- DISK CARD -->
      <Border x:Name="borderDisk" Grid.Column="0"
              Background="#252526" BorderBrush="#ab9df2"
              BorderThickness="1" Margin="4">
        <StackPanel Margin="14,12">
          <TextBlock x:Name="hdrDisk" Text="[ DISK  C:\ ]"
                     Foreground="#ab9df2"
                     FontFamily="Consolas" FontSize="13" FontWeight="Bold"/>
          <TextBlock x:Name="txtDiskPct"
                     Text="0%" Foreground="#ab9df2"
                     FontFamily="Consolas" FontSize="48" FontWeight="Bold"
                     HorizontalAlignment="Center" Margin="0,4,0,4"/>
          <ProgressBar x:Name="pbDisk"
                       Minimum="0" Maximum="100" Value="0"
                       Height="12" Foreground="#ab9df2" Background="#333333"
                       Margin="0,0,0,8"/>
          <Grid>
            <Grid.ColumnDefinitions>
              <ColumnDefinition/>
              <ColumnDefinition/>
            </Grid.ColumnDefinitions>
            <StackPanel HorizontalAlignment="Center">
              <TextBlock x:Name="lblDiskUsed" Text="USED"
                         Foreground="#5a5a5a"
                         FontFamily="Consolas" FontSize="9"
                         HorizontalAlignment="Center"/>
              <TextBlock x:Name="txtDiskUsed" Text="--"
                         Foreground="#ab9df2"
                         FontFamily="Consolas" FontSize="13" FontWeight="Bold"
                         HorizontalAlignment="Center"/>
            </StackPanel>
            <StackPanel Grid.Column="1" HorizontalAlignment="Center">
              <TextBlock x:Name="lblDiskFree" Text="FREE"
                         Foreground="#5a5a5a"
                         FontFamily="Consolas" FontSize="9"
                         HorizontalAlignment="Center"/>
              <TextBlock x:Name="txtDiskFree" Text="--"
                         Foreground="#5a5a5a"
                         FontFamily="Consolas" FontSize="13"
                         HorizontalAlignment="Center"/>
            </StackPanel>
          </Grid>
        </StackPanel>
      </Border>

      <!-- WIFI CARD -->
      <Border x:Name="borderWifi" Grid.Column="1"
              Background="#252526" BorderBrush="#ffd866"
              BorderThickness="1" Margin="4">
        <StackPanel Margin="14,12">
          <TextBlock x:Name="hdrWifi" Text="[ WI-FI ]"
                     Foreground="#ffd866"
                     FontFamily="Consolas" FontSize="13" FontWeight="Bold"/>

          <!-- SSID row -->
          <StackPanel Orientation="Horizontal" Margin="0,6,0,2">
            <TextBlock x:Name="lblSsid" Text="SSID   : "
                       Foreground="#5a5a5a"
                       FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtSsid" Text="Scanning..."
                       Foreground="#ffd866"
                       FontFamily="Consolas" FontSize="11" FontWeight="Bold"/>
          </StackPanel>

          <!-- Signal row -->
          <StackPanel Orientation="Horizontal" Margin="0,2,0,4">
            <TextBlock x:Name="lblSignal" Text="SIGNAL : "
                       Foreground="#5a5a5a"
                       FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtSignalPct" Text="-- %"
                       Foreground="#ffd866"
                       FontFamily="Consolas" FontSize="11" FontWeight="Bold"/>
          </StackPanel>
          <ProgressBar x:Name="pbSignal"
                       Minimum="0" Maximum="100" Value="0"
                       Height="10" Foreground="#ffd866" Background="#333333"
                       Margin="0,0,0,10"/>

          <!-- Speed rows -->
          <TextBlock x:Name="lblDown" Text="DOWNLOAD"
                     Foreground="#5a5a5a"
                     FontFamily="Consolas" FontSize="9"/>
          <TextBlock x:Name="txtNetDown" Text="0 KB/s"
                     Foreground="#a9dc76"
                     FontFamily="Consolas" FontSize="20" FontWeight="Bold"
                     Margin="0,0,0,6"/>
          <TextBlock x:Name="lblUp" Text="UPLOAD"
                     Foreground="#5a5a5a"
                     FontFamily="Consolas" FontSize="9"/>
          <TextBlock x:Name="txtNetUp" Text="0 KB/s"
                     Foreground="#ffd866"
                     FontFamily="Consolas" FontSize="20" FontWeight="Bold"/>
        </StackPanel>
      </Border>

      <!-- SYSTEM INFO CARD -->
      <Border x:Name="borderSys" Grid.Column="2"
              Background="#252526" BorderBrush="#fc9867"
              BorderThickness="1" Margin="4">
        <StackPanel Margin="14,12">
          <TextBlock x:Name="hdrSys" Text="[ SYSTEM ]"
                     Foreground="#fc9867"
                     FontFamily="Consolas" FontSize="13" FontWeight="Bold"
                     Margin="0,0,0,10"/>
          <StackPanel Orientation="Horizontal" Margin="0,3">
            <TextBlock x:Name="lblUptime" Text="UPTIME  : "
                       Foreground="#5a5a5a" FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtUptime" Text="--"
                       Foreground="#fc9867" FontFamily="Consolas" FontSize="11"/>
          </StackPanel>
          <StackPanel Orientation="Horizontal" Margin="0,3">
            <TextBlock x:Name="lblOS" Text="OS      : "
                       Foreground="#5a5a5a" FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtOS" Text="--"
                       Foreground="#fc9867" FontFamily="Consolas" FontSize="11"/>
          </StackPanel>
          <StackPanel Orientation="Horizontal" Margin="0,3">
            <TextBlock x:Name="lblHost" Text="HOST    : "
                       Foreground="#5a5a5a" FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtHost" Text="--"
                       Foreground="#fc9867" FontFamily="Consolas" FontSize="11"/>
          </StackPanel>
          <StackPanel Orientation="Horizontal" Margin="0,3">
            <TextBlock x:Name="lblFPS" Text="FPS     : "
                       Foreground="#5a5a5a" FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtFPS" Text="N/A"
                       Foreground="#ff6188" FontFamily="Consolas" FontSize="11"/>
          </StackPanel>
          <StackPanel Orientation="Horizontal" Margin="0,3">
            <TextBlock x:Name="lblStatus" Text="STATUS  : "
                       Foreground="#5a5a5a" FontFamily="Consolas" FontSize="11"/>
            <TextBlock x:Name="txtStatus" Text="LIVE"
                       Foreground="#a9dc76" FontFamily="Consolas" FontSize="11"/>
          </StackPanel>
        </StackPanel>
      </Border>
    </Grid>

    <!-- ===== ALERT BAR ===== -->
    <Grid x:Name="gridAlert" Grid.Row="3" Background="#1a1a1a">
      <TextBlock x:Name="lblAlerts" Text="  ALERTS: "
                 Foreground="#ffd866"
                 FontFamily="Consolas" FontSize="11" FontWeight="Bold"
                 VerticalAlignment="Center"/>
      <TextBlock x:Name="txtAlerts" Text="All systems nominal"
                 Foreground="#a9dc76"
                 FontFamily="Consolas" FontSize="11"
                 VerticalAlignment="Center" Margin="70,0,0,0"/>
      <TextBlock x:Name="txtLastUpdate" Text="Updated: --"
                 Foreground="#3a3a3a"
                 FontFamily="Consolas" FontSize="9"
                 HorizontalAlignment="Right" VerticalAlignment="Center"
                 Margin="0,0,8,0"/>
    </Grid>

  </Grid>
</Window>
"@

# =============================================================================
#  LOAD WINDOW
# =============================================================================
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xamlString)
$window = [Windows.Markup.XamlReader]::Load($reader)

function Find { param($n) $window.FindName($n) }

# Title / chrome
$rootGrid      = Find "rootGrid"
$gridTitle     = Find "gridTitle"
$gridAlert     = Find "gridAlert"
$txtTitle      = Find "txtTitle"
$txtClock      = Find "txtClock"
$btnTheme      = Find "btnTheme"

# Borders
$borderCpu     = Find "borderCpu"
$borderRam     = Find "borderRam"
$borderGpu     = Find "borderGpu"
$borderDisk    = Find "borderDisk"
$borderWifi    = Find "borderWifi"
$borderSys     = Find "borderSys"

# Headers
$hdrCpu        = Find "hdrCpu"
$hdrRam        = Find "hdrRam"
$hdrGpu        = Find "hdrGpu"
$hdrDisk       = Find "hdrDisk"
$hdrWifi       = Find "hdrWifi"
$hdrSys        = Find "hdrSys"

# CPU
$txtCpuPct     = Find "txtCpuPct"
$txtCpuTemp    = Find "txtCpuTemp"
$txtCpuName    = Find "txtCpuName"
$pbCpu         = Find "pbCpu"

# RAM
$txtRamPct     = Find "txtRamPct"
$txtRamUsed    = Find "txtRamUsed"
$txtRamTotal   = Find "txtRamTotal"
$txtRamSpeed   = Find "txtRamSpeed"
$pbRam         = Find "pbRam"

# GPU
$txtGpuPct     = Find "txtGpuPct"
$txtGpuTemp    = Find "txtGpuTemp"
$txtGpuName    = Find "txtGpuName"
$pbGpu         = Find "pbGpu"

# DISK
$txtDiskPct    = Find "txtDiskPct"
$txtDiskUsed   = Find "txtDiskUsed"
$txtDiskFree   = Find "txtDiskFree"
$pbDisk        = Find "pbDisk"

# WIFI
$txtSsid       = Find "txtSsid"
$txtSignalPct  = Find "txtSignalPct"
$pbSignal      = Find "pbSignal"
$txtNetDown    = Find "txtNetDown"
$txtNetUp      = Find "txtNetUp"

# SYSTEM
$txtUptime     = Find "txtUptime"
$txtOS         = Find "txtOS"
$txtHost       = Find "txtHost"
$txtFPS        = Find "txtFPS"
$txtStatus     = Find "txtStatus"

# ALERTS
$lblAlerts     = Find "lblAlerts"
$txtAlerts     = Find "txtAlerts"
$txtLastUpdate = Find "txtLastUpdate"

# Dim labels (for full theme recolor)
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

# =============================================================================
#  THEME DEFINITIONS
# =============================================================================
$script:themes = @{

    "MONOKAI" = @{
        # Window / structural
        WinBg        = "#1e1e1e"
        CardBg       = "#252526"
        TitleBg      = "#1e1e1e"
        AlertBg      = "#1a1a1a"
        PbBg         = "#333333"
        # Per-card accent colors
        CpuAccent    = "#a9dc76"   # green
        RamAccent    = "#78dce8"   # cyan
        GpuAccent    = "#ff6188"   # pink
        DiskAccent   = "#ab9df2"   # purple
        WifiAccent   = "#ffd866"   # yellow
        SysAccent    = "#fc9867"   # orange
        # General text
        TitleText    = "#a9dc76"
        ClockText    = "#6a6a6a"
        TempText     = "#ffd866"
        DimText      = "#5a5a5a"
        MidText      = "#3a3a3a"
        AlertLabel   = "#ffd866"
        AlertOk      = "#a9dc76"
        AlertWarn    = "#ff6188"
        StatusOk     = "#a9dc76"
        NetDownText  = "#a9dc76"
        NetUpText    = "#ffd866"
        ThemeBtnBg   = "#333333"
        ThemeBtnFg   = "#ffd866"
        ThemeBtnBdr  = "#ffd866"
    }

    "SOLARIZED" = @{
        # Window / structural
        WinBg        = "#fdf6e3"
        CardBg       = "#eee8d5"
        TitleBg      = "#e8e0c8"
        AlertBg      = "#e8e0c8"
        PbBg         = "#d0c8b0"
        # Per-card accent colors
        CpuAccent    = "#859900"   # olive green
        RamAccent    = "#268bd2"   # blue
        GpuAccent    = "#dc322f"   # red
        DiskAccent   = "#6c71c4"   # violet
        WifiAccent   = "#b58900"   # yellow
        SysAccent    = "#cb4b16"   # orange
        # General text
        TitleText    = "#268bd2"
        ClockText    = "#93a1a1"
        TempText     = "#b58900"
        DimText      = "#93a1a1"
        MidText      = "#93a1a1"
        AlertLabel   = "#b58900"
        AlertOk      = "#859900"
        AlertWarn    = "#dc322f"
        StatusOk     = "#859900"
        NetDownText  = "#859900"
        NetUpText    = "#b58900"
        ThemeBtnBg   = "#eee8d5"
        ThemeBtnFg   = "#268bd2"
        ThemeBtnBdr  = "#268bd2"
    }
}

$script:currentTheme = "MONOKAI"

# =============================================================================
#  HELPER: Convert hex string to SolidColorBrush
# =============================================================================
function ConvertTo-Brush {
    param([string]$hex)
    $hex = $hex.TrimStart("#")
    $r = [Convert]::ToByte($hex.Substring(0,2), 16)
    $g = [Convert]::ToByte($hex.Substring(2,2), 16)
    $b = [Convert]::ToByte($hex.Substring(4,2), 16)
    return [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.Color]::FromRgb($r, $g, $b))
}

# =============================================================================
#  APPLY THEME
# =============================================================================
function Apply-Theme {
    param([string]$name)
    $t = $script:themes[$name]

    # Window and layout backgrounds
    $window.Background          = ConvertTo-Brush $t.WinBg
    $rootGrid.Background        = ConvertTo-Brush $t.WinBg
    $gridTitle.Background       = ConvertTo-Brush $t.TitleBg
    $gridAlert.Background       = ConvertTo-Brush $t.AlertBg

    # Card backgrounds and borders
    $borderCpu.Background       = ConvertTo-Brush $t.CardBg
    $borderRam.Background       = ConvertTo-Brush $t.CardBg
    $borderGpu.Background       = ConvertTo-Brush $t.CardBg
    $borderDisk.Background      = ConvertTo-Brush $t.CardBg
    $borderWifi.Background      = ConvertTo-Brush $t.CardBg
    $borderSys.Background       = ConvertTo-Brush $t.CardBg

    $borderCpu.BorderBrush      = ConvertTo-Brush $t.CpuAccent
    $borderRam.BorderBrush      = ConvertTo-Brush $t.RamAccent
    $borderGpu.BorderBrush      = ConvertTo-Brush $t.GpuAccent
    $borderDisk.BorderBrush     = ConvertTo-Brush $t.DiskAccent
    $borderWifi.BorderBrush     = ConvertTo-Brush $t.WifiAccent
    $borderSys.BorderBrush      = ConvertTo-Brush $t.SysAccent

    # Card headers
    $hdrCpu.Foreground          = ConvertTo-Brush $t.CpuAccent
    $hdrRam.Foreground          = ConvertTo-Brush $t.RamAccent
    $hdrGpu.Foreground          = ConvertTo-Brush $t.GpuAccent
    $hdrDisk.Foreground         = ConvertTo-Brush $t.DiskAccent
    $hdrWifi.Foreground         = ConvertTo-Brush $t.WifiAccent
    $hdrSys.Foreground          = ConvertTo-Brush $t.SysAccent

    # Big stat numbers
    $txtCpuPct.Foreground       = ConvertTo-Brush $t.CpuAccent
    $txtRamPct.Foreground       = ConvertTo-Brush $t.RamAccent
    $txtGpuPct.Foreground       = ConvertTo-Brush $t.GpuAccent
    $txtDiskPct.Foreground      = ConvertTo-Brush $t.DiskAccent
    $txtSsid.Foreground         = ConvertTo-Brush $t.WifiAccent
    $txtSignalPct.Foreground    = ConvertTo-Brush $t.WifiAccent
    $txtRamUsed.Foreground      = ConvertTo-Brush $t.RamAccent
    $txtDiskUsed.Foreground     = ConvertTo-Brush $t.DiskAccent
    $txtUptime.Foreground       = ConvertTo-Brush $t.SysAccent
    $txtOS.Foreground           = ConvertTo-Brush $t.SysAccent
    $txtHost.Foreground         = ConvertTo-Brush $t.SysAccent

    # Progress bars
    $pbCpu.Foreground           = ConvertTo-Brush $t.CpuAccent
    $pbRam.Foreground           = ConvertTo-Brush $t.RamAccent
    $pbGpu.Foreground           = ConvertTo-Brush $t.GpuAccent
    $pbDisk.Foreground          = ConvertTo-Brush $t.DiskAccent
    $pbSignal.Foreground        = ConvertTo-Brush $t.WifiAccent
    $pbCpu.Background           = ConvertTo-Brush $t.PbBg
    $pbRam.Background           = ConvertTo-Brush $t.PbBg
    $pbGpu.Background           = ConvertTo-Brush $t.PbBg
    $pbDisk.Background          = ConvertTo-Brush $t.PbBg
    $pbSignal.Background        = ConvertTo-Brush $t.PbBg

    # Temp / special colors
    $txtCpuTemp.Foreground      = ConvertTo-Brush $t.TempText
    $txtGpuTemp.Foreground      = ConvertTo-Brush $t.TempText

    # Network speeds
    $txtNetDown.Foreground      = ConvertTo-Brush $t.NetDownText
    $txtNetUp.Foreground        = ConvertTo-Brush $t.NetUpText

    # Title bar
    $txtTitle.Foreground        = ConvertTo-Brush $t.TitleText
    $txtClock.Foreground        = ConvertTo-Brush $t.ClockText

    # Alert bar
    $lblAlerts.Foreground       = ConvertTo-Brush $t.AlertLabel
    $txtAlerts.Foreground       = ConvertTo-Brush $t.AlertOk

    # Theme button
    $btnTheme.Background        = ConvertTo-Brush $t.ThemeBtnBg
    $btnTheme.Foreground        = ConvertTo-Brush $t.ThemeBtnFg
    $btnTheme.BorderBrush       = ConvertTo-Brush $t.ThemeBtnBdr
    $btnTheme.Content           = "THEME: $name"

    # Dim / secondary text labels
    $dimBrush = ConvertTo-Brush $t.DimText
    foreach ($lbl in $dimLabels) {
        if ($lbl) { $lbl.Foreground = $dimBrush }
    }
}

# =============================================================================
#  HELPER FUNCTIONS
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

# Returns green/orange/red brush based on current theme's accent for alerts
function Get-UsageBrush {
    param([int]$pct, [string]$accent)
    if ($pct -ge 90) { return ConvertTo-Brush "#ff6188" }   # always red-ish for danger
    if ($pct -ge 70) { return ConvertTo-Brush "#ffd866" }   # always yellow for warning
    return ConvertTo-Brush $accent                           # normal = card's own accent
}

# =============================================================================
#  STATIC INFO - runs once on startup
# =============================================================================
function Initialize-StaticInfo {
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $txtCpuName.Text = $cpu.Name -replace "\s{2,}", " "

    $ram = Get-CimInstance Win32_PhysicalMemory | Select-Object -First 1
    if ($ram -and $ram.Speed) { $txtRamSpeed.Text = "$($ram.Speed) MHz" }

    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    if ($gpu) { $txtGpuName.Text = $gpu.Name }

    $os = Get-CimInstance Win32_OperatingSystem
    $txtOS.Text   = $os.Caption -replace "Microsoft Windows ", "Win "
    $txtHost.Text = $env:COMPUTERNAME
}

# =============================================================================
#  NETWORK BASELINE  (for delta speed calculation)
# =============================================================================
$script:netBaseline = @{}
$script:netTime     = [DateTime]::Now

function Initialize-Network {
    $adapters = Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
                Where-Object { $_.ReceivedBytes -gt 0 }
    foreach ($a in $adapters) {
        $script:netBaseline[$a.Name] = @{ Rx = $a.ReceivedBytes; Tx = $a.SentBytes }
    }
    $script:netTime = [DateTime]::Now
}

Initialize-Network

# =============================================================================
#  CPU PERFORMANCE COUNTER
# =============================================================================
$cpuCounter = New-Object System.Diagnostics.PerformanceCounter(
                  "Processor", "% Processor Time", "_Total")
$null = $cpuCounter.NextValue()   # first call always returns 0 — discard it

# =============================================================================
#  WIFI INFO  (netsh)
# =============================================================================
function Get-WifiInfo {
    try {
        $raw = & netsh wlan show interfaces 2>$null
        if (-not $raw) { return @{ SSID = "No WiFi adapter"; Signal = 0 } }

        $ssid   = if ($raw -match "(?m)^\s+SSID\s*:\s*(.+)$")   { $Matches[1].Trim() } else { "Not connected" }
        $signal = if ($raw -match "(?m)^\s+Signal\s*:\s*(\d+)%") { [int]$Matches[1]  } else { 0 }
        return @{ SSID = $ssid; Signal = $signal }
    } catch {
        return @{ SSID = "No WiFi"; Signal = 0 }
    }
}

# =============================================================================
#  TICK COUNTER  (so we can run heavy ops less often)
# =============================================================================
$script:tick = 0

# =============================================================================
#  MAIN UPDATE FUNCTION  (called every 1 second)
# =============================================================================
function Update-Dashboard {
    $script:tick++
    $t   = $script:themes[$script:currentTheme]
    $alerts = @()

    # ── Clock (every tick) ────────────────────────────────────────────────────
    $txtClock.Text = Get-Date -Format "HH:mm:ss"

    # ── CPU (every tick — PerformanceCounter is designed for frequent reads) ──
    $cpuPct = [math]::Round($cpuCounter.NextValue())
    $txtCpuPct.Text   = "$cpuPct%"
    $pbCpu.Value      = $cpuPct
    $pbCpu.Foreground = Get-UsageBrush $cpuPct $t.CpuAccent
    $txtCpuPct.Foreground = $pbCpu.Foreground
    if ($cpuPct -ge 90) { $alerts += "CPU $cpuPct%" }

    # ── CPU Temp via OpenHardwareMonitor (every 3 ticks — WMI is slow) ────────
    if ($script:tick % 3 -eq 0) {
        try {
            $sensor = Get-CimInstance -Namespace "root/OpenHardwareMonitor" `
                          -ClassName "Sensor" -ErrorAction Stop |
                      Where-Object { $_.SensorType -eq "Temperature" -and
                                     $_.Name -match "CPU" } |
                      Select-Object -First 1
            $txtCpuTemp.Text = if ($sensor) { "$([math]::Round($sensor.Value)) C" }
                               else         { "OHM needed" }
        } catch { $txtCpuTemp.Text = "OHM needed" }
    }

    # ── RAM (every tick) ──────────────────────────────────────────────────────
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

    # ── GPU via nvidia-smi (every tick) ───────────────────────────────────────
    $gpuDetected = $false
    try {
        $smi = & nvidia-smi --query-gpu=utilization.gpu,temperature.gpu `
                             --format=csv,noheader,nounits 2>$null
        if ($smi -and $smi.Trim() -ne "") {
            $parts   = $smi.Trim() -split ","
            $gpuPct  = [int]$parts[0].Trim()
            $gpuTemp = [int]$parts[1].Trim()
            $txtGpuPct.Text        = "$gpuPct%"
            $pbGpu.Value           = $gpuPct
            $pbGpu.Foreground      = Get-UsageBrush $gpuPct $t.GpuAccent
            $txtGpuPct.Foreground  = $pbGpu.Foreground
            $txtGpuTemp.Text       = "${gpuTemp} C"
            if ($gpuTemp -ge 85) { $alerts += "GPU TEMP ${gpuTemp}C" }
            $gpuDetected = $true
        }
    } catch { }

    # GPU via OHM fallback (every 3 ticks)
    if (-not $gpuDetected -and $script:tick % 3 -eq 0) {
        try {
            $gpuLoad = Get-CimInstance -Namespace "root/OpenHardwareMonitor" `
                           -ClassName "Sensor" -ErrorAction Stop |
                       Where-Object { $_.SensorType -eq "Load" -and
                                      $_.Name -match "GPU" } |
                       Select-Object -First 1
            if ($gpuLoad) {
                $gpuPct = [math]::Round($gpuLoad.Value)
                $txtGpuPct.Text   = "$gpuPct%"
                $pbGpu.Value      = $gpuPct
                $pbGpu.Foreground = Get-UsageBrush $gpuPct $t.GpuAccent
                $gpuDetected      = $true
            }
        } catch { }
    }

    if (-not $gpuDetected) { $txtGpuPct.Text = "N/A" }

    # ── DISK (every 5 ticks — disk usage doesn't change every second) ─────────
    if ($script:tick % 5 -eq 0 -or $script:tick -eq 1) {
        $drive  = Get-PSDrive C
        $dUsed  = $drive.Used
        $dFree  = $drive.Free
        $dTotal = $dUsed + $dFree
        $dPct   = [math]::Round(($dUsed / $dTotal) * 100)

        $txtDiskPct.Text       = "$dPct%"
        $txtDiskUsed.Text      = Format-Bytes $dUsed
        $txtDiskFree.Text      = Format-Bytes $dFree
        $pbDisk.Value          = $dPct
        $pbDisk.Foreground     = Get-UsageBrush $dPct $t.DiskAccent
        $txtDiskPct.Foreground = $pbDisk.Foreground
        if ($dPct -ge 90) { $alerts += "DISK $dPct%" }
    }

    # ── NETWORK SPEED (every tick — delta needs frequent sampling) ────────────
    $now     = [DateTime]::Now
    $elapsed = ($now - $script:netTime).TotalSeconds
    if ($elapsed -lt 0.1) { $elapsed = 1 }

    $totalRx = 0.0
    $totalTx = 0.0

    $current = Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
               Where-Object { $_.ReceivedBytes -gt 0 }

    foreach ($a in $current) {
        if ($script:netBaseline.ContainsKey($a.Name)) {
            $rx = [math]::Max(0, ($a.ReceivedBytes - $script:netBaseline[$a.Name].Rx) / $elapsed)
            $tx = [math]::Max(0, ($a.SentBytes     - $script:netBaseline[$a.Name].Tx) / $elapsed)
            $totalRx += $rx
            $totalTx += $tx
        }
        $script:netBaseline[$a.Name] = @{ Rx = $a.ReceivedBytes; Tx = $a.SentBytes }
    }
    $script:netTime = $now

    $txtNetDown.Text = Format-Speed $totalRx
    $txtNetUp.Text   = Format-Speed $totalTx

    # ── WIFI SIGNAL (every 3 ticks — netsh is slow) ───────────────────────────
    if ($script:tick % 3 -eq 0 -or $script:tick -eq 1) {
        $wifi = Get-WifiInfo
        $txtSsid.Text      = $wifi.SSID
        $txtSignalPct.Text = "$($wifi.Signal) %"
        $pbSignal.Value    = $wifi.Signal
    }

    # ── UPTIME (every 10 ticks) ───────────────────────────────────────────────
    if ($script:tick % 10 -eq 0 -or $script:tick -eq 1) {
        $boot   = $osNow.LastBootUpTime
        $uptime = $now - $boot
        $txtUptime.Text = "{0}d {1:D2}h {2:D2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    }

    # ── ALERTS ────────────────────────────────────────────────────────────────
    if ($alerts.Count -eq 0) {
        $txtAlerts.Text       = "All systems nominal"
        $txtAlerts.Foreground = ConvertTo-Brush $t.AlertOk
    } else {
        $txtAlerts.Text       = "WARNING: " + ($alerts -join "  |  ")
        $txtAlerts.Foreground = ConvertTo-Brush $t.AlertWarn
    }

    $txtLastUpdate.Text = "Updated: " + (Get-Date -Format "HH:mm:ss.f")
}

# =============================================================================
#  TIMER — 1 second for instant, responsive feel
# =============================================================================
$timer          = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$timer.Add_Tick({ Update-Dashboard })

# =============================================================================
#  EVENTS
# =============================================================================
$window.Add_Loaded({
    Apply-Theme "MONOKAI"
    Initialize-StaticInfo
    Update-Dashboard
    $timer.Start()
})

$window.Add_Closing({
    $timer.Stop()
    $cpuCounter.Dispose()
})

# Theme toggle button
$btnTheme.Add_Click({
    if ($script:currentTheme -eq "MONOKAI") {
        $script:currentTheme = "SOLARIZED"
    } else {
        $script:currentTheme = "MONOKAI"
    }
    Apply-Theme $script:currentTheme
})

# =============================================================================
#  RUN
# =============================================================================
$null = $window.ShowDialog()