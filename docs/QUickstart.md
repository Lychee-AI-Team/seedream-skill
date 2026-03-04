# Volcengine API QUICKstart

This guide helps you run the project in 30 seconds, then covers a complete 5-minute setup with three deployment options. It is designed to be copy-paste friendly and practical for first-time users.

## Table of Contents

- [30-Second Quick Start](#30-second-quick-start)
- [5-Minute Complete Tutorial](#5-minute-complete-tutorial)
- [### Features](#features)
- [#### Installation](#installation)
- [##### Configuration](#configuration)
- [###### Usage](#usage)
- [H7 Next Steps](#h7-next-steps)
- [H8 Resources](#h8-resources)
- [H9 Troubleshooting](#h9-troubleshooting)

## 30-Second Quick Start

Use this when you want a fast smoke test.

```bash
cd /Users/mastercui.eth/GitHub/ai-agent-cli/.worktrees/volcengine-api
bash install.sh
export ARK_API_KEY="your-real-api-key"
python examples/quickstart.py
```

Quick API check with `curl`:

```bash
curl -sS "https://ark.cn-beijing.volces.com/api/v3/models" \
  -H "Authorization: Bearer ${ARK_API_KEY}" \
  -H "Content-Type: application/json"
```

## 5-Minute Complete Tutorial

This path is for users who want stable local setup plus verification.

1. Install dependencies and bootstrap files.
2. Configure API key using script or config file.
3. Run quickstart sample and verify output.
4. Run installation checks and API connectivity checks.

```bash
cd /Users/mastercui.eth/GitHub/ai-agent-cli/.worktrees/volcengine-api
bash install.sh
bash scripts/configure.sh
bash scripts/verify_install.sh
python examples/quickstart.py
```

### Features

1. Image generation: text-to-image and image editing workflows.
2. Video generation: text-to-video and image-to-video pipelines.
3. Vision understanding: image analysis and detection tasks.
4. Task management: status tracking, history, and output download.

#### Installation

Requirements:

- Python 3.9+
- `pip`
- Network access to `https://ark.cn-beijing.volces.com`

Complete installation flow:

```bash
cd /Users/mastercui.eth/GitHub/ai-agent-cli/.worktrees/volcengine-api
python3 -m pip install --upgrade pip
python3 -m pip install -r volcengine-api/requirements.txt
mkdir -p output
```

Deployment methods comparison (target: 2-3 minutes, improved from 10-15 minutes):

| Method | Best for | Command | Typical time |
|---|---|---|---|
| Scripts | Fast local setup | `bash install.sh` | 2-3 min |
| Docker | Isolated runtime | `docker build -t volcengine-api . && docker run --rm -e ARK_API_KEY="$ARK_API_KEY" volcengine-api` | 2-4 min |
| Docker Compose | Repeatable team setup | `docker compose up --build` | 2-4 min |

##### Configuration

Option A (recommended): environment variable.

```bash
export ARK_API_KEY="your-real-api-key"
```

Option B: global config file.

```bash
mkdir -p "$HOME/.volcengine"
cat > "$HOME/.volcengine/config.yaml" <<'EOF'
api_key: "your-real-api-key"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
timeout: 30
max_retries: 3
output_dir: "./output"
EOF
```

###### Usage

Run first example:

```bash
python examples/quickstart.py
```

Run script-based verification:

```bash
bash scripts/verify_install.sh
```

Performance optimization suggestions:

- Prefer script installation for first run speed.
- Use batch requests for multiple generation tasks.
- Reuse configuration objects instead of rebuilding per call.
- Download outputs concurrently when processing many files.

###### H7 Next Steps

After quickstart, continue with targeted workflows in `docs/examples.md`, then validate behavior with tests in `volcengine-api/tests/`. If you are preparing a team environment, move to Docker Compose for consistent local setup.

###### H8 Resources

- Project README: [../README.md](../README.md)
- Usage examples: [examples.md](./examples.md)
- Troubleshooting guide: [troubleshooting.md](./troubleshooting.md)
- Volcengine Ark API docs: <https://www.volcengine.com/docs/82379>
- API endpoint base URL used in this project: `https://ark.cn-beijing.volces.com/api/v3`

###### H9 Troubleshooting

Friendly error hints:

- `API key not configured`: set `ARK_API_KEY` first, then rerun.
- `401 Unauthorized`: check key validity and account permission.
- `Rate limit exceeded`: reduce request frequency and retry later.
- `Network connection failed`: verify proxy/firewall and endpoint access.

Quick checks:

```bash
python3 --version
python3 -m pip --version
echo "${ARK_API_KEY}" | wc -c
bash scripts/verify_install.sh
```
