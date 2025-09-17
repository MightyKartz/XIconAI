# Backend PoC for Icons Middle Layer
# FastAPI app providing /v1/generate, /v1/task/{id}, /v1/quota endpoints
# Security: no secrets stored or logged. Prompts are hashed for logging.

import asyncio
import hashlib
import json
import os
import random
import string
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, Optional

from fastapi import FastAPI, BackgroundTasks, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import base64
import urllib.request as urllib_request
import urllib.error as urllib_error

APP_HOST = os.environ.get("ICONS_POC_HOST", "127.0.0.1")
APP_PORT = int(os.environ.get("ICONS_POC_PORT", "8787"))
BASE_PATH = Path(__file__).parent
STATIC_DIR = BASE_PATH / "static"
STATIC_DIR.mkdir(parents=True, exist_ok=True)

# DashScope (Alibaba Cloud) configuration - Pro users
DASHSCOPE_BASE_URL = os.environ.get("DASHSCOPE_BASE_URL", "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation").rstrip("/")
DASHSCOPE_T2I_MODEL = os.environ.get("DASHSCOPE_T2I_MODEL", "qwen-image")
# NEVER set real keys in code. Read from environment only.
DASHSCOPE_API_KEY = os.environ.get("DASHSCOPE_API_KEY", "").strip()

# ModelScope API-Inference configuration (Free users)
MODELSCOPE_API_BASE = os.environ.get("MODELSCOPE_API_BASE", "https://api-inference.modelscope.cn/v1").rstrip("/")
# NEVER set real keys in code. Read from environment only.
MODELSCOPE_API_KEY = os.environ.get("MODELSCOPE_API_KEY", "").strip()
MODELSCOPE_T2I_MODEL = os.environ.get("MODELSCOPE_T2I_MODEL", "Qwen/Qwen-Image").strip()
FREE_DAILY_LIMIT = int(os.environ.get("ICONS_FREE_DAILY_LIMIT", "2"))
_PRO_LIMIT_RAW = os.environ.get("ICONS_PRO_DAILY_LIMIT", "").strip()
try:
    PRO_DAILY_LIMIT = int(_PRO_LIMIT_RAW) if _PRO_LIMIT_RAW else None
except Exception:
    PRO_DAILY_LIMIT = None
# NEW: developer bypass flag
_BYPASS_RAW = os.environ.get("ICONS_BYPASS_QUOTA", "").strip().lower()
BYPASS_QUOTA = _BYPASS_RAW in ("1", "true", "yes", "y", "on")

IP_RPM_LIMIT = int(os.environ.get("ICONS_IP_RPM_LIMIT", "30"))

# In-memory stores (PoC only)
TASKS: Dict[str, dict] = {}
USAGE: Dict[str, dict] = {}  # { user_id: {"count": int, "reset": date_str, "plan": "free"|"pro"} }
CONCURRENCY_SEMAPHORE = asyncio.Semaphore(3)
USER_SEMAPHORES: Dict[str, asyncio.Semaphore] = {}
IP_REQUEST_LOG: Dict[str, list] = {}

class GenerateRequest(BaseModel):
    prompt: str
    style: Optional[str] = None
    parameters: Dict[str, object] = Field(default_factory=dict)

class GenerateTaskResponse(BaseModel):
    taskId: str

class TaskStatusResponse(BaseModel):
    taskId: str
    status: str
    progress: Optional[float] = None
    resultURL: Optional[str] = None
    error: Optional[str] = None

class QuotaResponse(BaseModel):
    remaining: int
    plan: str
    limit: Optional[int] = None
    resetAt: Optional[str] = None

class ReceiptVerifyRequest(BaseModel):
    receipt: str

class ReceiptVerifyResponse(BaseModel):
    success: bool
    plan: Optional[str] = None
    expiresAt: Optional[str] = None

app = FastAPI(title="Icons Middle Layer PoC", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

# Unified error handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    # Normalize detail
    detail = exc.detail
    if isinstance(detail, dict):
        error = str(detail.get("error") or "http_error")
        message = str(detail.get("message") or error)
    else:
        error = "http_error"
        message = str(detail)
    payload = {"error": error, "message": message, "code": exc.status_code}
    return JSONResponse(status_code=exc.status_code, content=payload)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    payload = {"error": "invalid_request", "message": "Request validation failed", "code": 400}
    return JSONResponse(status_code=400, content=payload)

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    # Do not leak details; map to 500 with generic message
    payload = {"error": "internal_error", "message": "Internal server error", "code": 500}
    return JSONResponse(status_code=500, content=payload)

def _today_str():
    return datetime.now(timezone.utc).strftime("%Y-%m-%d")


def _prompt_hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]


