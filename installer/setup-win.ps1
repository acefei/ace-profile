iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$Out_File = ".\packages.config"
wget "https://raw.githubusercontent.com/acefei/ace-profile/master/config/winapps.config" -O $Out_File
cinst $Out_File -y
rm $Out_File
