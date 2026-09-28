# Load the Windows Forms assembly for the UI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- GATHER MICROSOFT OFFICE INFORMATION ---
$OfficeInfo = [ordered]@{
    "Name"        = "Not Detected"
    "Version"     = "N/A"
    "Path"        = "N/A"
    "Bitness"     = "N/A"
    "InstallType" = "N/A"
}

# 1. Check Registry for ClickToRun (Modern Office 365 / 2019 / 2021 / 2024)
$ctrKey = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
if (Test-Path $ctrKey) {
    $OfficeInfo["Name"] = Get-ItemPropertyValue -Path $ctrKey -Name "ProductReleaseIds" -ErrorAction SilentlyContinue
    $OfficeInfo["Version"] = Get-ItemPropertyValue -Path $ctrKey -Name "VersionToReport" -ErrorAction SilentlyContinue
    $OfficeInfo["Path"] = Get-ItemPropertyValue -Path $ctrKey -Name "ClientFolder" -ErrorAction SilentlyContinue
    $OfficeInfo["Bitness"] = Get-ItemPropertyValue -Path $ctrKey -Name "Platform" -ErrorAction SilentlyContinue
    $OfficeInfo["InstallType"] = "ClickToRun (Modern)"
} 
# 2. Fallback to MSI-based classic installations (Office 2016 and older)
else {
    $wordKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Winword.exe"
    if (Test-Path $wordKey) {
        $path = Get-ItemPropertyValue -Path $wordKey -Name "(Default)" -ErrorAction SilentlyContinue
        if ($path) {
            $OfficeInfo["Path"] = Split-Path $path
            $fileVersion = (Get-Item $path).VersionInfo.FileVersion
            $OfficeInfo["Version"] = $fileVersion
            $OfficeInfo["InstallType"] = "MSI (Classic)"
            
            # Determine Name from File Version
            if ($fileVersion -like "16.0*") { $OfficeInfo["Name"] = "Microsoft Office 2016" }
            elseif ($fileVersion -like "15.0*") { $OfficeInfo["Name"] = "Microsoft Office 2013" }
            elseif ($fileVersion -like "14.0*") { $OfficeInfo["Name"] = "Microsoft Office 2010" }
            
            # Determine Bitness
            if ($path -like "*Program Files (x86)*") { $OfficeInfo["Bitness"] = "x86" } else { $OfficeInfo["Bitness"] = "x64" }
        }
    }
}

# --- BUILD THE WINDOWS UI ---
# Create Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Microsoft Office Information"
$form.Size = New-Object System.Drawing.Size(460, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Installed Office Details"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(20, 15)
$titleLabel.Size = New-Object System.Drawing.Size(400, 30)
$form.Controls.Add($titleLabel)

# Textbox to cleanly display data (and allow copying)
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ReadOnly = $true
$textBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$textBox.Location = New-Object System.Drawing.Point(20, 60)
$textBox.Size = New-Object System.Drawing.Size(400, 150)
$textBox.ScrollBars = "Vertical"

# Format string payload for textbox
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("Suite Name   : $($OfficeInfo['Name'])")
[void]$sb.AppendLine("Version      : $($OfficeInfo['Version'])")
[void]$sb.AppendLine("Architecture : $($OfficeInfo['Bitness'])")
[void]$sb.AppendLine("Install Type : $($OfficeInfo['InstallType'])")
[void]$sb.AppendLine("Install Path : $($OfficeInfo['Path'])")
$textBox.Text = $sb.ToString()
$form.Controls.Add($textBox)

# OK Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(340, 230)
$okButton.Size = New-Object System.Drawing.Size(80, 30)
$okButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton

# Display UI Window
$form.ShowDialog() | Out-Null
$form.Dispose()