Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "1-Click Installer"
$form.Size = New-Object System.Drawing.Size(400, 280)
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(400, 280)

# Checkbox for Node.js
$checkboxNode = New-Object System.Windows.Forms.CheckBox
$checkboxNode.Text = "Install Node.js"
$checkboxNode.Location = New-Object System.Drawing.Point(30, 30)
$checkboxNode.Size = New-Object System.Drawing.Size(200, 30)
$checkboxNode.Checked = $true
$form.Controls.Add($checkboxNode)


# Output TextBox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(30, 110)
$outputBox.Size = New-Object System.Drawing.Size(320, 100)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$outputBox.Anchor = "Top, Left, Right, Bottom"
$form.Controls.Add($outputBox)



# Confirm Button - Fixed at bottom right
$button = New-Object System.Windows.Forms.Button
$button.Text = "Confirm"
$button.Size = New-Object System.Drawing.Size(90, 30)
$button.Location = New-Object System.Drawing.Point(280, 210)
$button.Anchor = "Bottom, Right"
$button.TabStop = $true
$button.TabIndex = 10
$form.Controls.Add($button)

# Adjust output box to not overlap with button
$outputBox.Size = New-Object System.Drawing.Size(320, 95)  # Reduced height to ensure no overlap

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

# Add Terraform checkbox
$checkboxTerraform = New-Object System.Windows.Forms.CheckBox
$checkboxTerraform.Text = "Install Terraform CLI"
$checkboxTerraform.Location = New-Object System.Drawing.Point(30, 90)
$checkboxTerraform.Size = New-Object System.Drawing.Size(200, 30)
$checkboxTerraform.Checked = $false
$form.Controls.Add($checkboxTerraform)

# Move output box down a bit to fit new checkbox
$outputBox.Location = New-Object System.Drawing.Point(30, 130)

# Adjust output box to not overlap with button
$outputBox.Size = New-Object System.Drawing.Size(320, 95)  # Reduced height to ensure no overlap

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

            # Terraform install
            if ($checkboxTerraform.Checked) {
                $outputBox.AppendText("Starting Terraform CLI installation...`r`n")
                $terraformPath = Join-Path $scriptDir 'terraforminstall.ps1'
                if (Test-Path $terraformPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $terraformPath
                    $outputBox.AppendText([string]::Join("`r`n", $result))
                }
                else {
                    $outputBox.AppendText("ERROR: terraforminstall.ps1 not found at $terraformPath`r`n")
                }
            }

            if (-not $checkboxNode.Checked -and -not $checkboxDocker.Checked -and -not $checkboxMobaXterm.Checked -and -not $checkboxTerraform.Checked) {
                $outputBox.AppendText("Nothing selected to install.`r`n")
            }
        }
        finally {
            $button.Enabled = $true  # Re-enable button at end, even if error
        }
    })

# Show the form
[void]$form.ShowDialog()