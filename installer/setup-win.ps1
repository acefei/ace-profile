If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$Out_File = ".\win.apps "
((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/acefei/ace-profile/master/config/win.apps")) | Out-File -FilePath $Out_File
choco install $Out_File -y
rm $Out_File
