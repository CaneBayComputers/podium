After installing Linux Ubuntu, Mint or PopOS install Git:

Run the following commands in a terminal (press Alt + Ctrl + t)

Install git and xclip:
```bash
sudo apt-get install git xclip
```

Create an SSH key:
```bash
mkdir ~/.ssh

cd ~/.ssh

# Create SSH key, just keep pressing enter for everything
ssh-keygen -t rsa -N ''

# Put SSH key into clipboard
cat ~/.ssh/id_rsa.pub | xclip -sel clip
```

In Github:
- Click your avatar > Settings > SSH and GPG keys
- Click 'New SSH key' button
- Enter a Title and paste (Ctrl + v) the key into the Key field
- Click 'Add SSH key' button

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
