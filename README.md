# Volcengine API Skill

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Volcengine API skill supporting image generation, video generation, and vision understanding.

**English** | [简体中文](./README_CN.md)

## 🚀 Quick Start (2 minutes)

### Option 1: Script Installation (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill

# 2. Run installation script
./install.sh

# 3. Configure API Key
export ARK_API_KEY="your-api-key"

# 4. Run example
python3 examples/quickstart.py
```

### Option 2: Docker Deployment

```bash
# 1. Clone repository
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill

# 2. Configure environment
echo "ARK_API_KEY=your-api-key" > .env

# 3. Start service
docker compose up --build
```

### Deployment Comparison

| Method | Time | Use Case | Command |
|--------|------|----------|---------|
| Script | 2-3 min | Local development, quick start | `./install.sh` |
| Docker | 3-5 min | Containerized environment, teams | `docker compose up` |
| Manual | 5-10 min | Custom environment | See [INSTALLATION.md](./docs/INSTALLATION.md) |

> 📖 For detailed installation instructions, see [INSTALLATION.md](./docs/INSTALLATION.md)

---

## ✨ Features

### 🎨 Image Generation (Seedream 4.0)
- Text-to-Image
- Image Editing
- Image-to-Image
- Multiple sizes and styles

### 🎬 Video Generation (Seedance 1.5)
- Text-to-Video
- Image-to-Video
- Camera motion control
- First/last frame control

### 👁️ Vision Understanding
- Image content analysis
- Object detection and localization

### 📋 Task Management
- View generation progress
- Download results
- Manage history

---

## 📦 Installation

For detailed installation instructions, see [INSTALLATION.md](./docs/INSTALLATION.md).

### Quick Installation

```bash
# Clone repository
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill

# Run installation script
./install.sh
```

### Manual Installation

```bash
# Install dependencies
pip install -r volcengine-api/requirements.txt
```

---

## 🔧 Configuration

### Option 1: Environment Variable (Recommended)

```bash
export ARK_API_KEY="your-api-key-here"
```

### Option 2: Configuration File

Create `~/.volcengine/config.yaml`:

```yaml
api_key: "your-api-key-here"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
timeout: 30
max_retries: 3
output_dir: "./output"
```

### Option 3: Interactive Configuration

```bash
./scripts/configure.sh
```

---

## 📖 Usage Examples

### Image Generation

```python
from toolkit.api_client import VolcengineAPIClient
from toolkit.config import ConfigManager

# Configure
config = ConfigManager()
config.set("api_key", "your-api-key")

# Create client
with VolcengineAPIClient(config) as client:
    # Generate image
    result = client.post("/images/generate", json={
        "prompt": "Sunset beach with palm trees and waves",
        "width": 1024,
        "height": 768
    })
    print(f"Image URL: {result['url']}")
```

### Video Generation

```python
# Generate video
result = client.post("/videos/generate", json={
    "prompt": "Camera slowly pulls out, revealing mountain scenery",
    "duration": 5.0
})
print(f"Video URL: {result['url']}")
```

### Basic Usage

```python
from toolkit import VolcengineAPIClient, ConfigManager, TaskManager

# Initialize
config = ConfigManager()
client = VolcengineAPIClient(config)
task_manager = TaskManager(client)

# Create task
task = task_manager.create_task(
    task_type=TaskType.IMAGE_GENERATION,
    params={"prompt": "Beautiful sunset"}
)

# Query status
status = task_manager.get_task(task.id)
print(f"Status: {status.status}")

# Download result
if status.status == TaskStatus.SUCCEEDED:
    FileUtils.download_file(status.result.url, "./output/image.png")
```

### Advanced Usage

```python
from toolkit.validator import Validator

# Validate parameters
result = Validator.validate_image_generation_params(
    prompt="City night view",
    width=1920,
    height=1080
)

if not result.is_valid:
    print(f"Error: {result.errors}")
else:
    # Execute generation
    ...
