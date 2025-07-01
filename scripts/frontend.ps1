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
$outputBox.Location = New-Object System.Drawing.Point(30, 30)
$outputBox.Size = New-Object System.Drawing.Size(320, 140)  # Height leaves space for button
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$outputBox.Anchor = "Top, Left, Right, Bottom"
$form.Controls.Add($outputBox)



# Confirm Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Confirm"
$button.Size = New-Object System.Drawing.Size(90, 30)
$button.Location = New-Object System.Drawing.Point(
    $form.ClientSize.Width - $button.Width - 30,
    $form.ClientSize.Height - $button.Height - 20
)
$button.Anchor = "Bottom, Right"
$form.Controls.Add($button)

# Add Docker checkbox
$checkboxDocker = New-Object System.Windows.Forms.CheckBox
$checkboxDocker.Text = "Install Docker Desktop"
$checkboxDocker.Location = New-Object System.Drawing.Point(30, 50)
$checkboxDocker.Size = New-Object System.Drawing.Size(200, 30)
$checkboxDocker.Checked = $false
$form.Controls.Add($checkboxDocker)

# Add MobaXterm checkbox
$checkboxMobaXterm = New-Object System.Windows.Forms.CheckBox
$checkboxMobaXterm.Text = "Install MobaXterm"
$checkboxMobaXterm.Location = New-Object System.Drawing.Point(30, 70)
$checkboxMobaXterm.Size = New-Object System.Drawing.Size(200, 30)
$checkboxMobaXterm.Checked = $false
$form.Controls.Add($checkboxMobaXterm)

# Move output box down a bit to fit new checkbox
$outputBox.Location = New-Object System.Drawing.Point(30, 110)

# Button click event
$button.Add_Click({
        $button.Enabled = $false  #
        try {
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

            # MobaXterm install
            if ($checkboxMobaXterm.Checked) {
                $outputBox.AppendText("Starting MobaXterm installation...`r`n")
                $mobaPath = Join-Path $scriptDir 'mobaxterminstall.ps1'
                if (Test-Path $mobaPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $mobaPath
                    $outputBox.AppendText([string]::Join("`r`n", $result))
                }
                else {
                    $outputBox.AppendText("ERROR: mobaxterminstall.ps1 not found at $mobaPath`r`n")
                }
            }

            if (-not $checkboxNode.Checked -and -not $checkboxDocker.Checked -and -not $checkboxMobaXterm.Checked) {
                $outputBox.AppendText("Nothing selected to install.`r`n")
            }
        }
        finally {
            $button.Enabled = $true  # Re-enable button at end, even if error
        }
    })

# Show the form
[void]$form.ShowDialog()