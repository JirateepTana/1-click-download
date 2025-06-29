Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "1-Click Installer"
$form.Size = New-Object System.Drawing.Size(400, 220)
$form.StartPosition = "CenterScreen"

# Checkbox for Node.js
$checkboxNode = New-Object System.Windows.Forms.CheckBox
$checkboxNode.Text = "Install Node.js"
$checkboxNode.Location = New-Object System.Drawing.Point(30, 30)
$checkboxNode.Size = New-Object System.Drawing.Size(200, 30)
$checkboxNode.Checked = $true
$form.Controls.Add($checkboxNode)

# Output TextBox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(30, 70)
$outputBox.Size = New-Object System.Drawing.Size(320, 60)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

# Confirm Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Confirm"
$button.Location = New-Object System.Drawing.Point(260, 140)
$button.Size = New-Object System.Drawing.Size(90, 30)
$form.Controls.Add($button)

# Add Docker checkbox
$checkboxDocker = New-Object System.Windows.Forms.CheckBox
$checkboxDocker.Text = "Install Docker Desktop"
$checkboxDocker.Location = New-Object System.Drawing.Point(30, 50)
$checkboxDocker.Size = New-Object System.Drawing.Size(200, 30)
$checkboxDocker.Checked = $false
$form.Controls.Add($checkboxDocker)

# Move output box down a bit
$outputBox.Location = New-Object System.Drawing.Point(30, 90)

# Button click event
$button.Add_Click({
        $outputBox.Clear()
        $scriptPath = $MyInvocation.MyCommand.Path
        if (-not $scriptPath) {
            $scriptDir = Get-Location
        }
        else {
            $scriptDir = Split-Path -Parent $scriptPath
        }

        # Node.js install
        if ($checkboxNode.Checked) {
            $outputBox.AppendText("Starting Node.js installation...`r`n")
            $backendPath = Join-Path $scriptDir 'Backend.ps1'
            if (Test-Path $backendPath) {
                $result = powershell -NoLogo -ExecutionPolicy Bypass -File $backendPath
                $outputBox.AppendText([string]::Join("`r`n", $result))
            }
            else {
                $outputBox.AppendText("ERROR: Backend.ps1 not found at $backendPath`r`n")
            }
        }

        # Docker install
        if ($checkboxDocker.Checked) {
            $outputBox.AppendText("Starting Docker Desktop installation...`r`n")
            $dockerPath = Join-Path $scriptDir 'dockerinstall.ps1'
            if (Test-Path $dockerPath) {
                $result = powershell -NoLogo -ExecutionPolicy Bypass -File $dockerPath
                $outputBox.AppendText([string]::Join("`r`n", $result))
            }
            else {
                $outputBox.AppendText("ERROR: dockerinstall.ps1 not found at $dockerPath`r`n")
            }
        }

        if (-not $checkboxNode.Checked -and -not $checkboxDocker.Checked) {
            $outputBox.AppendText("Nothing selected to install.`r`n")
        }
    })

# Show the form
[void]$form.ShowDialog()