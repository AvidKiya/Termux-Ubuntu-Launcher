# Changelog

## 2.0.0 - 2026-06-29

- Rebased project around the original classic Avid Kiya Termux theme.
- Option 1 now runs the classic flow and opens fish by default.
- Installer now installs termux-api, termux storage setup, fish, Oh My Fish, and batman theme.
- Installer now includes python, git, ruby, curl, figlet, screenfetch, nano, lolcat.

## 1.2.0 - 2026-06-29

- Fixed Ubuntu detection by testing real `proot-distro login ubuntu -- /bin/true`.
- Option 3 now asks: Patch/Update, Reinstall, or Back when Ubuntu exists.
- Added repair flow for broken containers where install says container exists.
- Added responsive compact ASCII menu for narrow mobile terminals.
- Ubuntu option now starts only after a successful login test.

## 1.1.0 - 2026-06-29

- Installer now backs up and rewrites `~/.bashrc` from zero, as requested.
- Added fish compatibility hook for users whose Termux starts with fish.
- Fixed confusion around running `source ~/.bashrc` inside fish.
- Ubuntu installer now also patches PATH and installs the `patch` package.
- Ubuntu installer now installs common development packages for tools that need compiling.
- Ubuntu startup shell exports a safe Linux PATH.

## 1.0.0 - 2026-06-29

- Initial release
- Termux startup menu
- Ubuntu install/run support through proot-distro
- Termux and Ubuntu ASCII banners
- Weather report support
- Install and uninstall scripts
- Persian and English documentation
