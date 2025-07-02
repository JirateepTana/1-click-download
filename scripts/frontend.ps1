Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "1-Click Installer"
$form.Size = New-Object System.Drawing.Size(450, 360)
$form.MinimumSize = New-Object System.Drawing.Size(450, 360)
$form.StartPosition = "CenterScreen"

# Create dropdown button at top-right with categories
$dropdownButton = New-Object System.Windows.Forms.ToolStripDropDownButton
$dropdownButton.Text = "Categories"

# Add dropdown items
$items = @("DATS", "IT", "Cyber", "HR") | ForEach-Object {
    $item = New-Object System.Windows.Forms.ToolStripMenuItem $_
    $item
}
$items | ForEach-Object { $dropdownButton.DropDownItems.Add($_) | Out-Null }

# Create a ToolStrip to hold the dropdown
$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.Dock = "Top"
$toolStrip.GripStyle = "Hidden"
$toolStrip.Items.Add($dropdownButton) | Out-Null
$toolStrip.Padding = New-Object System.Windows.Forms.Padding(0, 0, 10, 0)
$toolStrip.Anchor = "Top, Right"
$toolStrip.LayoutStyle = "Flow"
$form.Controls.Add($toolStrip)

# Label
$categoryLabel = New-Object System.Windows.Forms.Label
$categoryLabel.Text = "Quick Configuration Categories:"
$categoryLabel.Location = New-Object System.Drawing.Point(30, 40)
$categoryLabel.Size = New-Object System.Drawing.Size(300, 20)
$categoryLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($categoryLabel)

# Category Buttons
$btnDevOps = New-Object System.Windows.Forms.Button
$btnDevOps.Text = "DevOps"
$btnDevOps.Location = New-Object System.Drawing.Point(30, 65)
$btnDevOps.Size = New-Object System.Drawing.Size(60, 25)
$btnDevOps.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($btnDevOps)

$btnFullStack = New-Object System.Windows.Forms.Button
$btnFullStack.Text = "FullStack"
$btnFullStack.Location = New-Object System.Drawing.Point(100, 65)
$btnFullStack.Size = New-Object System.Drawing.Size(70, 25)
$btnFullStack.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($btnFullStack)

$btnFrontend = New-Object System.Windows.Forms.Button
$btnFrontend.Text = "Frontend"
$btnFrontend.Location = New-Object System.Drawing.Point(180, 65)
$btnFrontend.Size = New-Object System.Drawing.Size(70, 25)
$btnFrontend.BackColor = [System.Drawing.Color]::LightCoral
$form.Controls.Add($btnFrontend)

$btnClearAll = New-Object System.Windows.Forms.Button
$btnClearAll.Text = "Clear"
$btnClearAll.Location = New-Object System.Drawing.Point(270, 65)
$btnClearAll.Size = New-Object System.Drawing.Size(50, 25)
$btnClearAll.BackColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($btnClearAll)

# Checkboxes
$checkboxNode = New-Object System.Windows.Forms.CheckBox
$checkboxNode.Text = "Install Node.js"
$checkboxNode.Location = New-Object System.Drawing.Point(30, 100)
$checkboxNode.Size = New-Object System.Drawing.Size(200, 30)
$checkboxNode.Checked = $true
$form.Controls.Add($checkboxNode)

$checkboxDocker = New-Object System.Windows.Forms.CheckBox
$checkboxDocker.Text = "Install Docker Desktop"
$checkboxDocker.Location = New-Object System.Drawing.Point(30, 125)
$checkboxDocker.Size = New-Object System.Drawing.Size(200, 30)
$checkboxDocker.Checked = $false
$form.Controls.Add($checkboxDocker)

$checkboxMobaXterm = New-Object System.Windows.Forms.CheckBox
$checkboxMobaXterm.Text = "Install MobaXterm"
$checkboxMobaXterm.Location = New-Object System.Drawing.Point(30, 150)
$checkboxMobaXterm.Size = New-Object System.Drawing.Size(200, 30)
$checkboxMobaXterm.Checked = $false
$form.Controls.Add($checkboxMobaXterm)

