<#
.SYNOPSIS
  Auto-configure SSH with Git Bash, using the native Windows Feature for OpenSSH.
#>

#--------------------------------------------------------------------------
# Auto-elevate to Administrator
#--------------------------------------------------------------------------
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-File", "`"$($MyInvocation.MyCommand.Path)`""
    exit
}

#--------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------

function Test-Winget {
    Write-Host "Checking winget..." -ForegroundColor Yellow
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget not found. Please install App Installer from Microsoft Store."
    }
    Write-Host "  OK" -ForegroundColor Green
}

function Install-OpenSshFeature {
    Write-Host "Installing OpenSSH Server (as a Windows Feature)..." -ForegroundColor Yellow

    $sshCapability = Get-WindowsCapability -Online -Name "OpenSSH.Server*" | Where-Object { $_.Name -like 'OpenSSH.Server*' }

    if ($sshCapability.State -eq 'Installed') {
        Write-Host "  Already installed" -ForegroundColor Green
        return
    }

    try {
        Write-Host "  Installing..." -ForegroundColor Yellow
        Add-WindowsCapability -Online -Name $sshCapability.Name -ErrorAction Stop
    } catch {
        throw "Failed to install OpenSSH Server feature. Error: $_"
    }

    $sshCapability = Get-WindowsCapability -Online -Name $sshCapability.Name
    if ($sshCapability.State -ne 'Installed') {
        throw "OpenSSH Server feature installation reported success, but verification failed."
    }

    Write-Host "  OK" -ForegroundColor Green
}

function Install-App {
    param(
        [string]$AppName,
        [string]$AppId
    )
    
    Write-Host "Installing $AppName..." -ForegroundColor Yellow
    
    # Check if already installed by checking winget's source
    if (winget list --id $AppId -s winget | Select-String -Quiet $AppId) {
        Write-Host "  Already installed" -ForegroundColor Green
        return
    }
    
    $args = "install --id $AppId -e --source winget --accept-package-agreements --accept-source-agreements"
    $process = Start-Process winget -ArgumentList $args -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -ne 0) {
        throw "Failed to install $AppName (Exit code: $($process.ExitCode))"
    }
    
    Write-Host "  OK" -ForegroundColor Green
}

function Find-GitBash {
    Write-Host "Locating Git Bash..." -ForegroundColor Yellow
    
    $bashPath = "$env:ProgramFiles\Git\bin\bash.exe"
    if (-not (Test-Path $bashPath)) {
        $bashPath = "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
    }
    
    if (-not (Test-Path $bashPath)) {
        throw "Git Bash not found at expected locations"
    }
    
    Write-Host "  Found: $bashPath" -ForegroundColor Green
    return $bashPath
}

function Set-SshDefaultShell {
    param([string]$ShellPath)
    
    Write-Host "Setting SSH default shell..." -ForegroundColor Yellow
    
    $regPath = "HKLM:\SOFTWARE\OpenSSH"
    $regKey = "DefaultShell"
    
    if (-not (Test-Path $regPath)) {
        throw "OpenSSH registry path not found: $regPath"
    }
    
    Set-ItemProperty -Path $regPath -Name $regKey -Value $ShellPath -Type String -Force
    
    $current = Get-ItemProperty -Path $regPath -Name $regKey
    if ($current.DefaultShell -ne $ShellPath) {
        throw "Registry verification failed"
    }
    
    Write-Host "  OK" -ForegroundColor Green
}

function Restart-SshdService {
    Write-Host "Restarting sshd service..." -ForegroundColor Yellow
    
    Restart-Service sshd -Force
    
    $service = Get-Service -Name sshd
    if ($service.Status -ne 'Running') {
        throw "Failed to restart sshd service"
    }
    
    Write-Host "  OK" -ForegroundColor Green
}

function Refresh-Env {
    Write-Host "Refreshing environment variables for this session..." -ForegroundColor Yellow
    
    # Update the Path for the current process
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "  OK. Note: A system restart may be required for changes to apply everywhere." -ForegroundColor Green
}

function Install-HttpServerContext {
    Write-Host "Installing 'http-server' context menu..." -ForegroundColor Yellow
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm not found. Please ensure NodeJS is installed and in your PATH."
    }
    
    if (Get-Command http-server -ErrorAction SilentlyContinue) {
        Write-Host "  http-server is already installed." -ForegroundColor Green
    } else {
        Write-Host "  Installing http-server globally via npm..."
        npm install http-server -g --silent
    }

    $regKeyPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\Open http-server here"
    if (Test-Path $regKeyPath) {
        Write-Host "  Context menu registry key already exists. Skipping import." -ForegroundColor Green
        Write-Host "  OK" -ForegroundColor Green
        return
    }
    
    $regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\shell\Open http-server here]
@="Open http-server here"

