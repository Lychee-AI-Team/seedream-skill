# 火山引擎API Skill

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个功能完整的火山引擎API操作Skill，支持图像生成、视频生成和视觉理解。

**[English](./README.md)** | 简体中文

## 🚀 快速开始（2分钟）

### 方式一：脚本安装（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill

# 2. 运行安装脚本
./install.sh

# 3. 配置 API Key
export ARK_API_KEY="your-api-key"

# 4. 运行示例
python3 examples/quickstart.py
```

### 方式二：Docker 部署

```bash
# 1. 克隆仓库
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill

# 2. 配置环境变量
echo "ARK_API_KEY=your-api-key" > .env

# 3. 启动服务
docker compose up --build
```

### 部署方式对比

| 方式 | 时间 | 适用场景 | 命令 |
|------|------|----------|------|
| 脚本安装 | 2-3分钟 | 本地开发、快速体验 | `./install.sh` |
| Docker | 3-5分钟 | 容器化环境、团队协作 | `docker compose up` |
| 手动安装 | 5-10分钟 | 自定义环境 | 见 [INSTALLATION.md](./docs/INSTALLATION.md) |

> 📖 详细安装说明请参考 [INSTALLATION.md](./docs/INSTALLATION.md)

---

## ✨ 功能特性

### 🎨 图像生成 (Seedream 4.0)
- 文本生成图片 (Text-to-Image)
- 图片编辑 (Image Editing)
- 图生图 (Image-to-Image)
- 支持多种尺寸和风格

### 🎬 视频生成 (Seedance 1.5)
- 文本生成视频 (Text-to-Video)
- 图片生成视频 (Image-to-Video)
- 控制镜头运动
- 支持首尾帧控制

### 👁️ 视觉理解 (Vision)
- 图像内容分析
- 对象检测和定位

### 📋 任务管理
- 查看生成进度
- 下载结果
- 管理历史记录

---

## 📦 安装

详细安装说明请参考 [INSTALLATION.md](./docs/INSTALLATION.md)。

### 快速安装

```bash
# 克隆仓库
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill

# 运行安装脚本
./install.sh
```

### 手动安装

```bash
# 安装依赖
pip install -r volcengine-api/requirements.txt
```

---

## 🔧 配置

### 方式1: 环境变量（推荐）

```bash
export ARK_API_KEY="your-api-key-here"
```

### 方式2: 配置文件

创建 `~/.volcengine/config.yaml`:

```yaml
api_key: "your-api-key-here"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
timeout: 30
max_retries: 3
output_dir: "./output"
```

### 方式3: 交互式配置

```bash
./scripts/configure.sh
```

---

## 📖 使用示例

### 图像生成

```python
from toolkit.api_client import VolcengineAPIClient
from toolkit.config import ConfigManager

# 配置
config = ConfigManager()
config.set("api_key", "your-api-key")

# 创建客户端
with VolcengineAPIClient(config) as client:
    # 生成图像
    result = client.post("/images/generate", json={
        "prompt": "夕阳下的海滩，有椰子树和海浪",
        "width": 1024,
        "height": 768
    })
    print(f"图像URL: {result['url']}")
```

### 视频生成

```python
# 生成视频
result = client.post("/videos/generate", json={
    "prompt": "镜头缓缓拉出，展现山景",
    "duration": 5.0
})
print(f"视频URL: {result['url']}")
```

### 基础用法

```python
from toolkit import VolcengineAPIClient, ConfigManager, TaskManager

# 初始化
config = ConfigManager()
client = VolcengineAPIClient(config)
task_manager = TaskManager(client)

# 创建任务
task = task_manager.create_task(
    task_type=TaskType.IMAGE_GENERATION,
    params={"prompt": "美丽的日落"}
)

# 查询状态
status = task_manager.get_task(task.id)
print(f"状态: {status.status}")

# 下载结果
if status.status == TaskStatus.SUCCEEDED:
    FileUtils.download_file(status.result.url, "./output/image.png")
```

### 高级用法

```python
from toolkit.validator import Validator