$checkboxTerraform = New-Object System.Windows.Forms.CheckBox
$checkboxTerraform.Text = "Install Terraform CLI"
$checkboxTerraform.Location = New-Object System.Drawing.Point(30, 175)
$checkboxTerraform.Size = New-Object System.Drawing.Size(200, 30)
$checkboxTerraform.Checked = $false
$form.Controls.Add($checkboxTerraform)

$checkboxVSCode = New-Object System.Windows.Forms.CheckBox
$checkboxVSCode.Text = "Install Visual Studio Code"
$checkboxVSCode.Location = New-Object System.Drawing.Point(30, 200)
$checkboxVSCode.Size = New-Object System.Drawing.Size(250, 30)
$checkboxVSCode.Checked = $false
$form.Controls.Add($checkboxVSCode)

# Output TextBox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(30, 240)
$outputBox.Size = New-Object System.Drawing.Size(380, 50)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$outputBox.Anchor = "Top, Left, Right, Bottom"
$form.Controls.Add($outputBox)

# Confirm Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Confirm"
$button.Size = New-Object System.Drawing.Size(90, 30)
$button.Location = New-Object System.Drawing.Point(330, 290)
$button.Anchor = "Bottom, Right"
$form.Controls.Add($button)

# Category button actions
$btnDevOps.Add_Click({
        $checkboxNode.Checked = $false
        $checkboxDocker.Checked = $true
        $checkboxMobaXterm.Checked = $true
        $checkboxTerraform.Checked = $true
        $checkboxVSCode.Checked = $true
        $outputBox.AppendText("Selected DevOps category: Docker, Terraform, MobaXterm, VS Code`r`n")
    })
$btnFullStack.Add_Click({
        $checkboxNode.Checked = $true
        $checkboxDocker.Checked = $true
        $checkboxMobaXterm.Checked = $false
        $checkboxTerraform.Checked = $false
        $checkboxVSCode.Checked = $true
        $outputBox.AppendText("Selected FullStack category: Node.js, Docker, VS Code`r`n")
    })
$btnFrontend.Add_Click({
        $checkboxNode.Checked = $true
        $checkboxDocker.Checked = $false
        $checkboxMobaXterm.Checked = $false
        $checkboxTerraform.Checked = $false
        $checkboxVSCode.Checked = $true
        $outputBox.AppendText("Selected Frontend category: Node.js, VS Code`r`n")
    })
$btnClearAll.Add_Click({
        $checkboxNode.Checked = $false
        $checkboxDocker.Checked = $false
        $checkboxMobaXterm.Checked = $false
        $checkboxTerraform.Checked = $false
        $checkboxVSCode.Checked = $false
        $outputBox.AppendText("Cleared all selections`r`n")
    })

# Confirm button action
$button.Add_Click({
        $button.Enabled = $false
        try {
            $outputBox.Clear()
            $scriptPath = $MyInvocation.MyCommand.Path
            if (-not $scriptPath) {
                $scriptDir = Get-Location
            }
            else {
                $scriptDir = Split-Path -Parent $scriptPath
            }

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

            if ($checkboxVSCode.Checked) {
                $outputBox.AppendText("Starting VS Code installation...`r`n")
                $vscodePath = Join-Path $scriptDir 'vscodeinstall.ps1'
                if (Test-Path $vscodePath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $vscodePath
                    $outputBox.AppendText([string]::Join("`r`n", $result))
                }
                else {
                    $outputBox.AppendText("ERROR: vscodeinstall.ps1 not found at $vscodePath`r`n")
                }
            }

            if (-not ($checkboxNode.Checked -or $checkboxDocker.Checked -or $checkboxMobaXterm.Checked -or $checkboxTerraform.Checked -or $checkboxVSCode.Checked)) {
                $outputBox.AppendText("Nothing selected to install.`r`n")
            }

        }
        finally {
            $button.Enabled = $true
        }
    })

# Show the form
[void]$form.ShowDialog()
