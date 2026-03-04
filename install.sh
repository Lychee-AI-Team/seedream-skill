#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
  printf "%b[INFO]%b %s\n" "${BLUE}" "${NC}" "$1"
}

log_success() {
  printf "%b[SUCCESS]%b %s\n" "${GREEN}" "${NC}" "$1"
}

log_warn() {
  printf "%b[WARN]%b %s\n" "${YELLOW}" "${NC}" "$1"
}

log_error() {
  printf "%b[ERROR]%b %s\n" "${RED}" "${NC}" "$1" >&2
}

fail() {
  log_error "$1"
  exit 1
}

on_error() {
  local line_no="$1"
  fail "Installation failed at line ${line_no}. Please fix the error above and rerun ./install.sh"
}

trap 'on_error $LINENO' ERR

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_os() {
  local kernel
  kernel="$(uname -s)"
  case "${kernel}" in
    Darwin)
      OS_NAME='macOS'
      ;;
    Linux)
      OS_NAME='Linux'
      ;;
    *)
      OS_NAME='Unknown'
      ;;
  esac

  log_info "Detected OS: ${OS_NAME} (${kernel})"
  if [ "${OS_NAME}" = 'Unknown' ]; then
    log_warn 'Unsupported OS detected. The script will continue with best effort.'
  fi
}

detect_python() {
  if command_exists python3; then
    PYTHON_BIN='python3'
  elif command_exists python; then
    PYTHON_BIN='python'
  else
    fail 'Python is not installed. Please install Python 3.9+ and rerun.'
  fi

  PYTHON_VERSION="$(${PYTHON_BIN} -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
  log_info "Detected Python: ${PYTHON_VERSION} (${PYTHON_BIN})"

  if ! ${PYTHON_BIN} -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 9) else 1)'; then
    fail "Python ${PYTHON_VERSION} is too old. Python 3.9+ is required."
  fi

  log_success 'Python version check passed (>= 3.9).'
}

ensure_pip() {
  if ${PYTHON_BIN} -m pip --version >/dev/null 2>&1; then
    log_success 'pip is available.'
    return
  fi

  log_warn 'pip not found. Attempting to bootstrap via ensurepip...'
  if ${PYTHON_BIN} -m ensurepip --upgrade >/dev/null 2>&1; then
    log_success 'pip installed with ensurepip.'
    return
  fi

  fail 'pip is unavailable and ensurepip failed. Please install pip manually.'
}

install_dependencies() {
  REQUIREMENTS_FILE="${PROJECT_ROOT}/volcengine-api/requirements.txt"
  [ -f "${REQUIREMENTS_FILE}" ] || fail "Missing requirements file: ${REQUIREMENTS_FILE}"

  log_info 'Upgrading pip...'
  ${PYTHON_BIN} -m pip install --upgrade pip

  log_info "Installing dependencies from ${REQUIREMENTS_FILE}"
  ${PYTHON_BIN} -m pip install -r "${REQUIREMENTS_FILE}"
  log_success 'Dependencies installed successfully.'
}

create_config_template() {
  CONFIG_DIR="${HOME}/.volcengine"
  CONFIG_FILE="${CONFIG_DIR}/config.yaml"

  mkdir -p "${CONFIG_DIR}"
  if [ -f "${CONFIG_FILE}" ]; then
    log_warn "Config already exists, skipping: ${CONFIG_FILE}"
    return
  fi

  cat > "${CONFIG_FILE}" <<'CONFIG'
# Volcengine API configuration template
# Fill these values before first run.

api_key: "YOUR_ARK_API_KEY"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
region: "cn-beijing"
timeout: 30
max_retries: 3
output_dir: "./output"
CONFIG

  log_success "Created config template: ${CONFIG_FILE}"
}

create_output_directory() {
  OUTPUT_DIR="${PROJECT_ROOT}/output"
  mkdir -p "${OUTPUT_DIR}"
  log_success "Output directory ready: ${OUTPUT_DIR}"
}

set_environment_variables_optional() {
  ENV_FILE="${HOME}/.volcengine/env.sh"
  SHELL_NAME="$(basename "${SHELL:-}")"
  SHOULD_SET_ENV='n'

  if [ -t 0 ]; then
    printf "%b[INFO]%b Set environment variables automatically? [y/N]: " "${BLUE}" "${NC}"
    read -r user_choice || true
    case "${user_choice:-}" in
      y|Y|yes|YES)
        SHOULD_SET_ENV='y'
        ;;
      *)
        SHOULD_SET_ENV='n'
        ;;
    esac
  else
    log_warn 'Non-interactive shell detected; skipping automatic environment variable setup.'
  fi

  if [ "${SHOULD_SET_ENV}" != 'y' ]; then
    log_info 'Skipping automatic environment variable setup (optional step).'
    return
  fi

  cat > "${ENV_FILE}" <<EOF_ENV
export ARK_API_KEY="your-api-key-here"
export VOLCENGINE_CONFIG="${HOME}/.volcengine/config.yaml"
export VOLCENGINE_OUTPUT_DIR="${PROJECT_ROOT}/output"
EOF_ENV

  case "${SHELL_NAME}" in
    zsh)
      SHELL_RC="${HOME}/.zshrc"
      ;;
    bash)
      SHELL_RC="${HOME}/.bashrc"
      ;;
    *)
      SHELL_RC=''
      ;;
  esac

  if [ -n "${SHELL_RC}" ]; then
    mkdir -p "$(dirname "${SHELL_RC}")"
    touch "${SHELL_RC}"
    SOURCE_LINE='[ -f "$HOME/.volcengine/env.sh" ] && source "$HOME/.volcengine/env.sh"'
    if ! command_exists grep; then
      log_warn 'grep is unavailable; skipped rc file update.'
    elif grep -Fq "${SOURCE_LINE}" "${SHELL_RC}"; then
      log_warn "Environment source line already exists in ${SHELL_RC}"
    else
      printf '\n%s\n' "${SOURCE_LINE}" >> "${SHELL_RC}"
      log_success "Added environment source line to ${SHELL_RC}"
    fi
  else
    log_warn 'Unknown shell; skipped automatic shell rc file update.'
  fi

  log_success 'Environment variable template created at ~/.volcengine/env.sh'
}

print_next_steps() {
  printf "\n"
  log_info 'Installation complete. Next steps:'
  printf '  1) Set API key:\n'
  printf '     - Temporary: export ARK_API_KEY="your-real-api-key"\n'
  printf '     - Persistent (optional): edit %s\n' "${HOME}/.volcengine/env.sh"
  printf '  2) Configure: edit %s and fill real values.\n' "${HOME}/.volcengine/config.yaml"
  printf '  3) Run quickstart: python examples/quickstart.py\n'
  printf '  4) Verify installation: python -c "import toolkit; print(\"OK\")"\n'
  printf '  5) Output directory: %s/output\n' "${PROJECT_ROOT}"
}

main() {
  PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  log_info 'Starting Volcengine API one-click installation...'
  detect_os
  detect_python
  ensure_pip
  install_dependencies
  create_config_template
  create_output_directory
  set_environment_variables_optional
  print_next_steps
  log_success 'All done.'
}

main "$@"
