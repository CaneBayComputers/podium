This project was designed for the absolute beginner in mind. If you plan on installing Linux yourself you can run this after doing so. Otherwise, if you are on a Windows machine head over to [cbc-windows-setup](https://github.com/CaneBayComputers/cbc-windows-setup) where you can easily install a Linux Mint virtual box that is ready to go! No prior dev op experience required! You don't even need to know anything about Linux whatsoever.

# CBC Development Linux Virtual Machine for Windows

If you are just starting off as a beginner and want to start developing PHP / Laravel this will get you all the way into starting a development machine on your Windows system.

For the batch file installer to work correctly please DOWNLOAD ALL FILES IN THE SAME DIRECTORY!!!

Do NOT run any of the .exe files!

## Download All Files

All files are safe and come from original source website.

You will first need Microsoft C++ Redistributable 2019.

Click to download: [vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)

If you don't already have VirtualBox just download this version here.

Click to download: [VirtualBox-7.0.14-161095-Win.exe](https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe)

Then you will need to download the extensions file.

Click to download: [Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack](https://download.virtualbox.org/virtualbox/7.0.14/Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack)

Next, download the VirtualBox virtual appliance OVA file.

This is a large download so this may be a while.

Click to download: [cbc-linux-mint-21.ova](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-mint-21.ova)

Next, download this repo's installation batch file.

Right click link and select "Save link as ...": [INSTALL.BAT](https://raw.githubusercontent.com/CaneBayComputers/cbc-windows-setup/main/INSTALL.BAT)

Open your Downloads folders and just double-click the INSTALL.BAT file.

A blue warning box will pop up. Just select *More Info* and select *Run anyway*.

I promise totes safe 😉

### PLEASE NOTE:

If the Microsoft Redistributable gives you a choice to *Repair*, *Uninstall* or *Close* just select *Close*.

Do NOT run VirtualBox after installation. Uncheck box to run after install.

Just answer `y` when it asks you.

You will have to enter the default password to get into the VM:

Pass: `1234`

Once started it will automatically start all of the containers.

There are more development instructions on the [cbc-development-setup](https://github.com/CaneBayComputers/cbc-development-setup)

After installing Linux Ubuntu, Mint or PopOS:

Run the following commands in a terminal (press Alt + Ctrl + t)

Install git:
```bash
sudo apt-get update

sudo apt-get install git
```

Clone this repo:
```bash
mkdir ~/repos

cd ~/repos

git clone git@github.com:CaneBayComputers/cbc-development-setup.git
```

Run installer:
```bash
cd ~/repos/cbc-development-setup

./install.sh
```
