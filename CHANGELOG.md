# Changelog

## v3.10.0 - Android-like App Mode + Pentest/Hack Lab

- Added `avid app`: starts localhost web panel and opens it on Android as an app-like experience.
- Added `avid app-shortcuts`: creates Termux:Widget shortcuts for DevHub App, CLI and Web Panel.
- Added PWA manifest and SVG icon for mobile standalone/browser install support.
- Startup `App Mode` now calls the new app flow instead of only web-start.
- Renamed security section to `تست نفوذ / هک`.
- Added real authorized lab packs: OSINT, API Testing, Android/Mobile Hacking Lab, Wordlists and Advanced Optional.
- Expanded web panel Pentest/Hack section and status checks.


## v3.9.0 - MiMo-inspired AvidKiya DevHub CODE TUI

- Added `scripts/avid_tui.py`, a dedicated Python curses terminal UI inspired by the MiMo Code experience.
- Added `avid code` / `avid tui` commands.
- Startup selector now prefers the richer TUI when `AK_CLI_THEME="mimo"`.
- Preserved the original classic Termux/Ubuntu launcher as a separate mode.
- Added direct backend routes for all TUI sections so arrow-selected actions call real commands.
- Fixed web backend routing safety: `web_start_bg`, `web-stop`, `web-status`, and foreground web mode are all explicit commands.
- Installer now copies and symlinks `avid-tui` without reinstalling existing packages.


## 2.3.0 - 2026-06-29

- Ubuntu now installs fish, Oh My Fish, and the batman theme too.
- Ubuntu option 2 shows the Avid Kiya Ubuntu banner and then opens fish/batman by default.
- Added Ubuntu fish PATH config so MiMo works inside fish as well.
- Added `AK_AUTO_FISH_AFTER_UBUNTU` config option.

## 2.2.0 - 2026-06-29

- Finalized matched Termux/Ubuntu Avid Kiya banners with lolcat color style.
- Installer now rewrites config from zero too, with backup, so old settings cannot break the final theme.
- Ubuntu patcher now adds `/root/.mimocode/bin` to PATH permanently.
- Ubuntu patcher now sources `/root/.bashrc` and symlinks `/root/.mimocode/bin/mimo` to `/usr/local/bin/mimo` when available.
- MiMo command-not-found fix is now built in.
- Ubuntu startup now sources `/root/.bashrc` before showing prompt.

## 2.1.0 - 2026-06-29

- Termux and Ubuntu banners now follow the same Avid Kiya style but with different artwork.
- Termux option uses Android art + TERMUX boxed banner + weather/date/uname.
- Ubuntu option uses penguin art + UBUNTU boxed banner + weather/date/uname and is colorized with lolcat when available.
- Ubuntu patcher now installs Node.js/npm, ruby/lolcat, development tools, and tries to install MiMo Code automatically.
- Added MiMo repair via `npm install -g @mimo-ai/cli` and official `curl -fsSL https://mimo.xiaomi.com/install | bash` fallback.

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