# 验证参数
result = Validator.validate_image_generation_params(
    prompt="城市夜景",
    width=1920,
    height=1080
)

if not result.is_valid:
    print(f"错误: {result.errors}")
else:
    # 执行生成
    ...
```

> 更多示例请参考 [examples.md](./docs/examples.md)

---

## 🏗️ 项目结构

```
seedream-skill/
├── install.sh              # 一键安装脚本
├── Dockerfile              # Docker 镜像定义
├── docker-compose.yml      # Docker Compose 配置
├── .env.example            # 环境变量模板
├── scripts/
│   ├── configure.sh        # 交互式配置向导
│   ├── verify_install.sh   # 安装验证脚本
│   └── help.sh             # 帮助脚本
├── examples/
│   └── quickstart.py       # 快速开始示例
├── docs/
│   ├── QUICKSTART.md       # 快速开始指南
│   ├── INSTALLATION.md     # 安装文档
│   ├── examples.md         # 使用示例
│   └── troubleshooting.md  # 故障排除
└── volcengine-api/
    ├── toolkit/            # 核心功能模块
    │   ├── models/         # 数据模型
    │   ├── utils/          # 工具函数
    │   ├── api_client.py   # API 客户端
    │   ├── config.py       # 配置管理
    │   ├── error_handler.py# 错误处理
    │   ├── task_manager.py # 任务管理
    │   └── validator.py    # 参数验证
    ├── tests/              # 测试套件
    ├── SKILL.md            # Skill 使用指南
    └── requirements.txt    # 依赖列表
```

---

## 🧪 测试

```bash
# 运行所有测试
pytest volcengine-api/tests/ -v

# 运行特定测试
pytest volcengine-api/tests/test_api_client.py -v

# 测试覆盖率
pytest volcengine-api/tests/ --cov=toolkit --cov-report=html
```

---

## 📚 API参考

### ConfigManager

```python
config = ConfigManager()
config.get("api_key")           # 获取配置
config.set("timeout", 60)       # 设置配置
config.get_api_key()            # 获取API密钥
config.get_output_dir()         # 获取输出目录
```

### VolcengineAPIClient

```python
client = VolcengineAPIClient(config)
client.get(endpoint)            # GET请求
client.post(endpoint, json={})  # POST请求
client.put(endpoint, json={})   # PUT请求
client.delete(endpoint)         # DELETE请求
```

### TaskManager

```python
manager = TaskManager(client)
manager.create_task(type, params)          # 创建任务
manager.get_task(task_id)                  # 获取任务
manager.list_tasks(status=..., type=...)   # 列出任务
manager.update_task_status(id, status)     # 更新状态
manager.delete_task(task_id)               # 删除任务
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

## ⚠️ 错误处理

所有错误都转换为用户友好的消息：

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
    print(f"认证失败: {e.message}")
    print(f"解决方案: {e.solution}")
except RateLimitError as e:
    print(f"速率限制: 请等待 {e.retry_after} 秒")
except InvalidInputError as e:
    print(f"参数错误: {e.message}")
```

---

## 🔒 安全最佳实践

1. **不要硬编码API密钥**
   ```python
   # ❌ 错误
   api_key = "your-key-here"
   
   # ✅ 正确
   api_key = os.getenv("ARK_API_KEY")
   ```

2. **使用环境变量**
   ```bash
   export ARK_API_KEY="your-key"
   ```

3. **配置文件权限**
   ```bash
   chmod 600 ~/.volcengine/config.yaml
   ```

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

---

## 📞 支持

- 📖 [快速开始](./docs/QUICKSTART.md)
- 📦 [安装指南](./docs/INSTALLATION.md)
- 📋 [使用示例](./docs/examples.md)
- 🔧 [故障排除](./docs/troubleshooting.md)
- 🐛 [问题追踪](https://github.com/Lychee-AI-Team/seedream-skill/issues)
- 💬 [讨论区](https://github.com/Lychee-AI-Team/seedream-skill/discussions)

---

**Built with ❤️ for Volcengine API**
