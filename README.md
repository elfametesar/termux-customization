# Termux Customization
- Changed PS1 format
- PS1 name changes colors according to root status
- Added colorful ls command and sudo
- Added font and new set of color palette
- Now you can run termux apps on rooted bash

**This project was inspired by MT Manager terminal, I basically tried to make Termux look like it a little.
Binaries are also taken from it except su binary, which I modified Termux's stock one.**

# Installation
You can simply put setup.sh file in Termux home folder and give the appropriate permissions then run with ./setup.sh or
```
pkg install wget -y
wget https://raw.githubusercontent.com/erenmete/termux-customization/main/setup.sh
chmod +x setup.sh
./setup.sh
```
