# =============================================================================
#  PC GAMING HEALTH DASHBOARD
#  Run: powershell -ExecutionPolicy Bypass -File GamingDashboard.ps1
# =============================================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

. "$PSScriptRoot\src\Themes.ps1"
. "$PSScriptRoot\src\Monitors.ps1"
. "$PSScriptRoot\src\Dashboard.ps1"
