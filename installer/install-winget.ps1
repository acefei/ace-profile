<#
.SYNOPSIS
    Installs WinGet and its dependencies by downloading from the latest GitHub Release.
    Designed for Windows IoT Enterprise but compatible with other editions.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

#--------------------------------------------------------------------------
# Helper Functions
#--------------------------------------------------------------------------

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsIoT {
    Write-Host "Checking if Windows IoT Enterprise..."
    try {
        $osInfo = Get-CimInstance Win32_OperatingSystem
        return ($osInfo.Caption -like "*IoT*")
    } catch {
        Write-Warning "Failed to query Win32_OperatingSystem: $_"
        return $false
    }
}

function Get-Arch {
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq "AMD64") { return "x64" }
    return $arch
}

function Save-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath
    )
    Write-Host "  Downloading $(Split-Path $DestinationPath -Leaf)..."
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $DestinationPath -UseBasicParsing
    } catch {
        throw "Failed to download from $Url. Error: $_"
    }
}

function Expand-ZipFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ZipPath,
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath
    )
    Write-Host "  Extracting $(Split-Path $ZipPath -Leaf)..."
    Expand-Archive -Path $ZipPath -DestinationPath $DestinationPath -Force
}

function Install-WingetAndDependencies {
    param (
        [bool]$IsIoT,
        [string]$Arch,
        [string]$TempDir
    )

    $latestReleaseUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    Write-Host "Fetching latest WinGet release info from GitHub..." -ForegroundColor Yellow
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $release = Invoke-RestMethod -Uri $latestReleaseUrl -UseBasicParsing
    } catch {
        throw "Failed to fetch release info: $_"
    }

    # Find assets
    $msixAsset = $release.assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -First 1
    $licenseAsset = $release.assets | Where-Object { $_.name -eq "License1.xml" } | Select-Object -First 1
    $depsAsset = $release.assets | Where-Object { $_.name -eq "DesktopAppInstaller_Dependencies.zip" } | Select-Object -First 1

    if (-not $msixAsset) { throw "WinGet msixbundle not found in release." }
    if (-not $depsAsset) { throw "Dependencies zip not found in release." }

    # Download Assets
    $msixPath = Join-Path $TempDir $msixAsset.name
    Save-File -Url $msixAsset.browser_download_url -DestinationPath $msixPath

    $depsZipPath = Join-Path $TempDir $depsAsset.name
    Save-File -Url $depsAsset.browser_download_url -DestinationPath $depsZipPath

    $licensePath = $null
    if ($licenseAsset) {
        $licensePath = Join-Path $TempDir "License1.xml"
        Save-File -Url $licenseAsset.browser_download_url -DestinationPath $licensePath
    }

    # Extract Dependencies
    $depsExtractPath = Join-Path $TempDir "Dependencies"
    Expand-ZipFile -ZipPath $depsZipPath -DestinationPath $depsExtractPath

    # Install VCLibs
    # Structure is typically: [Arch]/Microsoft.VCLibs...appx
    $vclibs = Get-ChildItem -Path $depsExtractPath -Recurse -Filter "Microsoft.VCLibs*.appx" | Where-Object { $_.FullName -like "*$Arch*" } | Select-Object -First 1
    
    if ($vclibs) {
        Write-Host "Installing VCLibs ($($vclibs.Name))..." -ForegroundColor Yellow
        Add-AppxPackage -Path $vclibs.FullName
        Write-Host "  VCLibs installed." -ForegroundColor Green
    } else {
        Write-Warning "Could not find VCLibs for $Arch in downloaded dependencies."
    }

    # Install UI.Xaml (if present in dependencies zip)
    $uiXaml = Get-ChildItem -Path $depsExtractPath -Recurse -Filter "Microsoft.UI.Xaml*.appx" | Where-Object { $_.FullName -like "*$Arch*" } | Select-Object -First 1
    if ($uiXaml) {
         Write-Host "Installing UI.Xaml ($($uiXaml.Name))..." -ForegroundColor Yellow
         Add-AppxPackage -Path $uiXaml.FullName
         Write-Host "  UI.Xaml installed." -ForegroundColor Green
    }

    # Install WinGet
    Write-Host "Installing WinGet..." -ForegroundColor Yellow
    if ($IsIoT -and $licensePath) {
        Write-Host "  Using Add-AppxProvisionedPackage (IoT method)..."
        Add-AppxProvisionedPackage -Online -PackagePath $msixPath -LicensePath $licensePath
    } else {
        Write-Host "  Using Add-AppxPackage (Standard method)..."
        Add-AppxPackage -Path $msixPath
    }
    Write-Host "  WinGet installation successful." -ForegroundColor Green
}

function Test-Installation {
    Write-Host "Verifying installation..."
    
    # Update Path for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "SUCCESS: 'winget' command is available." -ForegroundColor Green
        winget --version
    } else {
        Write-Warning "Installation finished, but 'winget' command is not yet in the current session path."
        Write-Warning "You may need to restart your terminal or computer."
    }
}

#--------------------------------------------------------------------------
# Main Execution Flow
#--------------------------------------------------------------------------

if (-not (Test-IsAdmin)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$($MyInvocation.MyCommand.Path)`""
    exit
}

Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "WinGet Installer Script (Online Mode)" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"

try {
    $isIoT = Test-IsIoT
    if ($isIoT) {
        Write-Host "  -> Detected Windows IoT Enterprise." -ForegroundColor Green
    } else {
        Write-Host "  -> Standard Windows edition."
    }

    $arch = Get-Arch

    # Create Temp Directory
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "WingetInstall_$(Get-Random)"
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

    try {
        Install-WingetAndDependencies -IsIoT $isIoT -Arch $arch -TempDir $tempDir
        Test-Installation
    } finally {
        # Cleanup
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
} catch {
    Write-Error "Installation Failed: $_"
    exit 1
}
