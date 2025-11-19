const input = document.getElementById('file');
const chooseBtn = document.getElementById('choose');
const predictBtn = document.getElementById('predict');
const previewImg = document.getElementById('preview');
const resultsEl = document.getElementById('results');
const drop = document.getElementById('drop');

let selectedFile = null;

function setLoading(isLoading) {
  document.body.classList.toggle('loading', isLoading);
  predictBtn.disabled = isLoading || !selectedFile;
  chooseBtn.disabled = isLoading;
}

function renderResults(items) {
  resultsEl.innerHTML = '';
  if (!Array.isArray(items) || items.length === 0) {
    resultsEl.innerHTML = `<div class="item">No predictions.</div>`;
    return;
  }
  items.slice(0, 5).forEach(({ label, prob }) => {
    const pct = Math.round((Number(prob) || 0) * 1000) / 10;
    const row = document.createElement('div');
    row.className = 'item';
    row.innerHTML = `
      <div class="row">
        <div class="label">${label}</div>
        <div class="score">${pct}%</div>
      </div>
      <div class="bar"><div class="fill" style="width:${Math.min(100, pct)}%"></div></div>
    `;
    resultsEl.appendChild(row);
  });
}

function renderError(message) {
  resultsEl.innerHTML = `<div class="item">Error: ${message || 'Unknown error'}</div>`;
}

chooseBtn.addEventListener('click', () => input.click());

input.addEventListener('change', () => {
  const f = input.files?.[0];
  if (!f) return;
  selectedFile = f;
  previewImg.src = URL.createObjectURL(f);
  predictBtn.disabled = false;
});

if (drop) {
  drop.addEventListener('dragover', (e) => {
    e.preventDefault();
    drop.classList.add('drag');
  });
  drop.addEventListener('dragleave', () => drop.classList.remove('drag'));
  drop.addEventListener('drop', (e) => {
    e.preventDefault();
    drop.classList.remove('drag');
    const f = e.dataTransfer.files?.[0];
    if (!f) return;
    const dt = new DataTransfer();
    dt.items.add(f);
    input.files = dt.files;
    selectedFile = f;
    previewImg.src = URL.createObjectURL(f);
    predictBtn.disabled = false;
  });
}

function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => {
      const result = r.result || '';
      const base64 = String(result).includes(',')
        ? String(result).split(',')[1]
        : String(result);
      resolve(base64);
    };
    r.onerror = reject;
    r.readAsDataURL(file);
  });
}

async function parseApiResponse(resp) {
  let data;
  try {
    data = await resp.json();
  } catch {
    return { error: `HTTP ${resp.status}` };
  }
  if (data && typeof data === 'object' && 'statusCode' in data && typeof data.body === 'string') {
    try {
      return JSON.parse(data.body);
    } catch {
      return data.body;
    }
  }
  return data;
}

predictBtn.addEventListener('click', async () => {
  if (!selectedFile) return;
  try {
    setLoading(true);
    const b64 = await fileToBase64(selectedFile);
    const payload = { image_base64: b64 };
    const resp = await fetch(window.DEMO_API_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await parseApiResponse(resp);
    if (data && data.error) {
      renderError(data.error);
      return;
    }
    renderResults(data);
  } catch (e) {
    renderError(e?.message || String(e));
  } finally {
    setLoading(false);
  }
});