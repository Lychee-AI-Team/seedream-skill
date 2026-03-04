#!/usr/bin/env bash

set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_DIR="$HOME/.volcengine"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
BEGIN_MARKER="# >>> volcengine ark_api_key >>>"
END_MARKER="# <<< volcengine ark_api_key <<<"
API_KEY=""
METHOD=""
RC_FILE=""

info() {
  printf "%bINFO%b %s\n" "$BLUE" "$NC" "$1"
}

warn() {
  printf "%bWARN%b %s\n" "$YELLOW" "$NC" "$1"
}

pass() {
  printf "%bPASS%b %s\n" "$GREEN" "$NC" "$1"
}

fail() {
  printf "%bFAIL%b %s\n" "$RED" "$NC" "$1"
}

backup_file() {
  local target="$1"
  local stamp backup

  if [[ ! -f "$target" ]]; then
    return 0
  fi

  stamp="$(date +%Y%m%d%H%M%S)"
  backup="${target}.bak.${stamp}"
  cp "$target" "$backup"
  pass "已备份: $backup"
}

detect_shell_rc() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"

  case "$shell_name" in
    zsh)
      RC_FILE="$HOME/.zshrc"
      ;;
    bash)
      RC_FILE="$HOME/.bashrc"
      ;;
    *)
      warn "无法识别当前 shell (${SHELL:-unknown})，默认使用 ~/.bashrc"
      RC_FILE="$HOME/.bashrc"
      ;;
  esac
}

prompt_api_key() {
  local key_len

  while true; do
    printf "请输入 ARK_API_KEY（输入隐藏，需 36 个字符）: "
    read -r -s API_KEY
    printf "\n"

    key_len="${#API_KEY}"
    if [[ "$key_len" -eq 36 ]]; then
      pass "API Key 格式校验通过。"
      return 0
    fi

    fail "API Key 长度不正确（当前 $key_len，预期 36）。请重试。"
  done
}

prompt_method() {
  local choice

  while true; do
    printf "\n请选择配置方式:\n"
    printf "  1) 环境变量（写入 ~/.bashrc 或 ~/.zshrc）\n"
    printf "  2) 全局配置文件（~/.volcengine/config.yaml）\n"
    printf "  3) 两者都配置\n"
    printf "请输入选项 [1-3]: "
    read -r choice

    case "$choice" in
      1)
        METHOD="env"
        return 0
        ;;
      2)
        METHOD="file"
        return 0
        ;;
      3)
        METHOD="both"
        return 0
        ;;
      *)
        warn "无效选项，请输入 1、2 或 3。"
        ;;
    esac
  done
}

write_env_config() {
  local tmp_file

  detect_shell_rc
  touch "$RC_FILE"
  backup_file "$RC_FILE"

  tmp_file="$(mktemp)"
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$RC_FILE" > "$tmp_file"

  {
    cat "$tmp_file"
    printf "\n%s\n" "$BEGIN_MARKER"
    printf "export ARK_API_KEY=\"%s\"\n" "$API_KEY"
    printf "%s\n" "$END_MARKER"
  } > "$RC_FILE"

  rm -f "$tmp_file"
  pass "已更新环境变量配置: $RC_FILE"
}

write_file_config() {
  mkdir -p "$CONFIG_DIR"
  backup_file "$CONFIG_FILE"

  cat > "$CONFIG_FILE" <<EOF
api_key: "$API_KEY"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
timeout: 30
max_retries: 3
output_dir: "./output"
EOF

  chmod 600 "$CONFIG_FILE"
  pass "已更新配置文件: $CONFIG_FILE"
}

validate_env_config() {
  if [[ -z "$RC_FILE" || ! -f "$RC_FILE" ]]; then
    fail "环境变量配置校验失败：未找到 rc 文件。"
    return 1
  fi

  if grep -q '^export ARK_API_KEY="' "$RC_FILE"; then
    pass "环境变量配置校验通过。"
    return 0
  fi

  fail "环境变量配置校验失败：未找到 ARK_API_KEY 导出项。"
  return 1
}

validate_file_config() {
  local configured_key

  if [[ ! -f "$CONFIG_FILE" ]]; then
    fail "配置文件校验失败：$CONFIG_FILE 不存在。"
    return 1
  fi

  configured_key="$(sed -n 's/^api_key: "\(.*\)"$/\1/p' "$CONFIG_FILE")"
  if [[ "${#configured_key}" -eq 36 ]]; then
    pass "配置文件校验通过。"
    return 0
  fi

  fail "配置文件校验失败：api_key 长度异常。"
  return 1
}

apply_configuration() {
  case "$METHOD" in
    env)
      write_env_config
      ;;
    file)
      write_file_config
      ;;
    both)
      write_env_config
      write_file_config
      ;;
    *)
      fail "未知配置方式: $METHOD"
      return 1
      ;;
  esac
}

validate_configuration() {
  local ok=0

  case "$METHOD" in
    env)
      validate_env_config || ok=1
      ;;
    file)
      validate_file_config || ok=1
      ;;
    both)
      validate_env_config || ok=1
      validate_file_config || ok=1
      ;;
    *)
      ok=1
      ;;
  esac

  return "$ok"
}

main() {
  info "Volcengine 配置向导启动"
  prompt_api_key
  prompt_method

  if ! apply_configuration; then
    fail "配置写入失败。"
    exit 1
  fi

  if ! validate_configuration; then
    fail "配置校验失败，请检查后重试。"
    exit 1
  fi

  printf "\n%bPASS%b 配置完成。\n" "$GREEN" "$NC"
  printf "- 已应用方式: %s\n" "$METHOD"
  printf "- 配置优先级: env var > project config > global config > defaults\n"
  printf "- 建议执行: source %s\n" "${RC_FILE:-~/.bashrc}"
}

main
