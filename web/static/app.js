async function refreshStatus(force=false){
  const grid=document.getElementById('statusGrid');
  if(!grid) return;
  if(force){grid.style.opacity=.55}
  try{
    const r=await fetch('/api/status'+(force?'?refresh=1':''));
    const data=await r.json();
    const s=data.status||{};
    grid.innerHTML=Object.entries(s).map(([k,v])=>`<div class="status-card ${v?'good':'miss'}"><span>${k}</span><b>${v?'OK':'Missing'}</b></div>`).join('');
  }catch(e){console.log(e)}
  grid.style.opacity=1;
}
setTimeout(()=>refreshStatus(false),800);
