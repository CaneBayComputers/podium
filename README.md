This project was designed for the absolute beginner in mind. If you plan on installing Linux yourself you can run this after doing so. Otherwise, if you are on a Windows machine head over to [cbc-windows-setup](https://github.com/CaneBayComputers/cbc-windows-setup) where you can easily install a Linux Mint virtual box that is ready to go! No prior dev op experience required! You don't even need to know anything about Linux whatsoever.

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
