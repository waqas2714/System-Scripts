# smart_battery_notifier.ps1
Import-Module BurntToast

# Get battery info
$battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue

if ($null -eq $battery) {
    New-BurntToastNotification -Text "Battery Script Error", "No battery detected or unable to read status."
    exit
}

# Battery charge level
$charge = [int]$battery.EstimatedChargeRemaining

# Battery status meanings:
# 1 = Discharging, 2 = AC Power (Charging), 3 = Fully Charged
$status = [int]$battery.BatteryStatus

# Define thresholds
$lowThreshold = 25
$highThreshold = 85

# Only notify when conditions actually make sense
if ($status -eq 1 -and $charge -lt $lowThreshold) {
    # Not plugged in & low battery
    New-BurntToastNotification -Text "Battery Low", "Battery is at $charge%. Please plug in your charger."
}
elseif (($status -eq 2 -or $status -eq 3) -and $charge -gt $highThreshold) {
    # Plugged in & battery full/high
    New-BurntToastNotification -Text "Battery High", "Battery is at $charge%. You can unplug your charger."
}
