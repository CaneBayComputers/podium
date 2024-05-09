# A Simple, Turn-Key, Bootstrap Laravel PHP Dev Environment for Windows, Linux and Mac for Beginners to Advanced Users!

If you just want to get to coding, using, practicing or checking out Laravel right away then my friend you are at the right place. If you want things to go smoothly please carefully read and **follow the instructions**. This project was designed for the absolute beginner in mind but advanced users can find this useful.

More details about this bootstrap Laravel project and what is all entailed 

---

### Windows Development Option:

You will be installing VirtualBox which is software that enables you to run other operating systems on your current Windows system.

There are some requirements your system must meet for the virtual machine to run well.

> Minimum Requirements:
>
> 1. 8GB RAM memory
> 2. 40GB of available storage space
> 3. Quad-core CPU with virtualization (VT-x / AMD-V enabled)

If you already have VirtualBox installed just skip to downloading an OVA Linux file where you can just import.

DOWNLOAD ALL FILES IN THE SAME DIRECTORY!!!

Do NOT manually run any of the .exe files after downloading!

All files are safe and come from original source website.

Download each required file:

- [Click to download Microsoft C++ Redistributable 2019](https://aka.ms/vs/17/release/vc_redist.x64.exe)

- [Click to download VirtualBox](https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe)

- [Click to download VirtualBox extensions](https://download.virtualbox.org/virtualbox/7.0.14/Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack)

- Choose ONE Linux distribution OVA file:

  - [Click to download Linux Mint 21 (recommended)](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-mint-21.ova)

  - [Click to download Linux Ubuntu 24](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-ubuntu-24.ova.ova)

  - [Click to download Linux ZorinOS 17](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-zorinos-17.ova)

  - [Click to download Linux PopOS 22:](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-popos-22.ova)

- Right click link and select "Save link as ...":
[INSTALL.BAT](https://raw.githubusercontent.com/CaneBayComputers/cbc-windows-setup/main/INSTALL.BAT)

Open your Downloads folders and just double-click the INSTALL.BAT file.

A blue warning box will pop up. Just select *More Info* and select *Run anyway*.

If the Microsoft Redistributable gives you a choice to *Repair*, *Uninstall* or *Close* just select *Close*.

Do NOT run VirtualBox after installation. Uncheck box to run after install.

Just answer `y` when it asks you.

You will have to enter the default password to get into the VM:

Pass: `1234`

---

### Linux Development Option:

You can install this Laravel PHP bootstrap development environment directly on to Linux natively or in an existing Linux virtual machine.

> It must be installed on Ubuntu or an Ubuntu variant such as but not limited to: Mint, ZorinOS or PopOS.

Run the following commands in a terminal to install git version control if not installed already:

Install git:
```bash
sudo apt-get update

sudo apt-get install git
```

A `repos` directly MUST exist in your user home directory

Create the directory:

```bash
cd ~

mkdir repos

cd repos
```

Clone this repo:
```bash
git clone git@github.com:CaneBayComputers/cbc-development-setup.git
```

Run installer:
```bash
cd cbc-development-setup

./install.sh
```
---

### Mac Development Option:

Well, to be honest there isn't exactly one however you should be able to cobble it together by installing VirtualBox on Mac and importing one of the Linux bootstrap OVA files which will have Laravel PHP on it ready to go.


## 