[HKEY_CLASSES_ROOT\Directory\shell\Open http-server here\command]
@="cmd.exe /k \"cd /d %1 && http-server\""
"@

    $regFile = "$env:TEMP\http-server-here.reg"
    $regContent | Out-File -FilePath $regFile -Encoding Unicode

    Write-Host "  Importing registry file..."
    $output = reg import "$regFile" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to import registry file: $output"
    }
    
    Remove-Item $regFile -Force
    
    Write-Host "  OK" -ForegroundColor Green
}

function Add-GitBashToTerminalProfile {
    Write-Host "Adding Git Bash to Windows Terminal profiles..." -ForegroundColor Yellow

    # Find Windows Terminal settings file
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (-not (Test-Path $wtSettingsPath)) {
        # For preview version of Windows Terminal
        $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    }

    if (-not (Test-Path $wtSettingsPath)) {
        Write-Host "  Windows Terminal settings.json not found. Skipping." -ForegroundColor Yellow
        return
    }

    $gitBashPath = Find-GitBash
    if (-not $gitBashPath) {
        Write-Host "  Git Bash not found. Skipping." -ForegroundColor Yellow
        return
    }
    
    $gitInstallPath = (Get-Item (Split-Path (Split-Path $gitBashPath -Parent) -Parent)).FullName

    $settings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json

    # Check if profile already exists
    $existingProfile = $settings.profiles.list | Where-Object { $_.name -eq "Git Bash" }
    if ($existingProfile) {
        Write-Host "  Git Bash profile already exists." -ForegroundColor Green
        return
    }

    # Generate a new GUID
    $guid = [guid]::NewGuid().ToString()

    $newProfile = @{
        guid          = "{$guid}"
        name          = "Git Bash"
        commandline   = "$gitBashPath -i -l"
        icon          = "$gitInstallPath\mingw64\share\git\git-for-windows.ico"
        startingDirectory = "%USERPROFILE%"
    }

    $settings.profiles.list += $newProfile

    $settings | ConvertTo-Json -Depth 10 | Set-Content $wtSettingsPath

    Write-Host "  OK" -ForegroundColor Green
}

function Set-TimeZoneChina {
    Write-Host "Setting TimeZone to 'China Standard Time'..." -ForegroundColor Yellow
    try {
        Set-TimeZone -Id "China Standard Time" -ErrorAction Stop
        Write-Host "  OK" -ForegroundColor Green
    } catch {
        throw "Failed to set TimeZone. Error: $_"
    }
}

function Setup-Ssh {
    Write-Host "Configuring SSH for Git..." -ForegroundColor Yellow
    
    # Check if OpenSSH is available
    $sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
    if (-not $sshService) {
        throw "OpenSSH Server (sshd) is not installed. Please install it first."
    }
    
    $bashPath = Find-GitBash
    Set-SshDefaultShell -ShellPath $bashPath
    Restart-SshdService
    
    Write-Host ""
    Write-Host "SSH setup complete." -ForegroundColor Green
}

#--------------------------------------------------------------------------
# Main Execution
#--------------------------------------------------------------------------

function Main {
    try {
        Test-Winget
        Write-Host ""

        # --- Configure SSH using git-bash as login shell ---
        Install-App -AppName "Git" -AppId "Git.Git"
        Write-Host ""

        Setup-Ssh
        
        # --- Install Developer Tools ---
        Install-App -AppName "Visual Studio Code" -AppId "Microsoft.VisualStudioCode"
        Write-Host ""
        
        Install-App -AppName "NodeJS (LTS)" -AppId "OpenJS.NodeJS.LTS"
        Write-Host ""
        
        # --- Configure Environment ---
        Refresh-Env
        Write-Host ""
        
        Install-HttpServerContext
        Write-Host ""
        
        Add-GitBashToTerminalProfile
        Write-Host ""

        Set-TimeZoneChina
        Write-Host ""
        
        # --- Success Message ---
        Write-Host "================================" -ForegroundColor Green
        Write-Host "  Setup Complete!" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Write-Host "`nYou can now SSH to this machine." -ForegroundColor Cyan

        # Find and display IP addresses for the SSH command
        $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
            $_.InterfaceAlias -notlike "Loopback*" -and $_.AddressState -eq 'Preferred'
        } | Select-Object -ExpandProperty IPAddress

        if ($ipAddresses) {
            Write-Host "Examples:" -ForegroundColor Cyan
            foreach ($ip in $ipAddresses) {
                Write-Host "  ssh $env:USERNAME@$ip" -ForegroundColor Cyan
            }
        } else {
            Write-Host "Could not determine local IP address. You can use the hostname:" -ForegroundColor Yellow
            Write-Host "  ssh $env:USERNAME@$env:COMPUTERNAME" -ForegroundColor Cyan
        }
        Write-Host ""

    } catch {
        Write-Host "`n================================" -ForegroundColor Red
        Write-Host "  Setup Failed" -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Write-Host "`nError: $_`n" -ForegroundColor Yellow
    } finally {
        Read-Host "Press Enter to exit"
    }
}

# Run main function
Main