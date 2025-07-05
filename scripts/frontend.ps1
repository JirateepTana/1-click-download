Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "1-Click Installer"
$form.Size = New-Object System.Drawing.Size(550, 650)
$form.MinimumSize = New-Object System.Drawing.Size(550, 650)
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

# Checkboxes - Organized by Installation Priority
# === TIER 1: CORE REQUIREMENTS ===
$coreLabel = New-Object System.Windows.Forms.Label
$coreLabel.Text = "Core Requirements (Install First):"
$coreLabel.Location = New-Object System.Drawing.Point(30, 100)
$coreLabel.Size = New-Object System.Drawing.Size(300, 20)
$coreLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$coreLabel.ForeColor = [System.Drawing.Color]::DarkGreen
$form.Controls.Add($coreLabel)

$checkboxNode = New-Object System.Windows.Forms.CheckBox
$checkboxNode.Text = "Node.js (Required for CLI tools)"
$checkboxNode.Location = New-Object System.Drawing.Point(30, 125)
$checkboxNode.Size = New-Object System.Drawing.Size(250, 20)
$checkboxNode.Checked = $true
$form.Controls.Add($checkboxNode)

$checkboxGit = New-Object System.Windows.Forms.CheckBox
$checkboxGit.Text = "Git (Required for GitHub Desktop, SourceTree)"
$checkboxGit.Location = New-Object System.Drawing.Point(30, 145)
$checkboxGit.Size = New-Object System.Drawing.Size(300, 20)
$checkboxGit.Checked = $true
$form.Controls.Add($checkboxGit)

# === TIER 2: DEVELOPMENT TOOLS ===
$devLabel = New-Object System.Windows.Forms.Label
$devLabel.Text = "Development Tools:"
$devLabel.Location = New-Object System.Drawing.Point(30, 175)
$devLabel.Size = New-Object System.Drawing.Size(300, 20)
$devLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$devLabel.ForeColor = [System.Drawing.Color]::DarkBlue
$form.Controls.Add($devLabel)

$checkboxVSCode = New-Object System.Windows.Forms.CheckBox
$checkboxVSCode.Text = "Visual Studio Code"
$checkboxVSCode.Location = New-Object System.Drawing.Point(30, 200)
$checkboxVSCode.Size = New-Object System.Drawing.Size(200, 20)
$checkboxVSCode.Checked = $false
$form.Controls.Add($checkboxVSCode)

$checkboxDocker = New-Object System.Windows.Forms.CheckBox
$checkboxDocker.Text = "Docker Desktop"
$checkboxDocker.Location = New-Object System.Drawing.Point(280, 200)
$checkboxDocker.Size = New-Object System.Drawing.Size(150, 20)
$checkboxDocker.Checked = $false
$form.Controls.Add($checkboxDocker)

# === TIER 3: CLI TOOLS (Node.js dependent) ===
$cliLabel = New-Object System.Windows.Forms.Label
$cliLabel.Text = "CLI Tools (Requires Node.js):"
$cliLabel.Location = New-Object System.Drawing.Point(30, 230)
$cliLabel.Size = New-Object System.Drawing.Size(300, 20)
$cliLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$cliLabel.ForeColor = [System.Drawing.Color]::DarkOrange
$form.Controls.Add($cliLabel)

$checkboxAngular = New-Object System.Windows.Forms.CheckBox
$checkboxAngular.Text = "Angular CLI"
$checkboxAngular.Location = New-Object System.Drawing.Point(30, 255)
$checkboxAngular.Size = New-Object System.Drawing.Size(120, 20)
$checkboxAngular.Checked = $false
$form.Controls.Add($checkboxAngular)

$checkboxNest = New-Object System.Windows.Forms.CheckBox
$checkboxNest.Text = "Nest CLI"
$checkboxNest.Location = New-Object System.Drawing.Point(160, 255)
$checkboxNest.Size = New-Object System.Drawing.Size(100, 20)
$checkboxNest.Checked = $false
$form.Controls.Add($checkboxNest)

$checkboxTerraform = New-Object System.Windows.Forms.CheckBox
$checkboxTerraform.Text = "Terraform CLI"
$checkboxTerraform.Location = New-Object System.Drawing.Point(280, 255)
$checkboxTerraform.Size = New-Object System.Drawing.Size(120, 20)
$checkboxTerraform.Checked = $false
$form.Controls.Add($checkboxTerraform)

# === TIER 4: INDEPENDENT TOOLS ===
$toolsLabel = New-Object System.Windows.Forms.Label
$toolsLabel.Text = "Application Tools:"
$toolsLabel.Location = New-Object System.Drawing.Point(30, 285)
$toolsLabel.Size = New-Object System.Drawing.Size(300, 20)
$toolsLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$toolsLabel.ForeColor = [System.Drawing.Color]::DarkRed
$form.Controls.Add($toolsLabel)

