# Avid Kiya Termux Ubuntu Launcher English Guide

This is an upgraded version of the old Avid Kiya Termux fish theme: `screenfetch`, `lolcat`, `figlet + Avid Kiya +`, weather, date, and fish with Oh My Fish/batman — now extended with a Termux/Ubuntu menu and installer.

This project installs a complete startup launcher for Termux. Every time you open Termux or a new bash session, it shows a menu:

```text
1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer
4. 🚪 Exit - Opening Termux normally
```

## Features

- Automatic dependency installation
- Installs fish, Oh My Fish, and batman theme
- Automatic `~/.bashrc` integration
- Beautiful ASCII startup menu
- Real Ubuntu shell through `proot-distro`
- Ubuntu installer in menu option 3
- Separate banners for Termux and Ubuntu
- Weather report from `wttr.in/36.46,52.86`
- Optional colors through `lolcat`
- Safe uninstall script
- Backs up and rewrites `~/.bashrc` from zero
- Ubuntu PATH/development patch including `patch`, `gcc`, `make`, and build tools

## Installation

Run this inside Termux:

```bash
pkg update -y
pkg install -y git

git clone https://github.com/YOUR_USERNAME/avid-termux-ubuntu-launcher.git
cd avid-termux-ubuntu-launcher
bash install.sh
```

Restart Termux, or if you are inside Bash run:

```bash
source ~/.bashrc
```

If you are inside fish, do not run `source ~/.bashrc`. Run this instead:

```bash
exec bash -i
```

## Usage

### Option 1: Run Termux

Shows the Termux banner and opens a normal Termux shell with:

```text
^^>>>
```

### Option 2: Run Ubuntu

If Ubuntu is installed, this opens a real Ubuntu proot shell:

```text
>>>
```

If Ubuntu is not installed, choose option 3 first.

### Option 3: Ubuntu installer

Installs Ubuntu using:

```bash
proot-distro install ubuntu
```

Then prepares base and development/patch packages inside Ubuntu:

```bash
apt update
apt install -y curl ca-certificates bash patch make gcc g++ build-essential git wget
```

### Option 4: Exit - Opening Termux normally

Skips the launcher and opens a normal Termux session.

## Configuration

After installation, edit:

```bash
~/.termux-avid-kiya/config
```

Example:

```bash
AK_WTTR_LOCATION="36.46,52.86"
AK_NAME="Avid Kiya"
AK_UBUNTU_DISTRO="ubuntu"
AK_AUTO_FISH_AFTER_TERMUX="0"
AK_USE_LOLCAT="1"
```

To automatically open `fish` after choosing option 1:

```bash
AK_AUTO_FISH_AFTER_TERMUX="1"
```

## Uninstall

```bash
cd avid-termux-ubuntu-launcher
bash uninstall.sh
```

This removes only the launcher integration. To remove Ubuntu too:

```bash
proot-distro remove ubuntu
```

## Important note about Ubuntu in Termux

Ubuntu runs via `proot-distro`. You get a real Ubuntu filesystem and userspace tools, but the kernel is still your Android device kernel. Therefore, `uname -a` may show the Android kernel.

## Troubleshooting

### Menu is not displayed

Check whether the installer block exists:

```bash
grep -n "AVID_KIYA" ~/.bashrc
```

If nothing is printed, run the installer again:

```bash
bash install.sh
```

### Ubuntu does not open

Install it first:

```bash
proot-distro install ubuntu
```

or choose menu option 3.

### lolcat failed to install

```bash
pkg install ruby
gem install lolcat --no-document
```


## Quick repair if you sourced ~/.bashrc inside fish

If you see:

```text
Missing end to balance this if statement
```

You probably ran `source ~/.bashrc` inside fish. Fix it with:

```bash
exec bash -i
```

or restart Termux.

## Updating an existing installation from GitHub

After uploading the new files to GitHub, update an old install with:

```bash
cd termux-ubuntu-launcher
git pull
bash install.sh
exec bash -i
```

To patch Ubuntu, choose menu option 3. If Ubuntu already exists, it will not be removed; it will only be patched and updated.


## MiMo Code support

Menu option 3 patches Ubuntu and tries to install MiMo Code automatically. It installs Node.js/npm and then runs:

```bash
npm install -g @mimo-ai/cli
```

If that fails, it also tries the official installer:

```bash
curl -fsSL https://mimo.xiaomi.com/install | bash
```

After patching, option 2 should show the MiMo path if `mimo` is available.


## Final MiMo command-not-found fix

MiMo is often installed at:

```bash
/root/.mimocode/bin/mimo
```

Menu option 3 now automatically adds this path to PATH, writes it to `/root/.bashrc`, sources `/root/.bashrc`, and creates this symlink when possible:

```bash
ln -sf /root/.mimocode/bin/mimo /usr/local/bin/mimo
```

After running option 3, this should work inside Ubuntu:

```bash
mimo
```


## Oh My Fish and batman inside Ubuntu

Menu option 3 also installs and enables fish + Oh My Fish + batman inside Ubuntu:

```bash
apt install -y fish
curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
omf install batman
omf theme batman
```

Option 2 shows the Ubuntu banner first, then opens fish/batman by default. To disable it:

```bash
nano ~/.termux-avid-kiya/config
AK_AUTO_FISH_AFTER_UBUNTU="0"
```
