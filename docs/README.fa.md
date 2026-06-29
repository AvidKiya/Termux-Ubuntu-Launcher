# راهنمای فارسی Avid Kiya Termux Ubuntu Launcher

این پروژه یک لانچر کامل برای Termux است که با باز شدن برنامه Termux یا هر سشن جدید، یک منوی زیبا نمایش می‌دهد:

```text
1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer
4. 🚪 Exit - Opening Termux normally
```

## قابلیت‌ها

- نصب خودکار وابستگی‌ها
- اضافه شدن خودکار به `~/.bashrc`
- نمایش منوی ASCII هنگام باز شدن Termux
- اجرای واقعی Ubuntu با `proot-distro`
- نصب Ubuntu با گزینه ۳
- نمایش بنر جداگانه برای Termux و Ubuntu
- نمایش آب‌وهوا با `wttr.in/36.46,52.86`
- پشتیبانی از رنگی کردن خروجی با `lolcat`
- امکان حذف امن با `uninstall.sh`
- پاک‌سازی و نوشتن دوباره `~/.bashrc` از صفر همراه با بکاپ
- پچ PATH و نصب ابزارهای لازم داخل Ubuntu مثل `patch`، `gcc`، `make` برای نصب ابزارهایی مثل mimo

## نصب

داخل Termux اجرا کنید:

```bash
pkg update -y
pkg install -y git

git clone https://github.com/YOUR_USERNAME/avid-termux-ubuntu-launcher.git
cd avid-termux-ubuntu-launcher
bash install.sh
```

بعد از نصب، Termux را کامل ببندید و دوباره باز کنید. اگر داخل Bash هستید می‌توانید بزنید:

```bash
source ~/.bashrc
```

اما اگر داخل fish هستید، `source ~/.bashrc` نزنید؛ چون fish فایل bash را نمی‌فهمد. به‌جایش بزنید:

```bash
exec bash -i
```

## استفاده

### گزینه ۱: Run Termux

بنر Termux نمایش داده می‌شود و وارد محیط Termux می‌شوید:

```text
^^>>>
```

### گزینه ۲: Run Ubuntu

اگر Ubuntu نصب شده باشد، یک شل واقعی Ubuntu با `proot-distro` باز می‌شود:

```text
>>>
```

اگر Ubuntu نصب نشده باشد، برنامه به شما می‌گوید اول گزینه ۳ را بزنید.

### گزینه ۳: Ubuntu installer

Ubuntu را با `proot-distro` نصب می‌کند:

```bash
proot-distro install ubuntu
```

و داخل Ubuntu پکیج‌های پایه و پکیج‌های پچ/کامپایل را نصب می‌کند:

```bash
apt update
apt install -y curl ca-certificates bash patch make gcc g++ build-essential git wget
```

### گزینه ۴: Exit - Opening Termux normally

منو را رد می‌کند و وارد حالت عادی Termux می‌شود.

## تنظیمات

بعد از نصب، فایل تنظیمات اینجاست:

```bash
~/.termux-avid-kiya/config
```

نمونه:

```bash
AK_WTTR_LOCATION="36.46,52.86"
AK_NAME="Avid Kiya"
AK_UBUNTU_DISTRO="ubuntu"
AK_AUTO_FISH_AFTER_TERMUX="0"
AK_USE_LOLCAT="1"
```

اگر می‌خواهید بعد از گزینه ۱ مستقیم وارد `fish` شوید:

```bash
AK_AUTO_FISH_AFTER_TERMUX="1"
```

## حذف نصب

```bash
cd avid-termux-ubuntu-launcher
bash uninstall.sh
```

این دستور فقط لانچر را از `~/.bashrc` حذف می‌کند. برای حذف Ubuntu:

```bash
proot-distro remove ubuntu
```

## نکته مهم درباره Ubuntu در Termux

Ubuntu داخل Termux با `proot-distro` اجرا می‌شود. یعنی Ubuntu واقعی از نظر فایل‌سیستم و ابزارهای لینوکسی دارید، اما کرنل همان کرنل اندروید دستگاه است. پس خروجی `uname -a` ممکن است کرنل اندروید را نشان دهد.

## رفع مشکل

### منو نمایش داده نمی‌شود

این دستور را اجرا کنید:

```bash
grep -n "AVID_KIYA" ~/.bashrc
```

اگر چیزی نشان نداد، دوباره نصب کنید:

```bash
bash install.sh
```

### Ubuntu باز نمی‌شود

اول نصب را انجام دهید:

```bash
proot-distro install ubuntu
```

یا از منو گزینه ۳ را بزنید.

### lolcat نصب نشد

```bash
pkg install ruby
 gem install lolcat --no-document
```


## تعمیر سریع اگر قبلاً `source ~/.bashrc` را داخل fish زدید

اگر خطایی شبیه این دیدید:

```text
Missing end to balance this if statement
```

مشکل از این است که داخل fish دستور `source ~/.bashrc` زده شده. راه‌حل:

```bash
exec bash -i
```

یا Termux را کامل ببندید و دوباره باز کنید.

## دستور آپدیت از GitHub

بعد از اینکه فایل‌های جدید را در GitHub آپلود کردید، برای آپدیت نصب قبلی:

```bash
cd termux-ubuntu-launcher
git pull
bash install.sh
exec bash -i
```

برای پچ کردن Ubuntu هم از منو گزینه ۳ را بزنید. اگر Ubuntu از قبل نصب باشد، حذف نمی‌شود؛ فقط پچ و آپدیت می‌شود.
