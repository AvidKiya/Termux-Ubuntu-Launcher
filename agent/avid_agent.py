#!/usr/bin/env python3
"""AvidKiya Agent - safe multi-provider orchestrator.
Supports official APIs / OpenAI-compatible endpoints / local or installed CLIs.
Does NOT scrape browser sessions or bypass paid APIs.
"""
import argparse, json, os, pathlib, subprocess, sys, textwrap, time, urllib.request

APP_DIR = pathlib.Path(os.environ.get("AK_APP_DIR", pathlib.Path.home()/".termux-avid-kiya"))
AGENT_DIR = APP_DIR/"agent"
CONFIG = AGENT_DIR/"agent-config.json"
MEMORY = AGENT_DIR/"memory.md"
LOGS = APP_DIR/"logs"
AGENT_DIR.mkdir(parents=True, exist_ok=True)
LOGS.mkdir(parents=True, exist_ok=True)

DEFAULT_CONFIG = {
  "manager": "mock-manager",
  "synthesizer": "mock-synthesizer",
  "workers": ["mock-worker-1", "mock-worker-2"],
  "providers": {
    "mock-manager": {"type":"mock", "role":"manager"},
    "mock-worker-1": {"type":"mock", "role":"worker"},
    "mock-worker-2": {"type":"mock", "role":"worker"},
    "mock-synthesizer": {"type":"mock", "role":"synthesizer"},
    "openrouter": {"type":"openai_compatible", "base_url":"https://openrouter.ai/api/v1/chat/completions", "model":"openai/gpt-4o-mini", "api_key_env":"OPENROUTER_API_KEY"},
    "deepseek": {"type":"openai_compatible", "base_url":"https://api.deepseek.com/chat/completions", "model":"deepseek-chat", "api_key_env":"DEEPSEEK_API_KEY"},
    "groq": {"type":"openai_compatible", "base_url":"https://api.groq.com/openai/v1/chat/completions", "model":"llama-3.1-70b-versatile", "api_key_env":"GROQ_API_KEY"},
    "mimo_cli": {"type":"cli", "cmd":"mimo", "note":"interactive CLI; use terminal for full experience"},
    "claude_cli": {"type":"cli", "cmd":"claude", "note":"official Claude Code CLI"},
    "gemini_cli": {"type":"cli", "cmd":"gemini", "note":"official Gemini CLI"}
  }
}

def load_config():
    if not CONFIG.exists():
        CONFIG.write_text(json.dumps(DEFAULT_CONFIG, indent=2, ensure_ascii=False), encoding="utf-8")
    return json.loads(CONFIG.read_text(encoding="utf-8"))

def save_config(cfg):
    CONFIG.write_text(json.dumps(cfg, indent=2, ensure_ascii=False), encoding="utf-8")

def log(msg):
    with open(LOGS/"agent.log", "a", encoding="utf-8") as f:
        f.write(f"[{time.strftime('%F %T')}] {msg}\n")

def call_mock(name, prompt, role):
    return f"[{name}/{role}]\nI received the task and produced a structured response.\n\nTask summary:\n{prompt[:900]}\n\nKey points:\n- Analyze requirements\n- Produce safe implementation plan\n- Return concise actionable output\n"

