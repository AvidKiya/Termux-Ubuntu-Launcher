#!/usr/bin/env python3
import os, subprocess, pathlib, datetime, secrets, shlex
from flask import Flask, render_template, request, redirect, url_for, jsonify

APP_DIR = pathlib.Path(os.environ.get('AK_APP_DIR', str(pathlib.Path.home()/'.termux-avid-kiya')))
CONFIG = APP_DIR/'config'
LOG_DIR = APP_DIR/'logs'
LOG_DIR.mkdir(parents=True, exist_ok=True)
HOST = os.environ.get('AK_WEB_HOST','127.0.0.1')
PORT = int(os.environ.get('AK_WEB_PORT','8765'))
app = Flask(__name__)

I18N = {
 'fa': {
  'dir':'rtl','lang_name':'فارسی','title':'Avid Kiya DevHub','subtitle':'ترموکس + اوبونتو + هوش مصنوعی + توسعه + آزمایشگاه امنیت سایبری',
  'dashboard':'داشبورد','ai':'ابزارهای هوش مصنوعی','cyber':'آزمایشگاه امنیت سایبری','dev':'ابزارهای توسعه','ubuntu':'اوبونتو','settings':'تنظیمات','logs':'لاگ‌ها',
  'quick':'عملیات سریع','status':'وضعیت سیستم','run':'اجرا','install':'نصب / تعمیر','missing':'نصب نیست','ok':'آماده','terminal_note':'پنل روی localhost اجرا می‌شود. عملیات‌ها در پس‌زمینه اجرا شده و خروجی داخل Logs ذخیره می‌شود. برای ابزارهای تعاملی مثل mimo/claude بهتر است از ترمینال avid استفاده شود.',
  'ethics':'فقط برای CTF، لَب دانشگاهی، سیستم شخصی و تست دارای مجوز استفاده شود.', 'task_started':'Task started. Check Logs.'
 },
 'en': {
  'dir':'ltr','lang_name':'English','title':'Avid Kiya DevHub','subtitle':'Termux + Ubuntu + AI + Dev + Cybersecurity Lab',
  'dashboard':'Dashboard','ai':'AI Tools','cyber':'Cybersecurity Lab','dev':'Developer Tools','ubuntu':'Ubuntu','settings':'Settings','logs':'Logs',
  'quick':'Quick Actions','status':'System Status','run':'Run','install':'Install / Repair','missing':'Missing','ok':'OK','terminal_note':'The panel runs on localhost. Actions run in background and output is stored in Logs. For interactive tools like mimo/claude, using the avid terminal menu is recommended.',
  'ethics':'Use only for CTF, university labs, personal systems, and authorized testing.', 'task_started':'Task started. Check Logs.'
 }
}

def lang():
    l=request.args.get('lang') or request.cookies.get('ak_lang') or 'fa'
    return l if l in I18N else 'fa'

def exists(cmd): return subprocess.call(f'command -v {cmd} >/dev/null 2>&1', shell=True)==0

def ubuntu(cmd): return subprocess.call(f'proot-distro login ubuntu -- bash -lc {shlex.quote(cmd)} >/dev/null 2>&1', shell=True)==0

def status():
    checks={
      'Termux': exists('pkg'),
      'Ubuntu': subprocess.call('proot-distro login ubuntu -- /bin/true >/dev/null 2>&1', shell=True)==0,
      'Fish': exists('fish'),
      'MiMo': ubuntu('command -v mimo >/dev/null 2>&1 || [ -x /root/.mimocode/bin/mimo ]'),
      'Claude': ubuntu('command -v claude >/dev/null 2>&1'),
      'Gemini': ubuntu('command -v gemini >/dev/null 2>&1'),
      'Aider': ubuntu('command -v aider >/dev/null 2>&1'),
      'nmap': ubuntu('command -v nmap >/dev/null 2>&1'),
      'sqlmap': ubuntu('command -v sqlmap >/dev/null 2>&1'),
      'john': ubuntu('command -v john >/dev/null 2>&1'),
      'radare2': ubuntu('command -v radare2 >/dev/null 2>&1'),
      'binwalk': ubuntu('command -v binwalk >/dev/null 2>&1'),
    }
    return checks