$checkboxMobaXterm = New-Object System.Windows.Forms.CheckBox
$checkboxMobaXterm.Text = "MobaXterm"
$checkboxMobaXterm.Location = New-Object System.Drawing.Point(30, 310)
$checkboxMobaXterm.Size = New-Object System.Drawing.Size(100, 20)
$checkboxMobaXterm.Checked = $false
$form.Controls.Add($checkboxMobaXterm)

$checkboxPutty = New-Object System.Windows.Forms.CheckBox
$checkboxPutty.Text = "PuTTY"
$checkboxPutty.Location = New-Object System.Drawing.Point(140, 310)
$checkboxPutty.Size = New-Object System.Drawing.Size(80, 20)
$checkboxPutty.Checked = $false
$form.Controls.Add($checkboxPutty)

$checkboxPostman = New-Object System.Windows.Forms.CheckBox
$checkboxPostman.Text = "Postman"
$checkboxPostman.Location = New-Object System.Drawing.Point(230, 310)
$checkboxPostman.Size = New-Object System.Drawing.Size(80, 20)
$checkboxPostman.Checked = $false
$form.Controls.Add($checkboxPostman)

$checkboxDBeaver = New-Object System.Windows.Forms.CheckBox
$checkboxDBeaver.Text = "DBeaver"
$checkboxDBeaver.Location = New-Object System.Drawing.Point(320, 310)
$checkboxDBeaver.Size = New-Object System.Drawing.Size(80, 20)
$checkboxDBeaver.Checked = $false
$form.Controls.Add($checkboxDBeaver)

$checkboxZoom = New-Object System.Windows.Forms.CheckBox
$checkboxZoom.Text = "Zoom"
$checkboxZoom.Location = New-Object System.Drawing.Point(30, 335)
$checkboxZoom.Size = New-Object System.Drawing.Size(80, 20)
$checkboxZoom.Checked = $false
$form.Controls.Add($checkboxZoom)

$checkboxDiscord = New-Object System.Windows.Forms.CheckBox
$checkboxDiscord.Text = "Discord"
$checkboxDiscord.Location = New-Object System.Drawing.Point(120, 335)
$checkboxDiscord.Size = New-Object System.Drawing.Size(80, 20)
$checkboxDiscord.Checked = $false
$form.Controls.Add($checkboxDiscord)

# === TIER 5: GIT-DEPENDENT TOOLS ===
$gitLabel = New-Object System.Windows.Forms.Label
$gitLabel.Text = "Git-based Tools (Requires Git):"
$gitLabel.Location = New-Object System.Drawing.Point(30, 365)
$gitLabel.Size = New-Object System.Drawing.Size(300, 20)
$gitLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$gitLabel.ForeColor = [System.Drawing.Color]::DarkMagenta
$form.Controls.Add($gitLabel)

$checkboxSourceTree = New-Object System.Windows.Forms.CheckBox
$checkboxSourceTree.Text = "SourceTree"
$checkboxSourceTree.Location = New-Object System.Drawing.Point(30, 390)
$checkboxSourceTree.Size = New-Object System.Drawing.Size(120, 20)
$checkboxSourceTree.Checked = $false
$form.Controls.Add($checkboxSourceTree)

$checkboxGitHub = New-Object System.Windows.Forms.CheckBox
$checkboxGitHub.Text = "GitHub Desktop"
$checkboxGitHub.Location = New-Object System.Drawing.Point(160, 390)
$checkboxGitHub.Size = New-Object System.Drawing.Size(140, 20)
$checkboxGitHub.Checked = $false
$form.Controls.Add($checkboxGitHub)

# Output TextBox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(30, 430)
$outputBox.Size = New-Object System.Drawing.Size(480, 120)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$outputBox.Anchor = "Top, Left, Right, Bottom"
$form.Controls.Add($outputBox)

# Confirm Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Confirm Installation"
$button.Size = New-Object System.Drawing.Size(150, 30)
$button.Location = New-Object System.Drawing.Point(360, 560)
$button.Anchor = "Bottom, Right"
$form.Controls.Add($button)

# Category button actions
$btnDevOps.Add_Click({
        # Core Requirements
        $checkboxNode.Checked = $true
        $checkboxGit.Checked = $true
        # Development Tools
        $checkboxVSCode.Checked = $true
        $checkboxDocker.Checked = $true
        # CLI Tools
        $checkboxTerraform.Checked = $true
        # Application Tools
        $checkboxMobaXterm.Checked = $true
        $checkboxPutty.Checked = $true
        # Git-based Tools
        $checkboxSourceTree.Checked = $true
        $checkboxGitHub.Checked = $true
        $outputBox.AppendText("Selected DevOps category: Core tools + Docker + Terraform + SSH tools + Git tools`r`n")
    })

