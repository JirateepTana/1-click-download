# 1-Click Installer Tool

A simple PowerShell-based tool to install common developer tools with a single command.

## 🔧 What It Does

- Installs essential tools silently using Chocolatey:
  - Node.js
  - Git
  - Docker Desktop
  - VS Code
  - 7-Zip
- Logs output to `logs/install-log.txt`
- Easy to expand or customize

## 🚀 How to Use

1. Make sure Chocolatey is installed on the system.
2. Open PowerShell **as Administrator**.
3. Navigate to the `1click-installer/` folder.
4. Run the script:

```powershell
.\scripts\install.ps1
```
