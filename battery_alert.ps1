# battery_alert_pretty.ps1
# Requires: BurntToast module

Import-Module BurntToast

# Get battery info
$battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue

if ($null -eq $battery) {
    New-BurntToastNotification -Text "⚠️ Battery Script Error", "No battery detected or unable to read status."
    exit
}

$charge = [int]$battery.EstimatedChargeRemaining

# Define thresholds
$lowThreshold = 25
$highThreshold = 75

# Choose notification style
if ($charge -lt $lowThreshold) {
    New-BurntToastNotification -Text "Battery Low", "Battery is at $charge%. Please plug in your charger."
}
elseif ($charge -gt $highThreshold) {
    New-BurntToastNotification -Text "Battery High", "Battery is at $charge%. You may unplug your charger."
}
