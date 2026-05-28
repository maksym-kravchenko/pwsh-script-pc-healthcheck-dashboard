# =============================================================================
#  PC GAMING HEALTH DASHBOARD
# =============================================================================
#  HOW TO RUN:
#    powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
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
    Height="700" Width="1040"
    Background="#0d1117"
    WindowStyle="SingleBorderWindow"
    ResizeMode="CanMinimize"
    TextOptions.TextFormattingMode="Display"
    TextOptions.TextRenderingMode="ClearType"
    UseLayoutRounding="True">

  <Grid x:Name="rootGrid" Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="50"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="40"/>
    </Grid.RowDefinitions>

    <!-- ===== TITLE BAR ===== -->
    <Grid x:Name="gridTitle" Grid.Row="0" Background="#0d1117">
      <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
        <TextBlock x:Name="txtTitle"
                   Text="  GAMING PC DASHBOARD  |  v1.2"
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
                Content="THEME: DARK"
                Background="#21262d" Foreground="#f0b03c"
                BorderBrush="#30363d" BorderThickness="1"
                FontFamily="Consolas" FontSize="10" FontWeight="Bold"
                Padding="12,5" Cursor="Hand">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border Background="{TemplateBinding Background}"
                      BorderBrush="{TemplateBinding BorderBrush}"
                      BorderThickness="{TemplateBinding BorderThickness}"
                      CornerRadius="6"
                      Padding="{TemplateBinding Padding}">
                <ContentPresenter HorizontalAlignment="Center"
                                  VerticalAlignment="Center"/>
              </Border>
            </ControlTemplate>
          </Button.Template>
        </Button>
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
              BorderThickness="1" Margin="6" CornerRadius="8">
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
              BorderThickness="1" Margin="6" CornerRadius="8">
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
              BorderThickness="1" Margin="6" CornerRadius="8">
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
              BorderThickness="1" Margin="6" CornerRadius="8">
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
              BorderThickness="1" Margin="6" CornerRadius="8">
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
              BorderThickness="1" Margin="6" CornerRadius="8">
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
    <Grid x:Name="gridAlert" Grid.Row="3" Background="#161b22">
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

# Title
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

# =============================================================================
#  THEME DEFINITIONS
# =============================================================================
$script:themes = @{

    "DARK" = @{
        WinBg        = "#0d1117"
        CardBg       = "#161b22"
        TitleBg      = "#0d1117"
        AlertBg      = "#161b22"
        PbBg         = "#21262d"

        CpuAccent    = "#7ee787"
        RamAccent    = "#79c0ff"
        GpuAccent    = "#ff7b72"
        DiskAccent   = "#d2a8ff"
        WifiAccent   = "#f0b03c"
        SysAccent    = "#ffa657"

        TitleText    = "#58a6ff"
        ClockText    = "#8b949e"
        TempText     = "#f0b03c"
        DimText      = "#6e7681"
        MidText      = "#484f58"
        AlertLabel   = "#f0b03c"
        AlertOk      = "#7ee787"
        AlertWarn    = "#ff7b72"
        StatusOk     = "#7ee787"
        NetDownText  = "#7ee787"
        NetUpText    = "#f0b03c"
        ThemeBtnBg   = "#21262d"
        ThemeBtnFg   = "#f0b03c"
        ThemeBtnBdr  = "#30363d"
    }

    "LIGHT" = @{
        WinBg        = "#f6f8fa"
        CardBg       = "#ffffff"
        TitleBg      = "#f6f8fa"
        AlertBg      = "#ffffff"
        PbBg         = "#eaeef2"

        CpuAccent    = "#1a7f37"
        RamAccent    = "#0969da"
        GpuAccent    = "#cf222e"
        DiskAccent   = "#8250df"
        WifiAccent   = "#9a6700"
        SysAccent    = "#bc4c00"

        TitleText    = "#0969da"
        ClockText    = "#57606a"
        TempText     = "#9a6700"
        DimText      = "#57606a"
        MidText      = "#8c959f"
        AlertLabel   = "#9a6700"
        AlertOk      = "#1a7f37"
        AlertWarn    = "#cf222e"
        StatusOk     = "#1a7f37"
        NetDownText  = "#1a7f37"
        NetUpText    = "#9a6700"
        ThemeBtnBg   = "#ffffff"
        ThemeBtnFg   = "#0969da"
        ThemeBtnBdr  = "#d0d7de"
    }
}

$script:currentTheme = "DARK"
$script:brushCache   = @{}

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
    # Freeze makes the brush immutable: WPF skips layout invalidation on every
    # assignment, and the object is safe to share across the UI thread.
    $brush.Freeze()
    $script:brushCache[$hex] = $brush
    return $brush
}