ACTIONS={
 'ubuntu_patch':'avid ubuntu-patch',
 'ai_mimo':'avid ai-mimo','ai_claude':'avid ai-claude','ai_gemini':'avid ai-gemini','ai_aider':'avid ai-aider','ai_all':'avid ai-all',
 'dev_all':'avid dev-all',
 'cyber_essential':'avid cyber-essential','cyber_recon':'avid cyber-recon','cyber_web':'avid cyber-web','cyber_hash':'avid cyber-hash','cyber_ctf':'avid cyber-ctf','cyber_forensics':'avid cyber-forensics','cyber_reverse':'avid cyber-reverse','cyber_full':'avid cyber-full',
 'health':'avid health-once'
}

def start_task(name):
    cmd=ACTIONS.get(name)
    if not cmd: return None
    ts=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    log=LOG_DIR/f'web-task-{name}-{ts}.log'
    with open(log,'w') as f:
        f.write(f'$ {cmd}\nStarted: {datetime.datetime.now()}\n\n')
    subprocess.Popen(f'({cmd}) >> {shlex.quote(str(log))} 2>&1', shell=True, cwd=str(APP_DIR))
    return log.name

@app.route('/')
def index():
    l=lang(); resp=app.make_response(render_template('dashboard.html', t=I18N[l], lang=l, s=status(), page='dashboard'))
    resp.set_cookie('ak_lang', l, max_age=60*60*24*365)
    return resp

@app.route('/ai')
def ai():
    l=lang(); return render_template('ai.html', t=I18N[l], lang=l, s=status(), page='ai')

@app.route('/cyber')
def cyber():
    l=lang(); return render_template('cyber.html', t=I18N[l], lang=l, s=status(), page='cyber')

@app.route('/dev')
def dev():
    l=lang(); return render_template('dev.html', t=I18N[l], lang=l, s=status(), page='dev')

@app.route('/ubuntu')
def ubuntu_page():
    l=lang(); return render_template('ubuntu.html', t=I18N[l], lang=l, s=status(), page='ubuntu')

@app.route('/settings', methods=['GET','POST'])
def settings():
    if request.method=='POST':
        data={k:request.form.get(k,'') for k in ['AK_WTTR_LOCATION','AK_WEB_HOST','AK_WEB_PORT','AK_LANGUAGE','AK_USE_LOLCAT','AK_AUTO_FISH_AFTER_TERMUX','AK_AUTO_FISH_AFTER_UBUNTU']}
        old=CONFIG.read_text(errors='ignore') if CONFIG.exists() else ''
        backup=CONFIG.with_suffix('.config-web-backup-'+datetime.datetime.now().strftime('%Y%m%d%H%M%S'))
        if CONFIG.exists(): backup.write_text(old)
        lines=[]
        for line in old.splitlines():
            key=line.split('=',1)[0].strip() if '=' in line and not line.strip().startswith('#') else None
            if key in data: continue
            lines.append(line)
        for k,v in data.items():
            if v!='': lines.append(f'{k}="{v}"')
        CONFIG.write_text('\n'.join(lines)+'\n')
        return redirect(url_for('settings', saved='1'))
    l=lang(); cfg=CONFIG.read_text(errors='ignore') if CONFIG.exists() else ''
    return render_template('settings.html', t=I18N[l], lang=l, cfg=cfg, page='settings')

@app.route('/logs')
def logs():
    l=lang(); files=sorted(LOG_DIR.glob('*.log'), key=lambda p:p.stat().st_mtime, reverse=True)
    content=''; name=request.args.get('file')
    if name and (LOG_DIR/name).exists(): content=(LOG_DIR/name).read_text(errors='ignore')[-50000:]
    return render_template('logs.html', t=I18N[l], lang=l, files=files, content=content, page='logs')

@app.route('/action/<name>', methods=['POST'])
def action(name):
    log=start_task(name)
    return redirect(url_for('logs', file=log or 'web.log'))

@app.route('/api/status')
def api_status(): return jsonify(status())

if __name__ == '__main__':
    print(f'Avid Kiya DevHub Web Panel: http://{HOST}:{PORT}')
    app.run(host=HOST, port=PORT)
