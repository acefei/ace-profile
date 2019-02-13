@echo off
del %systemroot%\system32\drivers\etc\hosts
echo 127.0.0.1 localhost >> %systemroot%\system32\drivers\etc\hosts

# Query on http://tool.chinaz.com/dns/, the best practice to select "114DNS[海外]" node.

# Github 
echo 192.30.253.118	gist.github.com         >> %systemroot%\system32\drivers\etc\hosts
echo 151.101.72.249	global-ssl.fastly.net   >> %systemroot%\system32\drivers\etc\hosts

ipconfig /flushdns