function Apply-Theme {
    param([string]$name)
    $t = $script:themes[$name]

    $window.Background          = ConvertTo-Brush $t.WinBg
    $rootGrid.Background        = ConvertTo-Brush $t.WinBg
    $gridTitle.Background       = ConvertTo-Brush $t.TitleBg
    $gridAlert.Background       = ConvertTo-Brush $t.AlertBg

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

    $hdrCpu.Foreground          = ConvertTo-Brush $t.CpuAccent
    $hdrRam.Foreground          = ConvertTo-Brush $t.RamAccent
    $hdrGpu.Foreground          = ConvertTo-Brush $t.GpuAccent
    $hdrDisk.Foreground         = ConvertTo-Brush $t.DiskAccent
    $hdrWifi.Foreground         = ConvertTo-Brush $t.WifiAccent
    $hdrSys.Foreground          = ConvertTo-Brush $t.SysAccent

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

    $txtCpuTemp.Foreground      = ConvertTo-Brush $t.TempText
    $txtGpuTemp.Foreground      = ConvertTo-Brush $t.TempText

    $txtNetDown.Foreground      = ConvertTo-Brush $t.NetDownText
    $txtNetUp.Foreground        = ConvertTo-Brush $t.NetUpText

    $txtTitle.Foreground        = ConvertTo-Brush $t.TitleText
    $txtClock.Foreground        = ConvertTo-Brush $t.ClockText

    $lblAlerts.Foreground       = ConvertTo-Brush $t.AlertLabel
    $txtAlerts.Foreground       = ConvertTo-Brush $t.AlertOk

    $btnTheme.Background        = ConvertTo-Brush $t.ThemeBtnBg
    $btnTheme.Foreground        = ConvertTo-Brush $t.ThemeBtnFg
    $btnTheme.BorderBrush       = ConvertTo-Brush $t.ThemeBtnBdr
    $btnTheme.Content           = "THEME: $name"

    $dimBrush = ConvertTo-Brush $t.DimText
    foreach ($lbl in $dimLabels) {
        if ($lbl) { $lbl.Foreground = $dimBrush }
    }
}

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

function Get-UsageBrush {
    param([int]$pct, [string]$accent)
    if ($pct -ge 90) { return ConvertTo-Brush "#ff6188" }   # always red-ish for danger
    if ($pct -ge 70) { return ConvertTo-Brush "#ffd866" }   # always yellow for warning
    return ConvertTo-Brush $accent                          # normal = card's own accent
}
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
        # Skip Microsoft Basic Display / virtual adapters when a real GPU is present.
        $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop
        $gpu = $gpus | Where-Object { $_.Name -notmatch 'Basic Display|Remote Display' } |
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

$script:netBaseline = @{}
$script:netTime     = [DateTime]::Now

# Seeds the byte counters used to compute per-second rates on the first tick.
function Initialize-Network {
    $adapters = Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
                Where-Object { $_.ReceivedBytes -gt 0 }
    foreach ($a in $adapters) {
        $script:netBaseline[$a.Name] = @{ Rx = $a.ReceivedBytes; Tx = $a.SentBytes }
    }
    $script:netTime = [DateTime]::Now
}

Initialize-Network

$cpuCounter = $null
try {
    $cpuCounter = New-Object System.Diagnostics.PerformanceCounter(
                      "Processor", "% Processor Time", "_Total")
    $null = $cpuCounter.NextValue()   # skip first call for 0
} catch {
    # Localized counter name on non-English Windows — fall back to CIM in Get-CpuPct.
    $cpuCounter = $null
}

function Get-CpuPct {
    if ($cpuCounter) {
        try { return [int]$cpuCounter.NextValue() } catch { }
    }
    try {
        $row = Get-CimInstance -Query "SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfOS_Processor WHERE Name='_Total'" -ErrorAction Stop
        if ($row) { return [int]$row.PercentProcessorTime }
    } catch { }
    return 0
}

$script:netshExe = Join-Path $env:SystemRoot "System32\netsh.exe"
if (-not (Test-Path $script:netshExe)) { $script:netshExe = "netsh.exe" }

$script:gpuEngineAvailable = $true   # set false the first time the query fails

