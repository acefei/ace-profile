$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Re-run as Admin
    $arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass", $arguments
    exit
}

function Install-App {
    param(
        [string]$appId
    )
    winget install -e --id $appId --accept-source-agreements --accept-package-agreements
}

function Refresh-Env {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# VS Code
Install-App -appId "Microsoft.VisualStudioCode"

# NodeJS
Install-App -appId "OpenJS.NodeJS.LTS"

# Make the software path take effect
Refresh-Env

# Right-click on any folder to start a simple HTTP server
npm install http-server -g
Set-Variable -Name "HttpServerReg" -Value "$env:USERPROFILE\Desktop\http-server-here.reg"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chadoe/http-server-here/master/http-server-here.reg" -OutFile "$HttpServerReg"
reg import "$HttpServerReg"

# Set TimeZone
Set-TimeZone -Id "China Standard Time"

# Input
$UserLanguageList = Get-WinUserLanguageList
$UserLanguageList.Add("zh-CN")
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
