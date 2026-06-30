#!/usr/bin/env python3
"""AvidKiya DevHub Desktop GUI for Windows/macOS/Linux.
A lightweight Python/Tk launcher that can be packaged as EXE with PyInstaller.
"""
from __future__ import annotations
import os, pathlib, queue, shutil, subprocess, sys, threading, tkinter as tk, webbrowser
from tkinter import ttk, messagebox
ROOT = pathlib.Path(__file__).resolve().parents[1]
PC = ROOT/'scripts'/'avid_pc.py'
LOGQ: queue.Queue[str] = queue.Queue()

def py(): return shutil.which('python') or shutil.which('python3') or sys.executable

def run_bg(args):
    def worker():
        LOGQ.put('$ ' + ' '.join(map(str,args)) + '\n')
        try:
            p=subprocess.Popen(args, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            assert p.stdout
            for line in p.stdout: LOGQ.put(line)
            LOGQ.put(f'\n[exit {p.wait()}]\n')
        except Exception as e: LOGQ.put(f'ERROR: {e}\n')
    threading.Thread(target=worker, daemon=True).start()

def main():
    root=tk.Tk(); root.title('AvidKiya DevHub'); root.geometry('920x620'); root.minsize(720,480)
    try: root.iconbitmap(default='')
    except Exception: pass
    style=ttk.Style(); style.theme_use('clam')
    style.configure('TFrame', background='#070914'); style.configure('TLabel', background='#070914', foreground='#eff8ff')
    style.configure('TButton', padding=10); style.configure('Title.TLabel', font=('Segoe UI',24,'bold'), foreground='#00e5ff')
    mainf=ttk.Frame(root); mainf.pack(fill='both', expand=True)
    top=ttk.Frame(mainf); top.pack(fill='x', padx=18, pady=14)
    ttk.Label(top, text='AvidKiya DevHub', style='Title.TLabel').pack(anchor='w')
    ttk.Label(top, text='PC / VS Code / Termux companion launcher — App, Web, CLI, Doctor, Packaging').pack(anchor='w')
    body=ttk.Frame(mainf); body.pack(fill='both', expand=True, padx=18, pady=8)
    left=ttk.Frame(body); left.pack(side='left', fill='y', padx=(0,14))
    right=ttk.Frame(body); right.pack(side='right', fill='both', expand=True)
    commands=[
        ('🚀 Open App/Web Panel', [py(), str(PC), 'app']),
        ('🌐 Start Web Panel', [py(), str(PC), 'web']),
        ('💻 Open CLI/TUI', [py(), str(PC), 'cli']),
        ('🩺 Doctor / Self-test', [py(), str(ROOT/'tools'/'qa_selftest.py')]),
        ('📊 PC Status', [py(), str(PC), 'status']),
        ('📦 Build EXE helper', [py(), str(PC), 'build-exe']),
    ]
    for text,args in commands:
        ttk.Button(left, text=text, command=lambda a=args: run_bg(a)).pack(fill='x', pady=5)
    ttk.Button(left, text='📁 Open Project Folder', command=lambda: webbrowser.open(ROOT.as_uri())).pack(fill='x', pady=5)
    ttk.Button(left, text='Exit', command=root.destroy).pack(fill='x', pady=20)
    log=tk.Text(right, bg='#02040a', fg='#eff8ff', insertbackground='#eff8ff', wrap='word')
    log.pack(fill='both', expand=True)
    log.insert('end','AvidKiya DevHub Desktop ready.\n')
    def pump():
        try:
            while True:
                log.insert('end', LOGQ.get_nowait()); log.see('end')
        except queue.Empty: pass
        root.after(120,pump)
    pump(); root.mainloop()
if __name__=='__main__': main()
