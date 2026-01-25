<#
.SYNOPSIS
    Auto-configure SSH with Git Bash, using the native Windows Feature for OpenSSH.
    Installs common developer tools using WinGet.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

#--------------------------------------------------------------------------
# Helper Functions
#--------------------------------------------------------------------------

function Test-Command {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    return $null -ne $cmd
}

function Assert-Admin {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "powershell.exe"
        $processInfo.Verb = "RunAs"
        $processInfo.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        [System.Diagnostics.Process]::Start($processInfo) | Out-Null
        exit
    }
}

function Assert-Winget {
    Write-Host "Checking winget..." -ForegroundColor Yellow
    if (Test-Command "winget") {
        Write-Host "  OK" -ForegroundColor Green
        return
    }

    Write-Host "  Winget not found. Attempting installation..." -ForegroundColor Yellow
    
    # Use $PSScriptRoot to get the script directory correctly within a function
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Split-Path -Parent $script:MyInvocation.MyCommand.Path
    }
    $scriptPath = Join-Path $scriptDir "install-winget.ps1"
    
    if (Test-Path $scriptPath) {
        Write-Host "  Invoking installer: $scriptPath"
        try {
            $process = Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"" -Wait -NoNewWindow -PassThru
            
            if ($process.ExitCode -ne 0) {
                throw "Installer script failed with exit code $($process.ExitCode)."
            }

            if (Test-Command "winget") {
                Write-Host "  Winget installed successfully." -ForegroundColor Green
            } else {
                throw "Winget installation script finished, but 'winget' command is still not found."
            }
        } catch {
            throw "Winget installation failed. Error: $_"
        }
    } else {
        throw "Winget installer script (install-winget.ps1) not found at $scriptPath."
    }
}

function Install-App {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppName,
        [Parameter(Mandatory=$true)]
        [string]$AppId,
        [string]$Command
    )
    
    if (-not [string]::IsNullOrEmpty($Command) -and (Test-Command $Command)) {
        Write-Host "  $AppName is already installed (command '$Command' found)." -ForegroundColor Green
        return
    }
    
    Write-Host "Installing $AppName..." -ForegroundColor Yellow
    
    # Check if already installed by checking winget's source
    # Using specific source to avoid confusion with msstore or others if needed, but keeping general for robustness
    if (winget list --id $AppId --accept-source-agreements | Select-String -Quiet $AppId) {
        Write-Host "  Already installed" -ForegroundColor Green
        return
    }
    
    $argsList = @("install", "--id", $AppId, "-e", "--source", "winget", "--accept-package-agreements", "--accept-source-agreements")
    $process = Start-Process winget -ArgumentList $argsList -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -ne 0) {
        throw "Failed to install $AppName (Exit code: $($process.ExitCode))"
    }
    
    Write-Host "  OK" -ForegroundColor Green
}

function Find-GitBash {
    Write-Host "Locating Git Bash..." -ForegroundColor Yellow
    
    $possiblePaths = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Host "  Found: $path" -ForegroundColor Green
            return $path
        }
    }
    
    throw "Git Bash not found at expected locations"
}

function Set-SshDefaultShell {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ShellPath
    )
    
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

function Update-EnvironmentVariables {
    Write-Host "Refreshing environment variables for this session..." -ForegroundColor Yellow
    
    # Update the Path for the current process
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "  OK. Note: A system restart may be required for changes to apply everywhere." -ForegroundColor Green
}

function Install-HttpServerContext {
    Write-Host "Installing 'http-server' context menu..." -ForegroundColor Yellow
    
    if (-not (Test-Command "npm")) {
        throw "npm not found. Please ensure NodeJS is installed and in your PATH."
    }
    
    if (Test-Command "http-server") {
        Write-Host "  http-server is already installed." -ForegroundColor Green
    } else {
        Write-Host "  Installing http-server globally via npm..."
        # Using Start-Process to capture exit codes properly if needed, but direct execution is fine for npm here
        # Redirecting error to null to keep it clean if successful
        try {
            npm install http-server -g --silent | Out-Null
        } catch {
            throw "Failed to install http-server: $_"
        }
    }

    $regKeyPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\Open http-server here"
    if (Test-Path $regKeyPath) {
        Write-Host "  Context menu registry key already exists. Skipping import." -ForegroundColor Green
        return
    }
    
    $regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\shell\Open http-server here]
