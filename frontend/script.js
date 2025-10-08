// script.js — upload → base64 → POST to API → render top-5

const input = document.getElementById('file');
const chooseBtn = document.getElementById('choose');
const predictBtn = document.getElementById('predict');
const previewImg = document.getElementById('preview');
const resultsEl = document.getElementById('results');
const drop = document.getElementById('drop');

let selectedFile = null;

/* ---------- UI helpers ---------- */

// Enable/disable the whole UI while predicting
function setLoading(isLoading) {
  document.body.classList.toggle('loading', isLoading);
  predictBtn.disabled = isLoading || !selectedFile;
  chooseBtn.disabled = isLoading;
}

// Render top-5 results (expects [{label, prob}, ...])
function renderResults(items) {
  resultsEl.innerHTML = '';

  if (!Array.isArray(items) || items.length === 0) {
    resultsEl.innerHTML = `<div class="item">No predictions.</div>`;
    return;
  }

  items.slice(0, 5).forEach(({ label, prob }) => {
    const pct = Math.round((Number(prob) || 0) * 1000) / 10; // 0.754 -> 75.4
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

// Show an error message inside results panel
function renderError(message) {
  resultsEl.innerHTML = `<div class="item">Error: ${message || 'Unknown error'}</div>`;
}

/* ---------- File handling ---------- */

// Open native file dialog
chooseBtn.addEventListener('click', () => input.click());

// On file select
input.addEventListener('change', () => {
  const f = input.files?.[0];
  if (!f) return;
  selectedFile = f;
  previewImg.src = URL.createObjectURL(f);
  predictBtn.disabled = false;
});

// Drag & drop (optional, if dropzone exists)
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
    // Reflect dropped file into the hidden input for consistency
    const dt = new DataTransfer();
    dt.items.add(f);
    input.files = dt.files;

    selectedFile = f;
    previewImg.src = URL.createObjectURL(f);
    predictBtn.disabled = false;
  });
}

// Convert file → base64 (strip "data:*;base64," prefix)
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

/* ---------- API call ---------- */

// Normalize various Lambda/APIGW proxy shapes into pure JSON
async function parseApiResponse(resp) {
  // Try normal JSON first
  let data;
  try {
    data = await resp.json();
  } catch {
    return { error: `HTTP ${resp.status}` };
  }

  // Lambda proxy can return { statusCode, body } where body is JSON string
  if (data && typeof data === 'object' && 'statusCode' in data && typeof data.body === 'string') {
    try {
      const parsed = JSON.parse(data.body);
      return parsed;
    } catch {
      // If body isn't JSON, just surface raw body
      return data.body;
    }
  }

  return data;
}

/* ---------- Predict ---------- */

predictBtn.addEventListener('click', async () => {
  if (!selectedFile) return;

  try {
    setLoading(true);

    const b64 = await fileToBase64(selectedFile);

    // Prefer base64 from local file; your backend also supports image_url
    const payload = { image_base64: b64 };

    const resp = await fetch(window.DEMO_API_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await parseApiResponse(resp);

    // If backend returned an error shape
    if (data && data.error) {
      renderError(data.error);
      return;
    }

    // Render predictions (expects array of {label, prob})
    renderResults(data);
  } catch (e) {
    renderError(e?.message || String(e));
  } finally {
    setLoading(false);
  }
});