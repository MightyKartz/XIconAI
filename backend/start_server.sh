#!/bin/bash

# 计算脚本所在目录，确保从 backend/.env 加载变量
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# 加载 .env（如果存在）且不覆盖已存在的环境变量
if [ -f "$ENV_FILE" ]; then
  while IFS='=' read -r key value; do
    # 跳过注释与空行
    [ -z "$key" ] && continue
    case "$key" in \#*) continue;; esac
    # 去掉首尾空白（BSD sed 兼容写法）
    key="$(echo "$key" | sed -E 's/^\s+//; s/\s+$//')"
    value="$(echo "$value" | sed -E 's/^\s+//; s/\s+$//')"
    # 仅在未设置时导入
    if [ -z "${!key}" ]; then
      # 去掉包裹引号
      value="${value#\"}"; value="${value%\"}"
      value="${value#\'}"; value="${value%\'}"
      export "$key"="$value"
    fi
  done < <(grep -v '^[[:space:]]*#' "$ENV_FILE" | sed -e '/^[[:space:]]*$/d')
fi

# 设置ModelScope API环境变量 - Free用户（可被外部环境或 .env 覆盖）
export MODELSCOPE_API_BASE=${MODELSCOPE_API_BASE:-"https://api-inference.modelscope.cn/v1"}
# 不在脚本中硬编码密钥，如需本地跑通，请在 .env 设置 MODELSCOPE_API_KEY
# export MODELSCOPE_API_KEY=${MODELSCOPE_API_KEY:-""}
export MODELSCOPE_T2I_MODEL=${MODELSCOPE_T2I_MODEL:-"MAILAND/majicflus_v1"}

# 设置DashScope API环境变量 - Pro用户（可被外部环境或 .env 覆盖）
# 按后端实现：多模态生成（multimodal-generation）服务路径，后续会在代码中拼接 /generation
export DASHSCOPE_BASE_URL=${DASHSCOPE_BASE_URL:-"https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation"}
# 不在脚本中硬编码密钥，如需本地跑通，请在 .env 设置 DASHSCOPE_API_KEY
# export DASHSCOPE_API_KEY=${DASHSCOPE_API_KEY:-""}
export DASHSCOPE_T2I_MODEL=${DASHSCOPE_T2I_MODEL:-"qwen-image"}

# 其他配置（可被外部覆盖）
export ICONS_POC_HOST=${ICONS_POC_HOST:-"127.0.0.1"}
export ICONS_POC_PORT=${ICONS_POC_PORT:-"8787"}
export ICONS_FREE_DAILY_LIMIT=${ICONS_FREE_DAILY_LIMIT:-"2"}
export ICONS_PRO_DAILY_LIMIT=${ICONS_PRO_DAILY_LIMIT:-""}
export ICONS_IP_RPM_LIMIT=${ICONS_IP_RPM_LIMIT:-"30"}
# 本地开发默认不开启绕过；如需绕过，可在运行前设置 ICONS_BYPASS_QUOTA=1
export ICONS_BYPASS_QUOTA=${ICONS_BYPASS_QUOTA:-"0"}

# 环境探针（不泄露密钥）
len_ms_key=${#MODELSCOPE_API_KEY}
len_ds_key=${#DASHSCOPE_API_KEY}
echo "[env] MODELSCOPE_API_BASE=$MODELSCOPE_API_BASE"
echo "[env] MODELSCOPE_T2I_MODEL=$MODELSCOPE_T2I_MODEL"
echo "[env] MODELSCOPE_API_KEY length=$len_ms_key"
echo "[env] DASHSCOPE_BASE_URL=$DASHSCOPE_BASE_URL"
echo "[env] DASHSCOPE_T2I_MODEL=$DASHSCOPE_T2I_MODEL"
echo "[env] DASHSCOPE_API_KEY length=$len_ds_key"

# 启动服务
cd "$SCRIPT_DIR"
python3 server.py