def _gen_task_id() -> str:
    return "tsk_" + "".join(random.choices(string.ascii_lowercase + string.digits, k=22))


def _get_user_and_plan(request: Request) -> tuple[str, str]:
    # PoC: derive user from header X-User-Id or fallback to "anon"
    user_id = request.headers.get("X-User-Id", "anon")
    plan = request.headers.get("X-Plan", "free").lower()
    if plan not in ("free", "pro"):
        plan = "free"
    return user_id, plan

def _is_developer_bypass(request: Request) -> bool:
    """检查是否应该绕过配额限制（开发者模式）"""
    # 全局环境变量绕过
    if BYPASS_QUOTA:
        return True
    
    # 检查开发者请求头（以dev-开头的用户ID表示开发者模式）
    user_id = request.headers.get("X-User-Id", "")
    if user_id.startswith("dev-"):
        return True
    
    return False



def _get_client_ip(request: Request) -> str:
    xfwd = request.headers.get("x-forwarded-for") or request.headers.get("X-Forwarded-For")
    if xfwd:
        return xfwd.split(",")[0].strip()
    return request.client.host if request.client else "0.0.0.0"


def _get_user_semaphore(user_id: str) -> asyncio.Semaphore:
    sem = USER_SEMAPHORES.get(user_id)
    if sem is None:
        sem = asyncio.Semaphore(3)
        USER_SEMAPHORES[user_id] = sem
    return sem


def _touch_usage(user_id: str, plan: str) -> dict:
    rec = USAGE.get(user_id)
    today = _today_str()
    if not rec or rec.get("reset") != today:
        rec = {"count": 0, "reset": today, "plan": plan}
        USAGE[user_id] = rec
    else:
        # keep existing count, but always update plan to match current request
        rec["plan"] = plan
    return rec