function Get-GpuInfo {
    # 1) NVIDIA via nvidia-smi (utilization + temperature)
    try {
        $smi = & nvidia-smi --query-gpu=utilization.gpu,temperature.gpu `
                            --format=csv,noheader,nounits 2>$null
        if ($smi) {
            $line = ($smi | Select-Object -First 1).Trim()
            if ($line) {
                $parts = $line -split ","
                return @{
                    Pct  = [int]$parts[0].Trim()
                    Temp = [int]$parts[1].Trim()
                }
            }
        }
    } catch { }

    # 2) Windows GPU performance counters — works for AMD / Intel / NVIDIA on Win10+.
    if ($script:gpuEngineAvailable) {
        try {
            $engines = Get-CimInstance -ClassName Win32_PerfFormattedData_GPUPerformanceCounters_GPUEngine -ErrorAction Stop
            if ($engines) {
                # Sum the 3D engines across adapters; cap at 100.
                $util = ($engines | Where-Object { $_.Name -like '*engtype_3D*' } |
                         Measure-Object -Property UtilizationPercentage -Sum).Sum
                if ($null -eq $util) {
                    # No 3D engine instances — fall back to whatever is busiest.
                    $util = ($engines | Measure-Object -Property UtilizationPercentage -Maximum).Maximum
                }
                if ($null -ne $util) {
                    $pct = [math]::Min(100, [math]::Round($util))
                    return @{ Pct = [int]$pct; Temp = $null }
                }
            }
        } catch {
            $script:gpuEngineAvailable = $false   # WMI class missing — stop trying.
        }
    }

    # 3) OpenHardwareMonitor — handles older systems or when the counters are off.
    try {
        $sensors = Get-CimInstance -Namespace "root/OpenHardwareMonitor" `
                                   -ClassName "Sensor" -ErrorAction Stop
        $load = $sensors | Where-Object {
                    $_.SensorType -eq "Load" -and $_.Name -match "GPU"
                } | Select-Object -First 1
        $temp = $sensors | Where-Object {
                    $_.SensorType -eq "Temperature" -and $_.Name -match "GPU"
                } | Select-Object -First 1
        if ($load) {
            return @{
                Pct  = [int][math]::Round($load.Value)
                Temp = if ($temp) { [int][math]::Round($temp.Value) } else { $null }
            }
        }
    } catch { }

    return $null
}

function Get-WifiInfo {
    $ssid    = ""
    $signal  = 0
    $hasWifi = $false

    try {
        # netsh returns string[] — iterate so $Matches is populated per line.
        $raw = & $script:netshExe wlan show interfaces 2>$null
        if ($raw) {
            $hasWifi = $true
            foreach ($line in $raw) {
                # SSID line — \s* avoids accidentally requiring whitespace; the
                # literal 'S' rules out BSSID lines automatically.
                if (-not $ssid -and $line -match '^\s*SSID\s*:\s*(.+?)\s*$') {
                    $ssid = $Matches[1]
                }
                # Only Signal in this output ends with N% — language-neutral.
                elseif ($signal -eq 0 -and $line -match ':\s*(\d{1,3})\s*%\s*$') {
                    $signal = [int]$Matches[1]
                    if ($signal -gt 100) { $signal = 100 }
                }
            }
        }
    } catch { }

    # Fallback when netsh is missing the SSID (non-English label, disconnected, etc.)
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

$script:tick = 0

function Update-Dashboard {
  try {
    $script:tick++
    $t   = $script:themes[$script:currentTheme]
    $alerts = @()

    $txtClock.Text = Get-Date -Format "HH:mm:ss"

    $cpuPct = Get-CpuPct
    $txtCpuPct.Text   = "$cpuPct%"
    $pbCpu.Value      = $cpuPct
    $pbCpu.Foreground = Get-UsageBrush $cpuPct $t.CpuAccent
    $txtCpuPct.Foreground = $pbCpu.Foreground
    if ($cpuPct -ge 90) { $alerts += "CPU $cpuPct%" }

    # CPU temp is polled every 3 s — WMI calls are expensive, daily-driver values don't
    # change fast enough to justify hitting OHM every second.
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

    $gpu = Get-GpuInfo
    if ($gpu) {
        $txtGpuPct.Text        = "$($gpu.Pct)%"
        $pbGpu.Value           = $gpu.Pct
        $pbGpu.Foreground      = Get-UsageBrush $gpu.Pct $t.GpuAccent
        $txtGpuPct.Foreground  = $pbGpu.Foreground
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

    $now     = [DateTime]::Now
    $elapsed = ($now - $script:netTime).TotalSeconds
    if ($elapsed -lt 0.1) { $elapsed = 1 }   # guard against sub-100ms delta on first call

    $totalRx = 0.0
    $totalTx = 0.0

    $current = Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
               Where-Object { $_.ReceivedBytes -gt 0 }

    # Diff cumulative adapter byte counters against the last snapshot to get bytes/sec.
    # The baseline is updated each tick so the next diff covers exactly one interval.
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

    if ($script:tick % 3 -eq 0 -or $script:tick -eq 1) {
        $wifi = Get-WifiInfo
        $txtSsid.Text      = $wifi.SSID
        $txtSignalPct.Text = "$($wifi.Signal) %"
        $pbSignal.Value    = $wifi.Signal
    }

    if ($script:tick % 10 -eq 0 -or $script:tick -eq 1) {
        $boot   = $osNow.LastBootUpTime
        $uptime = $now - $boot
        $txtUptime.Text = "{0}d {1:D2}h {2:D2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    }

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
    Apply-Theme $script:currentTheme
    Initialize-StaticInfo
    Update-Dashboard
    $timer.Start()
})

$window.Add_Closing({
    $timer.Stop()
    if ($cpuCounter) {
        try { $cpuCounter.Dispose() } catch { }
    }
})

$btnTheme.Add_Click({
    $script:currentTheme = if ($script:currentTheme -eq "DARK") { "LIGHT" } else { "DARK" }
    Apply-Theme $script:currentTheme
})

# ShowDialog blocks the script until the window is closed.
# Assigning to $null suppresses the DialogResult value from appearing in the console.
$null = $window.ShowDialog()