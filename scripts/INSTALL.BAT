@ECHO OFF

VC_redist.x64.exe

VirtualBox-7.0.14-161095-Win.exe

"C:\Program Files\Oracle\VirtualBox\VBoxManage" extpack install --replace "Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack"

"C:\Program Files\Oracle\VirtualBox\VBoxManage" import cbc-linux-mint-21.ova

"C:\Program Files\Oracle\VirtualBox\VBoxManage" startvm "cbc-linux-mint-21"

timeout /t -1