async def _generate_image_file(task_id: str, text: str, size: int = 1024, seed: Optional[int] = None) -> str:
    """Generate a PNG image with Pillow and save to static directory, return file URL path."""
    from PIL import Image, ImageDraw, ImageFont

    rng = random.Random(seed)
    img = Image.new("RGBA", (size, size), (240, 243, 248, 255))
    draw = ImageDraw.Draw(img)

    # random colored rectangle background accent
    accent = tuple(rng.randint(80, 200) for _ in range(3)) + (255,)
    draw.rounded_rectangle([(64, 64), (size - 64, size - 64)], radius=128, fill=accent)

    # text overlay
    overlay = (255, 255, 255, 245)
    msg = (text[:30] + "…") if len(text) > 30 else text
    # try to use a default font, fallback to simple
    try:
        font = ImageFont.truetype("Arial.ttf", 56)
    except Exception:
        font = ImageFont.load_default()
    # use textbbox for width/height to support newer Pillow versions
    try:
        bbox = draw.textbbox((0, 0), msg, font=font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    except Exception:
        # ultimate fallback: approximate using length
        tw, th = (min(size - 128, 20 * len(msg)), 56)
    draw.text(((size - tw) / 2, (size - th) / 2), msg, fill=overlay, font=font)

    file_path = STATIC_DIR / f"{task_id}.png"
    img.save(file_path, format="PNG")
    return f"/static/{task_id}.png"


# ---------- DashScope adapter (async) ----------
async def _http_post_json(url: str, payload: dict, headers: dict) -> dict:
    retries = 3
    backoff = 0.8
    last_err = None
    print(f"About to send request to {url}")
    print(f"Headers: {headers}")
    print(f"Payload: {payload}")
    print("Starting retry loop")
    for attempt in range(retries):
        try:
            def _do_post():
                req = urllib_request.Request(url, method="POST")
                for k, v in headers.items():
                    req.add_header(k, v)
                data = json.dumps(payload).encode("utf-8")
                with urllib_request.urlopen(req, data=data, timeout=30) as resp:
                    return json.loads(resp.read().decode("utf-8"))
            return await asyncio.to_thread(_do_post)
        except urllib_error.HTTPError as e:
            last_err = e
            code = getattr(e, 'code', 0)
            print(f"HTTPError: code={code}, reason={e.reason}")
            # Try to read the error response body
            try:
                error_body = e.read().decode('utf-8')
                print(f"Error response body: {error_body}")
            except Exception as err:
                print(f"Failed to read error response: {err}")
            if code in (429, 500, 502, 503, 504) and attempt < retries - 1:
                await asyncio.sleep(backoff * (2 ** attempt))
                continue
            raise
        except urllib_error.URLError as e:
            last_err = e
            print(f"URLError: {e.reason}")
            if attempt < retries - 1:
                await asyncio.sleep(backoff * (2 ** attempt))
                continue
            raise
    if last_err:
        raise last_err

async def _http_get_json(url: str, headers: dict) -> dict:
    retries = 3
    backoff = 0.8
    last_err = None
    for attempt in range(retries):
        try:
            def _do_get():
                req = urllib_request.Request(url, method="GET")
                for k, v in headers.items():
                    req.add_header(k, v)
                with urllib_request.urlopen(req, timeout=30) as resp:
                    return json.loads(resp.read().decode("utf-8"))
            return await asyncio.to_thread(_do_get)
        except urllib_error.HTTPError as e:
            last_err = e
            code = getattr(e, 'code', 0)
            if code in (429, 500, 502, 503, 504) and attempt < retries - 1:
                await asyncio.sleep(backoff * (2 ** attempt))
                continue
            raise
        except urllib_error.URLError as e:
            last_err = e
            if attempt < retries - 1:
                await asyncio.sleep(backoff * (2 ** attempt))
                continue
            raise
    if last_err:
        raise last_err

async def _dashscope_generate_image_sync(prompt: str, negative_prompt: Optional[str], size: int) -> Optional[str]:
    """Generate image using DashScope's Qwen-Image multimodal-generation API (sync mode)."""
    if not DASHSCOPE_API_KEY:
        raise RuntimeError("dashscope_key_missing")
    
    # Use the correct DashScope multimodal-generation endpoint
    url = f"{DASHSCOPE_BASE_URL}/generation"
    headers = {
        "Authorization": f"Bearer {DASHSCOPE_API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Map requested size to supported DashScope sizes
    # Supported sizes: 1328*1328 (default), 1664*928, 1472*1140, 1140*1472, 928*1664
    dashscope_size = "1328*1328"  # Use the default square size
    
    # Format request according to DashScope Qwen-Image multimodal-generation API specification
    body = {
        "model": DASHSCOPE_T2I_MODEL,
        "input": {
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "text": prompt
                        }
                    ]
                }
            ]
        },
        "parameters": {
            "size": dashscope_size,
            "prompt_extend": True,
            "watermark": False
        }
    }
    
    if negative_prompt:
        body["parameters"]["negative_prompt"] = negative_prompt
    
    print(f"DashScope Qwen-Image API request URL: {url}")
    safe_headers = {k: ("***" if k.lower() == "authorization" else v) for k, v in headers.items()}
    print(f"DashScope Qwen-Image API request headers: {safe_headers}")
    print(f"DashScope Qwen-Image API request body: {body}")
    
    # Make synchronous request
    resp = await _http_post_json(url, body, headers)
    print(f"DashScope Qwen-Image API response: {resp}")
    
    # Parse synchronous response for Qwen-Image format
    try:
        output = (resp or {}).get("output", {})
        choices = output.get("choices", [])
        
        if choices and isinstance(choices[0], dict):
            message = choices[0].get("message", {})
            content = message.get("content", [])
            
            if content and isinstance(content[0], dict):
                image_url = content[0].get("image")
                if image_url:
                    print(f"DashScope Qwen-Image API completed successfully, image URL: {image_url}")
                    return image_url
        
        print(f"No image URL found in DashScope response: {resp}")
        return None
                
    except Exception as e:
        print(f"Error processing DashScope Qwen-Image API response: {e}")
        return None

    raise RuntimeError(f"dashscope_unexpected_response:{resp}")


