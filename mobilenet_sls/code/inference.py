import io, json, base64, os
from PIL import Image, ImageFile
import torch
from torchvision import models, transforms

ImageFile.LOAD_TRUNCATED_IMAGES = True
torch.set_num_threads(1)
_device = torch.device("cpu")

_model = None
_classes = None
_tf = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485,0.456,0.406],
                         std=[0.229,0.224,0.225]),
])

def model_fn(model_dir):
    global _model, _classes
    print("LOADED inference.py VERSION=", os.environ.get("APP_VERSION","unset"), flush=True)
    weights = models.MobileNet_V2_Weights.IMAGENET1K_V1
    _model = models.mobilenet_v2(weights=weights).eval().to(_device)
    _classes = weights.meta.get("categories", None)
    return _model

def _to_bytes(x):
    if x is None: return b""
    if isinstance(x,(bytes,bytearray)): return bytes(x)
    if isinstance(x,str): return x.encode("utf-8",errors="ignore")
    try: return bytes(x)
    except: return b""

def input_fn(request_body, content_type=None):
    ct = (content_type or "").lower()
    if "application/x-image" in ct:
        return ("bytes", _to_bytes(request_body))
    if "application/json" in ct:
        try:
            obj = json.loads(request_body if isinstance(request_body,str)
                             else request_body.decode("utf-8",errors="ignore"))
        except: obj = {}
        b64 = obj.get("image_base64") or obj.get("b64")
        if b64:
            try: return ("bytes", base64.b64decode(b64))
            except: return ("bytes", b"")
        return ("bytes", b"")
    return ("bytes", _to_bytes(request_body))

def _infer_bytes(b: bytes):
    if not b: return []
    try:
        img = Image.open(io.BytesIO(b)).convert("RGB")
    except Exception:
        return []
    t = _tf(img).unsqueeze(0).to(_device)
    with torch.no_grad():
        probs = torch.softmax(_model(t), dim=1)[0]
        vals, idxs = torch.topk(probs, 5)
    out=[]
    for p,i in zip(vals.tolist(), idxs.tolist()):
        label = _classes[i] if _classes and i < len(_classes) else str(i)
        out.append({"label": label, "prob": float(p)})
    return out

def predict_fn(data, model):
    kind, payload = data
    if kind == "bytes":
        return _infer_bytes(payload)
    return []

def output_fn(prediction, accept=None):
    return json.dumps(prediction), "application/json"