def call_openai_compatible(provider, prompt):
    key = os.environ.get(provider.get("api_key_env",""), "")
    if not key:
        return f"[missing API key: {provider.get('api_key_env')}] Set it in environment/config, then retry."
    payload = {
        "model": provider.get("model"),
        "messages": [
            {"role":"system", "content":"You are a helpful coding and security lab assistant. Be concise, safe, and practical."},
            {"role":"user", "content": prompt}
        ],
        "temperature": 0.3
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(provider.get("base_url"), data=data, headers={"Content-Type":"application/json", "Authorization":f"Bearer {key}"})
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            obj=json.loads(r.read().decode())
        return obj["choices"][0]["message"]["content"]
    except Exception as e:
        return f"[provider error] {e}"

def call_cli(provider, prompt):
    cmd = provider.get("cmd")
    if not cmd:
        return "[cli provider missing cmd]"
    # Non-interactive CLI support varies. We avoid pretending all CLIs support stdin automation.
    return f"[{cmd}] is installed as an interactive CLI provider. Run it from terminal for login/session-safe usage. Prompt was not auto-sent."

def call_provider(cfg, name, prompt, role="worker"):
    p = cfg.get("providers",{}).get(name)
    if not p: return f"[unknown provider: {name}]"
    typ=p.get("type")
    if typ=="mock": return call_mock(name, prompt, role)
    if typ=="openai_compatible": return call_openai_compatible(p, prompt)
    if typ=="cli": return call_cli(p, prompt)
    return f"[unsupported provider type: {typ}]"

def run_task(prompt):
    cfg=load_config()
    manager=cfg.get("manager")
    workers=cfg.get("workers",[])
    synth=cfg.get("synthesizer")
    plan_prompt=f"Break this user request into clear subtasks for workers. Return numbered tasks only.\n\nUSER REQUEST:\n{prompt}"
    plan=call_provider(cfg, manager, plan_prompt, "manager")
    outputs=[]
    for i,w in enumerate(workers,1):
        worker_prompt=f"You are worker #{i}. Use this plan and solve your part.\n\nPLAN:\n{plan}\n\nORIGINAL REQUEST:\n{prompt}"
        out=call_provider(cfg,w,worker_prompt,"worker")
        outputs.append((w,out))
    synth_prompt="Merge the worker outputs into one final high-quality answer. Remove duplication, keep best details, and produce a clear final result.\n\n"
    synth_prompt += f"ORIGINAL REQUEST:\n{prompt}\n\nMANAGER PLAN:\n{plan}\n\n"
    for w,out in outputs:
        synth_prompt += f"--- WORKER {w} ---\n{out}\n\n"
    final=call_provider(cfg,synth,synth_prompt,"synthesizer")
    report="# AvidKiya Agent Result\n\n## Prompt\n\n"+prompt+"\n\n## Manager Plan\n\n"+plan+"\n\n## Worker Outputs\n\n"
    for w,out in outputs: report += f"### {w}\n\n{out}\n\n"
    report += "## Final\n\n"+final+"\n"
    out_file=LOGS/("agent-result-"+time.strftime("%Y%m%d-%H%M%S")+".md")
    out_file.write_text(report, encoding="utf-8")
    print(report)
    print(f"\nSaved: {out_file}")

def add_provider(args):
    cfg=load_config()
    cfg.setdefault("providers",{})[args.name]={"type":"openai_compatible","base_url":args.base_url,"model":args.model,"api_key_env":args.api_key_env}
    save_config(cfg)
    print(f"Added provider: {args.name}")

def main():
    ap=argparse.ArgumentParser(description="AvidKiya Agent")
    sub=ap.add_subparsers(dest="cmd")
    sub.add_parser("init")
    sub.add_parser("config")
    r=sub.add_parser("run"); r.add_argument("prompt", nargs="*")
    a=sub.add_parser("add-provider"); a.add_argument("name"); a.add_argument("base_url"); a.add_argument("model"); a.add_argument("api_key_env")
    ns=ap.parse_args()
    if ns.cmd=="init": load_config(); print(CONFIG)
    elif ns.cmd=="config": print(CONFIG.read_text(encoding="utf-8") if CONFIG.exists() else json.dumps(load_config(),indent=2))
    elif ns.cmd=="add-provider": add_provider(ns)
    elif ns.cmd=="run":
        prompt=" ".join(ns.prompt).strip() or sys.stdin.read().strip()
        if not prompt: print("No prompt provided."); return 2
        run_task(prompt)
    else:
        ap.print_help()

if __name__=="__main__": main()