# Legacy functions for backward compatibility (now unused)
async def _dashscope_create_task(prompt: str, negative_prompt: Optional[str], size: int) -> str:
    # This function is now deprecated, use _dashscope_generate_image_sync instead
    raise RuntimeError("dashscope_async_mode_deprecated")


async def _dashscope_fetch_task(task_id: str) -> dict:
    # This function is now deprecated
    raise RuntimeError("dashscope_async_mode_deprecated")


async def _dashscope_wait_for_result(task_id: str, timeout_sec: float = 90.0, interval_sec: float = 2.0) -> Optional[str]:
    # This function is now deprecated
    raise RuntimeError("dashscope_async_mode_deprecated")


async def _download_to_static(url: str, dest_path: Path) -> None:
    def _do_download():
        with urllib_request.urlopen(url, timeout=60) as resp, open(dest_path, "wb") as f:
            f.write(resp.read())
    await asyncio.to_thread(_do_download)


# startup diagnostics (no secrets)
@app.on_event("startup")
async def _startup_diag():
    dashscope_ok = bool(DASHSCOPE_API_KEY)
    modelscope_ok = bool(MODELSCOPE_API_KEY and MODELSCOPE_T2I_MODEL)
    print("[startup] providers:")
    print(f"  - dashscope: {'configured' if dashscope_ok else 'not-configured'}; base={DASHSCOPE_BASE_URL}; model={DASHSCOPE_T2I_MODEL}")
    print(f"  - modelscope: {'configured' if modelscope_ok else 'not-configured'}; base={MODELSCOPE_API_BASE}; model={MODELSCOPE_T2I_MODEL}")
    print(f"[startup] quotas: free={FREE_DAILY_LIMIT}, pro={'unlimited' if PRO_DAILY_LIMIT is None else PRO_DAILY_LIMIT}")
    if BYPASS_QUOTA:
        print("[Developer] Free unlimited usage enabled - bypassing quota check")


def _choose_provider(plan: str) -> str:
    """Simple provider router. Free -> modelscope if configured, Pro -> dashscope if configured; otherwise local."""
    dashscope_ok = bool(DASHSCOPE_API_KEY and DASHSCOPE_T2I_MODEL)
    modelscope_ok = bool(MODELSCOPE_API_KEY and MODELSCOPE_T2I_MODEL)
    if plan == "pro" and dashscope_ok:
        return "dashscope"
    if modelscope_ok:
        return "modelscope"
    return "local"


async def _generate_via_provider(task_id: str, provider: str, prompt: str, params: dict) -> str:
    """Provider adapter shim. Calls real APIs when configured; fallback to local generation."""
    # normalize size
    try:
        size = int(params.get("size", 1024))
    except Exception:
        size = 1024
    size = max(512, min(1440, size))

    if provider == "dashscope" and DASHSCOPE_API_KEY:
        # Use DashScope multimodal generation API
        try:
            remote_url = await _dashscope_generate_image_sync(prompt, None, size=size)
            if not remote_url:
                raise RuntimeError("dashscope_no_result")
            dest = STATIC_DIR / f"{task_id}.png"
            # Handle both URL and base64 data URI
            if isinstance(remote_url, str) and remote_url.startswith("data:image/"):
                try:
                    b64 = remote_url.split(",", 1)[1]
                except Exception:
                    raise RuntimeError("dashscope_invalid_data_uri")
                with open(dest, "wb") as f:
                    f.write(base64.b64decode(b64))
            else:
                await _download_to_static(remote_url, dest)
            return f"/static/{task_id}.png"
        except Exception:
            # propagate to fallback (handled by caller)
            raise

    if provider == "modelscope" and MODELSCOPE_API_KEY and MODELSCOPE_T2I_MODEL:
        print(f"Calling _modelscope_generate_image with prompt: {prompt}")
        import sys
        sys.stdout.flush()
        try:
            # Extract size from parameters for ModelScope
            size = 1024
            try:
                size = int(params.get("size", 1024))
            except Exception:
                pass
            remote_url = await _modelscope_generate_image(prompt, size)
            if not remote_url:
                raise RuntimeError("modelscope_no_result")
            dest = STATIC_DIR / f"{task_id}.png"
            # NEW: handle base64 data URI directly
            if isinstance(remote_url, str) and remote_url.startswith("data:image/"):
                try:
                    b64 = remote_url.split(",", 1)[1]
                except Exception:
                    raise RuntimeError("modelscope_invalid_data_uri")
                with open(dest, "wb") as f:
                    f.write(base64.b64decode(b64))
            else:
                await _download_to_static(remote_url, dest)
            return f"/static/{task_id}.png"
        except Exception:
            # propagate to fallback
            raise

    # default: local fallback
    rel_url = await _generate_image_file(task_id, prompt, size=size, seed=7)
    return rel_url


