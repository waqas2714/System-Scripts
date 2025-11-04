# smart_battery_notifier.ps1
Add-Type -AssemblyName PresentationFramework

# --- Skip notification if a game is running from W:\Games ---
$gameFolder = "W:\Games"
$processes = Get-WmiObject Win32_Process -ErrorAction SilentlyContinue

$gameRunning = $false
foreach ($p in $processes) {
    try {
        if ($p.ExecutablePath -and ($p.ExecutablePath -like "$gameFolder*")) {
            Write-Host "Game detected: $($p.Name)" -ForegroundColor Yellow
            $gameRunning = $true
            break
        }
    } catch {}
}

if ($gameRunning) {
    Write-Host "Skipping battery alert because a game is running." -ForegroundColor Gray
    exit 0
}


# --- Battery info ---
$battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
if ($null -eq $battery) {
    $message = "No battery detected or unable to read status."
    $color = "#8B0000"
}
else {
    $charge = [int]$battery.EstimatedChargeRemaining
    $status = [int]$battery.BatteryStatus

    $lowThreshold = 25
    $highThreshold = 75

    if ($status -eq 1 -and $charge -lt $lowThreshold) {
        $message = "Battery is at $charge%. Please plug in your charger."
        $color = "#B22222"   # red
    }
    elseif (($status -eq 2 -or $status -eq 3) -and $charge -gt $highThreshold) {
        $message = "Battery is at $charge%. You can unplug your charger."
        $color = "#006400"   # green
    }
    else {
        exit 0;
    }
}

# --- Simple popup window ---
$window = New-Object System.Windows.Window
$window.WindowStartupLocation = 'CenterScreen'
$window.Width = 400
$window.Height = 180
$window.Topmost = $true
$window.WindowStyle = 'ToolWindow'
$window.ResizeMode = 'NoResize'
$window.Title = "Battery Notification"

# Background
$window.Background = [Windows.Media.Brushes]::White

# Layout
$panel = New-Object System.Windows.Controls.StackPanel
$panel.Margin = '20'
$panel.VerticalAlignment = 'Center'

# Message text
$textBlock = New-Object System.Windows.Controls.TextBlock
$textBlock.Text = $message
$textBlock.FontSize = 20
$textBlock.TextAlignment = 'Center'
$textBlock.Margin = '0,0,0,20'
$textBlock.TextWrapping = 'Wrap'
$textBlock.Foreground = New-Object Windows.Media.SolidColorBrush ([Windows.Media.ColorConverter]::ConvertFromString($color))

# Close button
$button = New-Object System.Windows.Controls.Button
$button.Content = "Close"
$button.Width = 80
$button.Height = 30
$button.HorizontalAlignment = 'Center'
$button.Add_Click({ $window.Close() })

# Add components
$panel.Children.Add($textBlock)
$panel.Children.Add($button)
$window.Content = $panel

# Show the window (wait until manually closed)
$window.ShowDialog() | Out-Null
