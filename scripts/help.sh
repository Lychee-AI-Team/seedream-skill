#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

line() {
  printf '%b\n' "${BLUE}============================================================${NC}"
}

header() {
  line
  printf '%b\n' "${GREEN}$1${NC}"
  line
}

item() {
  printf '%b\n' "  ${YELLOW}- ${NC}$1"
}

cmd() {
  printf '%b\n' "    ${BLUE}$ $1${NC}"
}

header "Volcengine API Quick Help"

header "1) Available Features"
item "Image: text-to-image, image editing, image-to-image"
item "Video: text-to-video, image-to-video"
item "Vision: image analysis and object understanding"
item "Task Management: create, query, list, download results"

header "2) Quick Commands"
item "Install dependencies"
cmd "pip install -r volcengine-api/requirements.txt"
item "Run end-to-end quickstart (image/video/vision)"
cmd "python examples/quickstart.py"
item "Run task-management unit tests"
cmd "pytest volcengine-api/tests/test_task_manager.py -v"

header "3) Configuration"
item "Set API key (recommended)"
cmd "export ARK_API_KEY=\"your-api-key\""
item "Optional: set output directory"
cmd "export VOLCENGINE_OUTPUT_DIR=\"./output\""
item "Optional: create project config file"
cmd "mkdir -p .volcengine"
cmd "cat > .volcengine/config.yaml <<'EOF'"
cmd "api_key: \"your-api-key\""
cmd "timeout: 30"
cmd "output_dir: \"./output\""
cmd "EOF"

header "4) Troubleshooting"
item "Auth failed: verify ARK_API_KEY is set and valid"
cmd "echo \"$ARK_API_KEY\" | wc -c"
item "Module not found: install dependencies again"
cmd "pip install -r volcengine-api/requirements.txt"
item "Rate limited: retry later or reduce request frequency"
item "Request timeout: check network and API endpoint accessibility"

header "5) Getting Started"
item "Step 1: Install dependencies"
cmd "pip install -r volcengine-api/requirements.txt"
item "Step 2: Configure API key"
cmd "export ARK_API_KEY=\"your-api-key\""
item "Step 3: Run a first image generation"
cmd "python examples/quickstart.py"
item "Step 4: Check generated outputs in ./output"

printf '%b\n' "${GREEN}Tip:${NC} Save this key for current shell session before running examples."