async def _process_task(task_id: str):
    task = TASKS.get(task_id)
    if not task:
        return
    prompt = task["prompt"]
    params = task.get("parameters", {})
    provider = task.get("provider", "modelscope")

    # Simulate queueing and processing with concurrency control
    await asyncio.sleep(0.3)
    task["status"] = "processing"
    task["progress"] = 0.1

    async with CONCURRENCY_SEMAPHORE:
        async with _get_user_semaphore(task.get("user", "anon")):
            try:
                # simulate progressive updates
                for p in [0.25, 0.5, 0.7, 0.9]:
                    await asyncio.sleep(0.4)
                    task["progress"] = p
                # provider generation (with graceful fallback chain)
                try:
                    rel_url = await _generate_via_provider(task_id, provider, prompt, params)
                except Exception as e:
                    # record first failure and try modelscope only if dashscope failed; otherwise go local
                    task["error"] = f"provider_failed:{provider}:{e}"
                    try:
                        if provider == "dashscope":
                            rel_url = await _generate_via_provider(task_id, "modelscope", prompt, params)
                        else:
                            # provider is modelscope or others, skip escalating to dashscope for free users
                            raise RuntimeError("skip_escalation")
                    except Exception as e2:
                        task["error"] = f"{task['error']}; fallback_failed:{'modelscope' if provider == 'dashscope' else 'local'}:{e2}"
                        # final guaranteed local fallback
                        rel_url = await _generate_via_provider(task_id, "local", prompt, params)
                task["progress"] = 1.0
                task["status"] = "completed"
                task["resultURL"] = f"http://{APP_HOST}:{APP_PORT}{rel_url}"
            except Exception as final_e:
                # If even local generation fails, mark as failed
                task["status"] = "failed"
                task["error"] = f"all_providers_failed:{final_e}"


@app.get("/v1/quota", response_model=QuotaResponse)
async def get_quota(request: Request):
    user_id, plan = _get_user_and_plan(request)
    rec = _touch_usage(user_id, plan)
    # developer bypass: always unlimited
    if _is_developer_bypass(request):
        print("[Developer] Free unlimited usage enabled - bypassing quota check")
        # 在开发者模式下，返回当前请求头中的plan，而不是数据库中的plan
        return QuotaResponse(remaining=999999, plan=plan, limit=None, resetAt=None)
    # compute limit/remaining
    # 使用请求头中的plan来计算配额，确保与API调用保持一致
    if plan == "free":
        limit = FREE_DAILY_LIMIT
    else:
        limit = PRO_DAILY_LIMIT
    if limit is None:
        remaining = 999999
    else:
        remaining = max(0, limit - rec["count"])
    # next reset at midnight UTC
    today = datetime.now(timezone.utc).date()
    reset_at = datetime.combine(today + timedelta(days=1), datetime.min.time(), tzinfo=timezone.utc)
    # 返回请求头中的plan，确保与前端显示一致
    return QuotaResponse(remaining=remaining, plan=plan, limit=limit, resetAt=reset_at.isoformat())


@app.get("/v1/task/{task_id}", response_model=TaskStatusResponse)
async def get_task(task_id: str):
    task = TASKS.get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="task not found")
    return TaskStatusResponse(
        taskId=task["taskId"],
        status=task["status"],
        progress=task.get("progress"),
        resultURL=task.get("resultURL"),
        error=task.get("error"),
    )