@="Open http-server here"

[HKEY_CLASSES_ROOT\Directory\shell\Open http-server here\command]
@="cmd.exe /k \"cd /d %1 && http-server\""
"@

    $regFile = Join-Path $env:TEMP "http-server-here.reg"
    $regContent | Out-File -FilePath $regFile -Encoding Unicode

    Write-Host "  Importing registry file..."
    $process = Start-Process reg -ArgumentList "import `"$regFile`"" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -ne 0) {
        throw "Failed to import registry file."
    }
    
    Remove-Item $regFile -Force
    
    Write-Host "  OK" -ForegroundColor Green
}

function Add-GitBashToTerminalProfile {
    Write-Host "Adding Git Bash to Windows Terminal profiles..." -ForegroundColor Yellow

    # Find Windows Terminal settings file
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (-not (Test-Path $wtSettingsPath)) {
        Write-Host "  Windows Terminal settings.json not found. Skipping." -ForegroundColor Yellow
        return
    }

    $gitBashPath = Find-GitBash
    # gitBashPath is guaranteed to be valid due to Find-GitBash throwing, but keeping check for clarity
    
    $gitInstallPath = (Get-Item (Split-Path (Split-Path $gitBashPath -Parent) -Parent)).FullName

    try {
        $jsonContent = Get-Content $wtSettingsPath -Raw 
        if ([string]::IsNullOrWhiteSpace($jsonContent)) {
            Write-Warning "Windows Terminal settings.json is empty."
            return
        }
        $settings = $jsonContent | ConvertFrom-Json
    } catch {
        Write-Warning "Failed to parse Windows Terminal settings.json: $_"
        return
    }

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
        Set-TimeZone -Id "China Standard Time"
        Write-Host "  OK" -ForegroundColor Green
    } catch {
        throw "Failed to set TimeZone. Error: $_"
    }
}

function Initialize-Ssh {
    Write-Host "Configuring SSH for Git..." -ForegroundColor Yellow
    
    # Check if OpenSSH is available
    $sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
    if (-not $sshService) {
        Write-Host "OpenSSH Server (sshd) is not installed. Attempting to install..." -ForegroundColor Yellow
        try {
            # Install OpenSSH Server
            Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
            
            # Set startup type to Automatic and start service
            Set-Service -Name sshd -StartupType Automatic
            Start-Service sshd
            
            Write-Host "OpenSSH Server installed successfully." -ForegroundColor Green
        } catch {
            Write-Warning "Failed to install OpenSSH Server: $_"
            $choice = Read-Host "Do you want to continue without SSH configuration? (y/n)"
            if ($choice -notmatch "^[Yy]$") {
                throw "Setup aborted by user due to SSH installation failure."
            }
            Write-Warning "Skipping SSH configuration..."
            return
        }
    }
    
    $bashPath = Find-GitBash
    Set-SshDefaultShell -ShellPath $bashPath
    Restart-SshdService
    
    Write-Host "`nSSH setup complete." -ForegroundColor Green
}

function Get-LocalIpAddress {
    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.InterfaceAlias -notlike "Loopback*" -and $_.AddressState -eq 'Preferred'
    } | Select-Object -ExpandProperty IPAddress
    
    return $ipAddresses
}

#--------------------------------------------------------------------------
# Main Execution
#--------------------------------------------------------------------------

function Invoke-Setup {
    try {
        Assert-Admin
        Assert-Winget
        Write-Host ""

        # --- Configure SSH using git-bash as login shell ---
        Install-App -AppName "Git" -AppId "Git.Git" -Command "git"
        Write-Host ""

        Initialize-Ssh
        
        # --- Install Developer Tools ---
        Install-App -AppName "Visual Studio Code" -AppId "Microsoft.VisualStudioCode" -Command "code"
        Write-Host ""
        
        Install-App -AppName "NodeJS (LTS)" -AppId "OpenJS.NodeJS.LTS" -Command "node"
        Write-Host ""
        
        Install-App -AppName "SSHFS-Win" -AppId "SSHFS-Win.SSHFS-Win"
        Write-Host ""
        
        # --- Configure Environment ---
        Update-EnvironmentVariables
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
        $ipAddresses = Get-LocalIpAddress

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
Invoke-Setup
