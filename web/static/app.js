async function refreshStatus(){try{let r=await fetch('/api/status');let j=await r.json();console.log('status',j)}catch(e){}}
setInterval(refreshStatus,15000);