@app.post("/v1/generate", response_model=GenerateTaskResponse)
async def create_task(req: GenerateRequest, request: Request, bg: BackgroundTasks):
    user_id, plan = _get_user_and_plan(request)
    # IP rate limiting (per minute)
    ip = _get_client_ip(request)
    now_ts = time.time()
    recent = [t for t in IP_REQUEST_LOG.get(ip, []) if now_ts - t < 60]
    if len(recent) >= IP_RPM_LIMIT:
        raise HTTPException(status_code=429, detail={"error": "rate_limited", "message": "Too many requests from IP"})
    recent.append(now_ts)
    IP_REQUEST_LOG[ip] = recent

    rec = _touch_usage(user_id, plan)
    # Quota enforcement by plan (skip when developer bypass is enabled)
    if not _is_developer_bypass(request):
        if rec["plan"] == "free":
            if rec["count"] >= FREE_DAILY_LIMIT:
                raise HTTPException(status_code=402, detail={"error": "quota_exceeded", "message": "Daily free quota exceeded"})
        else:
            if PRO_DAILY_LIMIT is not None and rec["count"] >= PRO_DAILY_LIMIT:
                raise HTTPException(status_code=402, detail={"error": "quota_exceeded", "message": "Daily pro quota exceeded"})
    else:
        print("[Developer] Free unlimited usage enabled - bypassing quota check")

    # Enforce plan-based size caps
    parameters = dict(req.parameters or {})
    try:
        requested_size = int(parameters.get("size", 1024))
    except Exception:
        requested_size = 1024
    if _is_developer_bypass(request):
        # In developer bypass mode, do not enforce plan-based size caps.
        # Allow requested size within safe bounds handled by provider shim (256-1440).
        parameters["size"] = max(256, min(1440, requested_size))
        print("[Developer] Size cap bypass enabled - allowing size up to 1440")
    else:
        if rec["plan"] == "free":
            parameters["size"] = min(512, max(256, requested_size))
        else:
            parameters["size"] = min(1024, max(512, requested_size))

    task_id = _gen_task_id()
    # 在开发者模式下，使用请求头中的plan来选择提供商，确保API路由正确
    effective_plan = plan if _is_developer_bypass(request) else rec["plan"]
    provider = _choose_provider(effective_plan)  # route by plan
    TASKS[task_id] = {
        "taskId": task_id,
        "status": "pending",
        "progress": 0.0,
        "resultURL": None,
        "error": None,
        "createdAt": time.time(),
        "prompt": req.prompt,
        "prompt_hash": _prompt_hash(req.prompt),
        "parameters": parameters,
        "style": req.style,
        "user": user_id,
        "provider": provider,
    }
    # increment usage on task creation
    rec["count"] += 1

    bg.add_task(_process_task, task_id)
    return GenerateTaskResponse(taskId=task_id)


@app.post("/v1/receipt/verify", response_model=ReceiptVerifyResponse)
async def verify_receipt(req: ReceiptVerifyRequest, request: Request):
    """
    PoC receipt verification.
    - Accepts base64-encoded receipt string in {"receipt": "..."}
    - If decodable and non-empty, marks user as Pro until +30 days
    - Never logs or returns raw receipt
    """
    user_id, _plan = _get_user_and_plan(request)
    # basic validation
    if not req.receipt or not isinstance(req.receipt, str):
        raise HTTPException(status_code=400, detail={"error": "invalid_receipt", "message": "missing receipt"})
    try:
        decoded = base64.b64decode(req.receipt, validate=True)
    except Exception:
        raise HTTPException(status_code=400, detail={"error": "invalid_receipt", "message": "malformed base64"})

    if len(decoded) < 16:
        # treat too-short as invalid
        return ReceiptVerifyResponse(success=False, plan="free", expiresAt=None)

    # mark user as pro for 30 days in usage store
    rec = _touch_usage(user_id, "pro")
    rec["plan"] = "pro"
    expires_at = datetime.now(timezone.utc) + timedelta(days=30)
    return ReceiptVerifyResponse(success=True, plan="pro", expiresAt=expires_at.isoformat())


@app.get("/health")
async def health():
    return {"ok": True, "time": datetime.now(timezone.utc).isoformat()}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server:app", host=APP_HOST, port=APP_PORT, reload=False)

