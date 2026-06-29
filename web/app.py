#!/usr/bin/env python3
import os, subprocess, pathlib, datetime
from flask import Flask, render_template, request, redirect, url_for
APP_DIR = pathlib.Path(os.environ.get('AK_APP_DIR', str(pathlib.Path.home()/'.termux-avid-kiya')))
LOG_DIR = APP_DIR/'logs'; LOG_DIR.mkdir(parents=True, exist_ok=True)
HOST = os.environ.get('AK_WEB_HOST','127.0.0.1'); PORT = int(os.environ.get('AK_WEB_PORT','8765'))
app = Flask(__name__)
def exists(cmd): return subprocess.call(f'command -v {cmd} >/dev/null 2>&1', shell=True)==0
def ubuntu(cmd): return subprocess.call(f'proot-distro login ubuntu -- bash -lc {cmd!r} >/dev/null 2>&1', shell=True)==0
def status():
    return {'termux':exists('pkg'),'ubuntu':subprocess.call('proot-distro login ubuntu -- /bin/true >/dev/null 2>&1',shell=True)==0,'mimo':ubuntu('command -v mimo >/dev/null 2>&1 || [ -x /root/.mimocode/bin/mimo ]'),'claude':ubuntu('command -v claude >/dev/null 2>&1'),'gemini':ubuntu('command -v gemini >/dev/null 2>&1'),'nmap':ubuntu('command -v nmap >/dev/null 2>&1'),'sqlmap':ubuntu('command -v sqlmap >/dev/null 2>&1'),'john':ubuntu('command -v john >/dev/null 2>&1'),'radare2':ubuntu('command -v radare2 >/dev/null 2>&1')}
@app.route('/')
def index(): return render_template('index.html', s=status(), lang=request.args.get('lang','fa'), now=datetime.datetime.now())
@app.route('/logs')
def logs():
    files=sorted(LOG_DIR.glob('*.log')); content=''; name=request.args.get('file')
    if name and (LOG_DIR/name).exists(): content=(LOG_DIR/name).read_text(errors='ignore')[-20000:]
    return render_template('logs.html', files=files, content=content)
@app.route('/action/<name>', methods=['POST'])
def action(name):
    cmds={'ai':'avid ai','cyber':'avid cyber','health':'avid health','ubuntu':'avid ubuntu'}
    (LOG_DIR/'web.log').write_text('Run in terminal: '+cmds.get(name,'avid')+'\n', encoding='utf-8')
    return redirect(url_for('index'))
if __name__ == '__main__':
    print(f'Avid Kiya DevHub Web Panel: http://{HOST}:{PORT}')
    app.run(host=HOST, port=PORT)
