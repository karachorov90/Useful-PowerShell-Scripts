# Ensure the Windows Forms assembly is loaded
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 1. Gather Windows OS Information
$OS = Get-CimInstance Win32_OperatingSystem
$ComputerInfo = Get-ComputerInfo

# Extract specific details
$OSName        = $OS.Caption
$OSVersion     = $OS.Version
$Architecture  = $OS.OSArchitecture
$BuildNumber   = $OS.BuildNumber
$DisplayVersion= $ComputerInfo.WindowsDisplayVersion # e.g., 23H2 or 24H2
$InstallDate   = $OS.InstallDate.ToString("yyyy-MM-dd HH:mm:ss")
$RegisteredUser= $OS.RegisteredUser

# 2. Build the Windows GUI Window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Windows OS Information"
$Form.Size = New-Object System.Drawing.Size(460, 340)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)

# Helper function to generate labels efficiently
function Add-InfoRow ($LabelText, $ValueText, $TopPosition) {
    # Title Label
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $LabelText
    $Label.Location = New-Object System.Drawing.Point(20, $TopPosition)
    $Label.Size = New-Object System.Drawing.Size(130, 20)
    $Label.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $Form.Controls.Add($Label)

    # Value Label
    $Value = New-Object System.Windows.Forms.Label
    $Value.Text = $ValueText
    $Value.Location = New-Object System.Drawing.Point(160, $TopPosition)
    $Value.Size = New-Object System.Drawing.Size(260, 20)
    $Value.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $Form.Controls.Add($Value)
}

# 3. Populate the Form with data rows
Add-InfoRow "OS Name:"          $OSName 40
Add-InfoRow "Version:"          $OSVersion 75
Add-InfoRow "Display Version:"  $DisplayVersion 110
Add-InfoRow "Build Number:"     $BuildNumber 145
Add-InfoRow "Architecture:"     $Architecture 180
Add-InfoRow "Installation Date:" $InstallDate 215
Add-InfoRow "Registered Owner:" $RegisteredUser 250

# 4. Show the Window
$Form.ShowDialog() | Out-Null