```

> More examples at [examples.md](./docs/examples.md)

---

## 🏗️ Project Structure

```
seedream-skill/
├── install.sh              # One-click installer
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose config
├── .env.example            # Environment template
├── scripts/
│   ├── configure.sh        # Interactive config wizard
│   ├── verify_install.sh   # Installation verification
│   └── help.sh             # Help reference
├── examples/
│   └── quickstart.py       # Quick start example
├── docs/
│   ├── QUICKSTART.md       # Quick start guide
│   ├── INSTALLATION.md     # Installation docs
│   ├── examples.md         # Usage examples
│   └── troubleshooting.md  # Troubleshooting
└── volcengine-api/
    ├── toolkit/            # Core functionality
    │   ├── models/         # Data models
    │   ├── utils/          # Utility functions
    │   ├── api_client.py   # API client
    │   ├── config.py       # Configuration management
    │   ├── error_handler.py# Error handling
    │   ├── task_manager.py # Task management
    │   └── validator.py    # Parameter validation
    ├── tests/              # Test suite
    ├── SKILL.md            # Skill usage guide
    └── requirements.txt    # Dependencies
```

---

## 🧪 Testing

```bash
# Run all tests
pytest volcengine-api/tests/ -v

# Run specific test
pytest volcengine-api/tests/test_api_client.py -v

# Test coverage
pytest volcengine-api/tests/ --cov=toolkit --cov-report=html
```

---

## 📚 API Reference

### ConfigManager

```python
config = ConfigManager()
config.get("api_key")           # Get config
config.set("timeout", 60)       # Set config
config.get_api_key()            # Get API key
config.get_output_dir()         # Get output directory
```

### VolcengineAPIClient

```python
client = VolcengineAPIClient(config)
client.get(endpoint)            # GET request
client.post(endpoint, json={})  # POST request
client.put(endpoint, json={})   # PUT request
client.delete(endpoint)         # DELETE request
```

### TaskManager

```python
manager = TaskManager(client)
manager.create_task(type, params)          # Create task
manager.get_task(task_id)                  # Get task
manager.list_tasks(status=..., type=...)   # List tasks
manager.update_task_status(id, status)     # Update status
manager.delete_task(task_id)               # Delete task
```

### Validator

```python
Validator.validate_required(value, field, result)
Validator.validate_type(value, type, field, result)
Validator.validate_range(value, min, max, field, result)
Validator.validate_image_generation_params(prompt, width, height)
Validator.validate_video_generation_params(prompt, duration)
```

---

## ⚠️ Error Handling

All errors are converted to user-friendly messages:

```python
from toolkit.error_handler import (
    VolcengineError,
    AuthenticationError,
    RateLimitError,
    InvalidInputError
)

try:
    result = client.post("/images/generate", json=params)
except AuthenticationError as e:
    print(f"Authentication failed: {e.message}")
    print(f"Solution: {e.solution}")
except RateLimitError as e:
    print(f"Rate limit: please wait {e.retry_after} seconds")
except InvalidInputError as e:
    print(f"Parameter error: {e.message}")
```

---

## 🔒 Security Best Practices

1. **Don't hardcode API keys**
   ```python
   # ❌ Wrong
   api_key = "your-key-here"
   
   # ✅ Correct
   api_key = os.getenv("ARK_API_KEY")
   ```

2. **Use environment variables**
   ```bash
   export ARK_API_KEY="your-key"
   ```

3. **Set config file permissions**
   ```bash
   chmod 600 ~/.volcengine/config.yaml
   ```

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📞 Support

- 📖 [Quick Start](./docs/QUICKSTART.md)
- 📦 [Installation Guide](./docs/INSTALLATION.md)
- 📋 [Examples](./docs/examples.md)
- 🔧 [Troubleshooting](./docs/troubleshooting.md)
- 🐛 [Issue Tracker](https://github.com/Lychee-AI-Team/seedream-skill/issues)
- 💬 [Discussions](https://github.com/Lychee-AI-Team/seedream-skill/discussions)

---

**Built with ❤️ for Volcengine API**