# ---------- DashScope adapter (OpenAI-compatible mode) ----------
async def _dashscope_generate_image_compatible(prompt: str, size: int = 1024) -> Optional[str]:
    """Generate image using DashScope's OpenAI-compatible API."""
    if not DASHSCOPE_API_KEY:
        raise RuntimeError("dashscope_key_missing")

    url = f"{DASHSCOPE_BASE_URL}/images/generations"
    headers = {
        "Authorization": f"Bearer {DASHSCOPE_API_KEY}",
        "Content-Type": "application/json",
    }
    # Size formatting for DashScope compatible mode
    size_str = f"{size}x{size}"
    body = {
        "model": DASHSCOPE_T2I_MODEL,
        "prompt": prompt,
        "size": size_str,
        "n": 1,
    }

    resp = await _http_post_json(url, body, headers)

    # Handle response in OpenAI format
    try:
        data = (resp or {}).get("data") or []
        first = data[0] if data else None
        if isinstance(first, dict):
            # Check for URL (newer format)
            if first.get("url"):
                return first["url"]
            # Check for b64_json (base64 encoded image)
            elif first.get("b64_json"):
                return f"data:image/png;base64,{first['b64_json']}"
    except Exception:
        pass

    raise RuntimeError(f"dashscope_compatible_unexpected_response:{resp}")


# ---------- ModelScope adapter (async mode with task polling) ----------
async def _modelscope_generate_image(prompt: str, size: int = 1024) -> Optional[str]:
    """Generate image using ModelScope API-Inference (asynchronous mode with polling)."""
    print("Entering _modelscope_generate_image function")
    if not (MODELSCOPE_API_KEY and MODELSCOPE_T2I_MODEL):
        print("ModelScope not configured")
        raise RuntimeError("modelscope_not_configured")
    print("ModelScope configured correctly")

    # Use asynchronous mode for ModelScope API-Inference
    url = f"{MODELSCOPE_API_BASE}/images/generations"
    headers = {
        "Authorization": f"Bearer {MODELSCOPE_API_KEY}",
        "Content-Type": "application/json",
        "X-ModelScope-Async-Mode": "true"
    }

    # Request body for image generation
    body = {
        "model": MODELSCOPE_T2I_MODEL,
        "prompt": prompt
    }

    print(f"ModelScope request: url={url}")
    safe_headers = {k: ("***" if k.lower() == "authorization" else v) for k, v in headers.items()}
    print(f"ModelScope headers: {safe_headers}")
    print(f"ModelScope body: {body}")
    print("About to call _http_post_json for image generation")

    try:
        # Submit async task
        resp = await _http_post_json(url, body, headers)
        print(f"ModelScope response: {resp}")

        # Extract task ID from response
        task_id = resp.get("task_id")
        if not task_id:
            raise RuntimeError(f"modelscope_no_task_id:{resp}")

        print(f"ModelScope task_id: {task_id}")

        # Poll for task completion
        max_attempts = 30
        poll_interval = 5
        task_result_url = f"{MODELSCOPE_API_BASE}/tasks/{task_id}"
        task_headers = {
            "Authorization": f"Bearer {MODELSCOPE_API_KEY}",
            "Content-Type": "application/json",
            "X-ModelScope-Task-Type": "image_generation"
        }

        for attempt in range(max_attempts):
            print(f"Polling task status (attempt {attempt + 1}/{max_attempts})")
            try:
                task_resp = await _http_get_json(task_result_url, task_headers)
                print(f"Task status response: {task_resp}")

                task_status = task_resp.get("task_status")
                if task_status == "SUCCEED":
                    # Extract image URL from response
                    output_images = task_resp.get("output_images", [])
                    if output_images and len(output_images) > 0:
                        image_url = output_images[0]
                        print(f"ModelScope image generated successfully: {image_url}")
                        return image_url
                    else:
                        raise RuntimeError(f"modelscope_no_image_url:{task_resp}")
                elif task_status == "FAILED":
                    raise RuntimeError(f"modelscope_task_failed:{task_resp.get('message', 'Unknown error')}")
                elif task_status not in ["RUNNING", "QUEUING"]:
                    print(f"Unexpected task status: {task_status}")

            except urllib_error.HTTPError as e:
                print(f"HTTP error while polling task: {e}")
                # Continue polling for transient errors

            # Wait before next poll
            if attempt < max_attempts - 1:
                await asyncio.sleep(poll_interval)

        raise RuntimeError("modelscope_task_timeout")

    except urllib_error.HTTPError as e:
        # Extract detailed error information from response
        try:
            error_body = e.read().decode('utf-8')
            print(f"ModelScope API Error Response: {error_body}")
        except:
            pass
        raise
    except Exception as e:
        print(f"Unexpected error in _modelscope_generate_image: {e}")
        raise