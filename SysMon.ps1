# Load the built-in Windows UI framework (Windows Forms)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Create main UI Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Real-Time System Monitor"
$form.Size = New-Object System.Drawing.Size(400, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30) # Dark theme

# Font styles
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$fontLabel = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

# --- Helper Function for Labels ---
function Create-Label($text, $x, $y, $w, $h, $font, $color=[System.Drawing.Color]::White) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($w, $h)
    $label.Font = $font
    $label.ForeColor = $color
    $form.Controls.Add($label)
    return $label
}

# --- Helper Function for Progress Bars ---
function Create-ProgressBar($x, $y, $w, $h) {
    $pb = New-Object System.Windows.Forms.ProgressBar
    $pb.Location = New-Object System.Drawing.Point($x, $y)
    $pb.Size = New-Object System.Drawing.Size($w, $h)
    $pb.Minimum = 0
    $pb.Maximum = 100
    $pb.Value = 0
    $form.Controls.Add($pb)
    return $pb
}

# --- UI Layout Elements ---
Create-Label "SYSTEM PERFORMANCE" 20 15 350 30 $fontTitle

# CPU Section
Create-Label "CPU Usage:" 20 60 150 20 $fontLabel
$lblCpuVal = Create-Label "0%" 300 60 60 20 $fontLabel
$pbCpu = Create-ProgressBar 20 85 340 20

# RAM Section
Create-Label "Available Memory (RAM):" 20 120 200 20 $fontLabel
$lblRamVal = Create-Label "0 MB" 260 120 100 20 $fontLabel
$pbRam = Create-ProgressBar 20 145 340 20

# Disk Section
Create-Label "Disk Free Space (C:):" 20 205 200 20 $fontLabel
$lblDiskVal = Create-Label "0%" 300 205 60 20 $fontLabel
$pbDisk = Create-ProgressBar 20 230 340 20

# --- Live Data Metrics Collection ---
# Initialize Performance Counters for instant fetching
$cpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
$ramCounter = New-Object System.Diagnostics.PerformanceCounter("Memory", "Available MBytes")
# Warm up CPU counter
[void]$cpuCounter.NextValue()

# Get total RAM size to calculate utilization percentage
$totalRamBytes = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum
$totalRamMB = [Math]::Round($totalRamBytes / 1MB)

# --- Real-Time Update Timer Loop ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000 # Update every 1000ms (1 second)

$timer.Add_Tick({
    # 1. Update CPU
    $cpuUsage = [Math]::Round($cpuCounter.NextValue())
    $pbCpu.Value = $cpuUsage
    $lblCpuVal.Text = "$cpuUsage%"
    
    # 2. Update RAM
    $availRamMB = $ramCounter.NextValue()
    $usedRamPercent = [Math]::Round((($totalRamMB - $availRamMB) / $totalRamMB) * 100)
    $pbRam.Value = $usedRamPercent
    $lblRamVal.Text = "$([Math]::Round($availRamMB)) MB Free"

    # 3. Update Disk (C: Drive)
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskFreePercent = [Math]::Round(($disk.FreeSpace / $disk.Size) * 100)
    $diskUsedPercent = 100 - $diskFreePercent
    $pbDisk.Value = $diskUsedPercent
    $lblDiskVal.Text = "$diskFreePercent% Free"
})

# Start tracking when form loads
$form.Add_Load({ $timer.Start() })
$form.Add_FormClosing({ $timer.Stop() })

# Display the application UI window
[System.Windows.Forms.Application]::Run($form)