# Avid Kiya Termux Ubuntu Launcher English Guide

This project installs a complete startup launcher for Termux. Every time you open Termux or a new bash session, it shows a menu:

```text
1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer
4. 🚪 Exit - Opening Termux normally
```

## Features

- Automatic dependency installation
- Automatic `~/.bashrc` integration
- Beautiful ASCII startup menu
- Real Ubuntu shell through `proot-distro`
- Ubuntu installer in menu option 3
- Separate banners for Termux and Ubuntu
- Weather report from `wttr.in/36.46,52.86`
- Optional colors through `lolcat`
- Safe uninstall script

## Installation

Run this inside Termux:

```bash
pkg update -y
pkg install -y git

git clone https://github.com/YOUR_USERNAME/avid-termux-ubuntu-launcher.git
cd avid-termux-ubuntu-launcher
bash install.sh
```

Restart Termux, or run:

```bash
source ~/.bashrc
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

Then prepares basic packages inside Ubuntu:

```bash
apt update
apt install -y curl ca-certificates bash
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
