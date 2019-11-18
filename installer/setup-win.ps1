iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$Out_File = ".\win.apps "
wget "https://raw.githubusercontent.com/acefei/ace-profile/master/config/win.apps" -O $Out_File
cinst $Out_File -y
rm $Out_File
