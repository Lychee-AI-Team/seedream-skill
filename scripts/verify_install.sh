#!/usr/bin/env bash

set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

overall_ok=0

pass() {
  printf "%bPASS%b %s\n" "$GREEN" "$NC" "$1"
}

fail() {
  printf "%bFAIL%b %s\n" "$RED" "$NC" "$1"
  overall_ok=1
}

warn() {
  printf "%bWARN%b %s\n" "$YELLOW" "$NC" "$1"
}

check_python_version() {
  local version_raw major minor

  if ! version_raw="$(python3 --version 2>&1)"; then
    fail "python3 不可用。请安装 Python 3.9+。"
    return
  fi

  major="$(python3 -c 'import sys; print(sys.version_info[0])' 2>/dev/null)"
  minor="$(python3 -c 'import sys; print(sys.version_info[1])' 2>/dev/null)"

  if [[ -z "$major" || -z "$minor" ]]; then
    fail "无法解析 Python 版本（输出: $version_raw）。"
    return
  fi

  if (( major > 3 )) || (( major == 3 && minor >= 9 )); then
    pass "Python 版本满足要求: $version_raw"
  else
    fail "Python 版本过低: $version_raw。请升级到 Python 3.9+。"
  fi
}

check_dependencies() {
  if python3 -c "import httpx, pydantic, yaml" >/dev/null 2>&1; then
    pass "依赖检查通过: httpx, pydantic, yaml"
  else
    fail "依赖缺失。请执行: python3 -m pip install httpx pydantic pyyaml"
  fi
}

check_api_key() {
  if [[ -n "${ARK_API_KEY:-}" ]]; then
    pass "检测到环境变量 ARK_API_KEY"
  else
    fail "未检测到 ARK_API_KEY。请设置: export ARK_API_KEY='your_api_key'"
  fi
}

check_config_file() {
  local cfg="$HOME/.volcengine/config.yaml"
  if [[ -f "$cfg" ]]; then
    pass "检测到配置文件: $cfg"
  else
    fail "未找到配置文件: $cfg。请创建并写入 API 配置。"
  fi
}

optional_api_test() {
  local answer

  if [[ -z "${ARK_API_KEY:-}" ]]; then
    warn "跳过可选 API 连接测试：ARK_API_KEY 未配置。"
    return
  fi

  printf "运行可选 API 连接测试？[y/N]: "
  read -r answer

  case "$answer" in
    y|Y|yes|YES)
      if python3 - <<'PY'
import os
import sys

import httpx

api_key = os.environ.get("ARK_API_KEY", "")
url = "https://ark.cn-beijing.volces.com/api/v3/models"
headers = {"Authorization": f"Bearer {api_key}"}

try:
    with httpx.Client(timeout=10.0) as client:
        response = client.get(url, headers=headers)
        if response.status_code == 200:
            print("API connectivity check succeeded.")
            sys.exit(0)
        print(f"Unexpected status: {response.status_code}")
        sys.exit(2)
except Exception as exc:
    print(f"Connection error: {exc}")
    sys.exit(1)
PY
      then
        pass "可选 API 连接测试通过"
      else
        fail "可选 API 连接测试失败。请检查网络、API Key 或服务端点配置。"
      fi
      ;;
    *)
      warn "已跳过可选 API 连接测试（未获得同意）。"
      ;;
  esac
}

main() {
  check_python_version
  check_dependencies
  check_api_key
  check_config_file
  optional_api_test

  if (( overall_ok == 0 )); then
    printf "%bALL CHECKS PASSED%b\n" "$GREEN" "$NC"
    exit 0
  fi

  printf "%bCHECKS FAILED%b\n" "$RED" "$NC"
  exit 1
}

main
