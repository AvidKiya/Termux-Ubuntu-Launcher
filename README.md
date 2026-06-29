# Avid Kiya Termux Ubuntu Launcher

**فارسی:** لانچر منویی زیبا برای Termux که موقع باز شدن هر سشن، بین Termux، Ubuntu و نصب Ubuntu انتخاب می‌دهد.  
**English:** A beautiful startup menu for Termux that lets you choose Termux, Ubuntu, install Ubuntu, or open a normal Termux session.

---

## نصب سریع / Quick Install

```bash
pkg update -y
pkg install -y git

git clone https://github.com/YOUR_USERNAME/avid-termux-ubuntu-launcher.git
cd avid-termux-ubuntu-launcher
bash install.sh
```

بعد Termux را ببندید و دوباره باز کنید، یا اجرا کنید:

```bash
source ~/.bashrc
```

If you are inside fish, do not run `source ~/.bashrc`. Use this instead:

```bash
exec bash -i
```

Then use:

```text
1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer
4. 🚪 Exit - Opening Termux normally
```

> First choose option `3` once to install Ubuntu. After that, option `2` opens a real Ubuntu proot shell.

---

## Documentation

- [راهنمای فارسی](docs/README.fa.md)
- [English Guide](docs/README.en.md)

---

## Features

- Auto-start menu from `~/.bashrc`
- Termux banner with Android/system info
- Ubuntu banner after entering Ubuntu
- Real Ubuntu installation using `proot-distro`
- Weather from `wttr.in/36.46,52.86`
- Optional `lolcat` colors
- Safe uninstall script
- Config file at `~/.termux-avid-kiya/config`
- Rewrites `~/.bashrc` from zero after backing it up
- Ubuntu PATH/development patch for tools that need `patch`, `gcc`, `make`, etc.

---

## Uninstall

```bash
cd avid-termux-ubuntu-launcher
bash uninstall.sh
```

To remove Ubuntu too:

```bash
proot-distro remove ubuntu
```

---

## License

MIT
