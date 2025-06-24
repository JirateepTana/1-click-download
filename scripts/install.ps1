Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "1-Click Installer"
$form.Size = New-Object System.Drawing.Size(400,220)
$form.StartPosition = "CenterScreen"

# Checkbox for Node.js
$checkboxNode = New-Object System.Windows.Forms.CheckBox
$checkboxNode.Text = "Install Node.js"
$checkboxNode.Location = New-Object System.Drawing.Point(30,30)
$checkboxNode.Size = New-Object System.Drawing.Size(200,30)
$checkboxNode.Checked = $true
$form.Controls.Add($checkboxNode)

# Output TextBox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(30,70)
$outputBox.Size = New-Object System.Drawing.Size(320,60)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

# Confirm Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Confirm"
$button.Location = New-Object System.Drawing.Point(260,140)
$button.Size = New-Object System.Drawing.Size(90,30)
$form.Controls.Add($button)

# Download Node.js function (from your install.ps1)
function Install-NodeJS {
    $installPath = "D:\nodejs"
    $zipPath = "$env:TEMP\nodejs.zip"
    $outputBox.AppendText("Fetching latest LTS Node.js version...`r`n")
    $indexJson = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json"
    $latest = $indexJson | Where-Object { $_.lts } | Select-Object -First 1
    $version = $latest.version
    $outputBox.AppendText("Latest LTS version detected: $version`r`n")
    $zipUrl = "https://nodejs.org/dist/$version/node-$version-win-x64.zip"

    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath | Out-Null
    }

    if (Test-Path "$installPath\node.exe") {
        $outputBox.AppendText("Node.js is already installed at $installPath`r`n")
        & "$installPath\node.exe" -v | ForEach-Object { $outputBox.AppendText("$_`r`n") }
        return
    }

    $outputBox.AppendText("Downloading Node.js from $zipUrl`r`n")
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

    $outputBox.AppendText("Extracting Node.js to $installPath`r`n")
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $installPath)

    $subfolder = Get-ChildItem -Path $installPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if ($subfolder) {
        Get-ChildItem -Path $subfolder.FullName | Move-Item -Destination $installPath -Force
        Remove-Item -Path $subfolder.FullName -Recurse -Force
    }

    Remove-Item $zipPath -Force

    $nodePath = "$installPath\node.exe"
    $npmPath = "$installPath\npm.cmd"

    if (Test-Path $nodePath) {
        $outputBox.AppendText("Node.js installed successfully:`r`n")
        & $nodePath -v | ForEach-Object { $outputBox.AppendText("$_`r`n") }
        if (Test-Path $npmPath) {
            $outputBox.AppendText("npm version:`r`n")
            & $npmPath -v | ForEach-Object { $outputBox.AppendText("$_`r`n") }
        } else {
            $outputBox.AppendText("npm not found!`r`n")
        }
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if (-not ($currentPath -split ";" | Where-Object { $_ -eq $installPath })) {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", "User")
            $outputBox.AppendText("Added $installPath to user PATH. Restart your terminal to use 'node' globally.`r`n")
        } else {
            $outputBox.AppendText("$installPath is already in user PATH.`r`n")
        }
    } else {
        $outputBox.AppendText("Installation failed. Node.js not found in $installPath`r`n")
    }
}

# Button click event
$button.Add_Click({
    $outputBox.Clear()
    if ($checkboxNode.Checked) {
        Install-NodeJS
    } else {
        $outputBox.AppendText("Nothing selected to install.`r`n")
    }
})

# Show the form
[void]$form.ShowDialog()