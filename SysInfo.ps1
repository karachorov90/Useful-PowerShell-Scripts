# 1. Gather the system information
$ComputerName   = $env:COMPUTERNAME
$IPAddress      = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' }).IPAddress -join ', '
$DefaultGateway = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -ExpandProperty NextHop) -join ', '
$CPU             = (Get-CimInstance Win32_Processor).Name
$RAM             = [Math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
$Disk            = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$Storage         = "[C:] " + [Math]::Round($Disk.Size / 1GB) + " GB Total (" + [Math]::Round($Disk.FreeSpace / 1GB) + " GB Free)"
$OS              = (Get-CimInstance Win32_OperatingSystem).Caption

# 2. Arrange the text inside a formatted string
$OutputText = @"
Computer Name: $ComputerName
IP Address: $IPAddress
Default Gateway: $DefaultGateway
CPU Info: $CPU
RAM Info: $RAM GB
Storage Info: $Storage
OS Info: $OS
"@

# 3. Load Windows Forms Assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 4. Create the Main Form window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "System Information Summary"
$Form.Size = New-Object System.Drawing.Size(500, 360)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

# 5. Create a Text Box to display the output neatly
$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Location = New-Object System.Drawing.Point(20, 20)
$TextBox.Size = New-Object System.Drawing.Size(440, 220)
$TextBox.MultiLine = $true
$TextBox.ScrollBars = "Vertical"
$TextBox.ReadOnly = $true
$TextBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$TextBox.Text = $OutputText
$Form.Controls.Add($TextBox)

# 6. Add a "Copy to Clipboard" Button
$CopyButton = New-Object System.Windows.Forms.Button
$CopyButton.Location = New-Object System.Drawing.Point(120, 260)
$CopyButton.Size = New-Object System.Drawing.Size(120, 35)
$CopyButton.Text = "Copy Info"
$CopyButton.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($TextBox.Text)
    [System.Windows.Forms.MessageBox]::Show("Copied to clipboard!", "Success", "OK", "Information")
})
$Form.Controls.Add($CopyButton)

# 7. Add a "Close" Button
$CloseButton = New-Object System.Windows.Forms.Button
$CloseButton.Location = New-Object System.Drawing.Point(260, 260)
$CloseButton.Size = New-Object System.Drawing.Size(120, 35)
$CloseButton.Text = "Close"
$CloseButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.Controls.Add($CloseButton)

# 8. Display the Form
$Form.ShowDialog() | Out-Null