$btnFullStack.Add_Click({
        # Core Requirements
        $checkboxNode.Checked = $true
        $checkboxGit.Checked = $true
        # Development Tools
        $checkboxVSCode.Checked = $true
        $checkboxDocker.Checked = $true
        # CLI Tools
        $checkboxAngular.Checked = $true
        $checkboxNest.Checked = $true
        # Application Tools
        $checkboxPostman.Checked = $true
        $checkboxDBeaver.Checked = $true
        # Git-based Tools
        $checkboxGitHub.Checked = $true
        $outputBox.AppendText("Selected FullStack category: Node.js + Git + VS Code + Docker + Angular/Nest CLI + API/DB tools`r`n")
    })

$btnFrontend.Add_Click({
        # Core Requirements
        $checkboxNode.Checked = $true
        $checkboxGit.Checked = $true
        # Development Tools
        $checkboxVSCode.Checked = $true
        # CLI Tools
        $checkboxAngular.Checked = $true
        # Application Tools
        $checkboxPostman.Checked = $true
        # Git-based Tools
        $checkboxGitHub.Checked = $true
        $outputBox.AppendText("Selected Frontend category: Node.js + Git + VS Code + Angular CLI + Postman + GitHub Desktop`r`n")
    })

$btnClearAll.Add_Click({
        # Core Requirements
        $checkboxNode.Checked = $false
        $checkboxGit.Checked = $false
        # Development Tools
        $checkboxVSCode.Checked = $false
        $checkboxDocker.Checked = $false
        # CLI Tools
        $checkboxAngular.Checked = $false
        $checkboxNest.Checked = $false
        $checkboxTerraform.Checked = $false
        # Application Tools
        $checkboxMobaXterm.Checked = $false
        $checkboxPutty.Checked = $false
        $checkboxPostman.Checked = $false
        $checkboxDBeaver.Checked = $false
        $checkboxZoom.Checked = $false
        $checkboxDiscord.Checked = $false
        # Git-based Tools
        $checkboxSourceTree.Checked = $false
        $checkboxGitHub.Checked = $false
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

            $outputBox.AppendText("=== STARTING INSTALLATION IN PRIORITY ORDER ===`r`n`r`n")

            # TIER 1: CORE REQUIREMENTS (Must install first)
            $outputBox.AppendText("--- TIER 1: CORE REQUIREMENTS ---`r`n")
            
            if ($checkboxNode.Checked) {
                $outputBox.AppendText("Installing Node.js (Required for CLI tools)...`r`n")
                $backendPath = Join-Path $scriptDir 'Backend.ps1'
                if (Test-Path $backendPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $backendPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: Backend.ps1 not found at $backendPath`r`n")
                }
            }

            if ($checkboxGit.Checked) {
                $outputBox.AppendText("Installing Git (Required for GitHub Desktop, SourceTree)...`r`n")
                $gitPath = Join-Path $scriptDir 'gitinstall.ps1'
                if (Test-Path $gitPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $gitPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: gitinstall.ps1 not found at $gitPath`r`n")
                }
            }

            # TIER 2: DEVELOPMENT TOOLS
            $outputBox.AppendText("`r`n--- TIER 2: DEVELOPMENT TOOLS ---`r`n")
            
            if ($checkboxVSCode.Checked) {
                $outputBox.AppendText("Installing Visual Studio Code...`r`n")
                $vscodePath = Join-Path $scriptDir 'vscodeinstall.ps1'
                if (Test-Path $vscodePath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $vscodePath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: vscodeinstall.ps1 not found at $vscodePath`r`n")
                }
            }

            if ($checkboxDocker.Checked) {
                $outputBox.AppendText("Installing Docker Desktop...`r`n")
                $dockerPath = Join-Path $scriptDir 'dockerinstall.ps1'
                if (Test-Path $dockerPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $dockerPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: dockerinstall.ps1 not found at $dockerPath`r`n")
                }
            }

            # TIER 3: CLI TOOLS (Node.js dependent)
            $outputBox.AppendText("`r`n--- TIER 3: CLI TOOLS (Node.js dependent) ---`r`n")
            
            if ($checkboxAngular.Checked) {
                $outputBox.AppendText("Installing Angular CLI...`r`n")
                $angularPath = Join-Path $scriptDir 'angularcliinstall.ps1'
                if (Test-Path $angularPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $angularPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: angularcliinstall.ps1 not found at $angularPath`r`n")
                }
            }

            if ($checkboxNest.Checked) {
                $outputBox.AppendText("Installing Nest CLI...`r`n")
                $nestPath = Join-Path $scriptDir 'nestcliinstall.ps1'
                if (Test-Path $nestPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $nestPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: nestcliinstall.ps1 not found at $nestPath`r`n")
                }
            }

            if ($checkboxTerraform.Checked) {
                $outputBox.AppendText("Installing Terraform CLI...`r`n")
                $terraformPath = Join-Path $scriptDir 'terraforminstall.ps1'
                if (Test-Path $terraformPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $terraformPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: terraforminstall.ps1 not found at $terraformPath`r`n")
                }
            }

            # TIER 4: INDEPENDENT TOOLS
            $outputBox.AppendText("`r`n--- TIER 4: APPLICATION TOOLS ---`r`n")
            
            if ($checkboxMobaXterm.Checked) {
                $outputBox.AppendText("Installing MobaXterm...`r`n")
                $mobaPath = Join-Path $scriptDir 'mobaxterminstall.ps1'
                if (Test-Path $mobaPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $mobaPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: mobaxterminstall.ps1 not found at $mobaPath`r`n")
                }
            }

            if ($checkboxPutty.Checked) {
                $outputBox.AppendText("Installing PuTTY...`r`n")
                $puttyPath = Join-Path $scriptDir 'puttyinstall.ps1'
                if (Test-Path $puttyPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $puttyPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: puttyinstall.ps1 not found at $puttyPath`r`n")
                }
            }

            if ($checkboxPostman.Checked) {
                $outputBox.AppendText("Installing Postman...`r`n")
                $postmanPath = Join-Path $scriptDir 'postmaninstall.ps1'
                if (Test-Path $postmanPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $postmanPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: postmaninstall.ps1 not found at $postmanPath`r`n")
                }
            }

            if ($checkboxDBeaver.Checked) {
                $outputBox.AppendText("Installing DBeaver...`r`n")
                $dbeaverPath = Join-Path $scriptDir 'dbeaverinstall.ps1'
                if (Test-Path $dbeaverPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $dbeaverPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: dbeaverinstall.ps1 not found at $dbeaverPath`r`n")
                }
            }

            if ($checkboxZoom.Checked) {
                $outputBox.AppendText("Installing Zoom...`r`n")
                $zoomPath = Join-Path $scriptDir 'zoominstall.ps1'
                if (Test-Path $zoomPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $zoomPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: zoominstall.ps1 not found at $zoomPath`r`n")
                }
            }

            if ($checkboxDiscord.Checked) {
                $outputBox.AppendText("Installing Discord...`r`n")
                $discordPath = Join-Path $scriptDir 'discordinstall.ps1'
                if (Test-Path $discordPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $discordPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: discordinstall.ps1 not found at $discordPath`r`n")
                }
            }

            # TIER 5: GIT-DEPENDENT TOOLS (Install last)
            $outputBox.AppendText("`r`n--- TIER 5: GIT-DEPENDENT TOOLS ---`r`n")
            
            if ($checkboxSourceTree.Checked) {
                $outputBox.AppendText("Installing SourceTree...`r`n")
                $sourcetreePath = Join-Path $scriptDir 'sourcetreeinstall.ps1'
                if (Test-Path $sourcetreePath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $sourcetreePath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: sourcetreeinstall.ps1 not found at $sourcetreePath`r`n")
                }
            }

            if ($checkboxGitHub.Checked) {
                $outputBox.AppendText("Installing GitHub Desktop...`r`n")
                $githubPath = Join-Path $scriptDir 'githubdesktopinstall.ps1'
                if (Test-Path $githubPath) {
                    $result = powershell -NoLogo -ExecutionPolicy Bypass -File $githubPath
                    $outputBox.AppendText([string]::Join("`r`n", $result) + "`r`n")
                }
                else {
                    $outputBox.AppendText("ERROR: githubdesktopinstall.ps1 not found at $githubPath`r`n")
                }
            }

            # Check if nothing was selected
            $anySelected = $checkboxNode.Checked -or $checkboxGit.Checked -or $checkboxVSCode.Checked -or $checkboxDocker.Checked -or $checkboxAngular.Checked -or $checkboxNest.Checked -or $checkboxTerraform.Checked -or $checkboxMobaXterm.Checked -or $checkboxPutty.Checked -or $checkboxPostman.Checked -or $checkboxDBeaver.Checked -or $checkboxZoom.Checked -or $checkboxDiscord.Checked -or $checkboxSourceTree.Checked -or $checkboxGitHub.Checked
            
            if (-not $anySelected) {
                $outputBox.AppendText("Nothing selected to install.`r`n")
            }
            else {
                $outputBox.AppendText("`r`n=== INSTALLATION PROCESS COMPLETED ===`r`n")
                $outputBox.AppendText("Please restart your terminal/PowerShell to use newly installed CLI tools.`r`n")
            }

        }
        finally {
            $button.Enabled = $true
        }
    })

# Show the form
[void]$form.ShowDialog()
