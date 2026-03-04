# 安装指南

本文档提供火山引擎 API Skill 的详细安装说明，包括三种安装方式和完整的故障排除指南。

## 目录

- [系统要求](#系统要求)
- [安装方式对比](#安装方式对比)
- [方式一：脚本安装（推荐）](#方式一脚本安装推荐)
- [方式二：Docker 安装](#方式二docker-安装)
- [方式三：手动安装](#方式三手动安装)
- [安装后配置](#安装后配置)
- [验证安装](#验证安装)
- [故障排除](#故障排除)

---

## 系统要求

### 必需条件

| 项目 | 要求 |
|------|------|
| Python | 3.9 或更高版本 |
| pip | 最新版本 |
| 操作系统 | Linux (Ubuntu 20.04+), macOS 12+, Windows 10+ (WSL2) |
| 网络 | 可访问 `https://ark.cn-beijing.volces.com` |

### 依赖包

```
volcengine-python-sdk[ark]>=5.0.0
PyYAML>=6.0
Pydantic>=2.0.0
httpx>=0.27.0
Pillow>=10.0.0
```

### 检查 Python 版本

```bash
python3 --version
# 输出应为 Python 3.9.x 或更高
```

如果版本过低，请先升级 Python：

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install python3.11 python3-pip

# macOS (使用 Homebrew)
brew install python@3.11
```

---

## 安装方式对比

| 方式 | 难度 | 时间 | 适用场景 |
|------|------|------|----------|
| 脚本安装 | ⭐ | 2-3 分钟 | 快速体验、本地开发 |
| Docker 安装 | ⭐⭐ | 3-5 分钟 | 容器化环境、团队协作 |
| 手动安装 | ⭐⭐⭐ | 5-10 分钟 | 自定义环境、生产部署 |

---

## 方式一：脚本安装（推荐）

### 步骤 1：获取代码

```bash
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill
```

### 步骤 2：运行安装脚本

```bash
chmod +x install.sh
./install.sh
```

安装脚本会自动：
- 检测操作系统和 Python 版本
- 安装所有依赖包
- 创建配置文件模板
- 创建输出目录

### 步骤 3：配置 API Key

```bash
# 方式 A：交互式配置
./scripts/configure.sh

# 方式 B：直接设置环境变量
export ARK_API_KEY="your-api-key-here"
```

### 步骤 4：验证安装

```bash
./scripts/verify_install.sh
```

### 预期输出

```
🔍 验证安装...

✅ Python 版本: 3.11.x
✅ pip 已安装
✅ 所有依赖已安装
✅ 配置已就绪

✅ 所有检查通过！
```

---

## 方式二：Docker 安装

### 前置条件

- Docker 20.10+
- Docker Compose 2.0+（可选）

### 步骤 1：获取代码

```bash
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill
```

### 步骤 2：配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，设置 ARK_API_KEY
```

### 步骤 3：构建并运行

**使用 Docker Compose（推荐）：**

```bash
docker compose up --build
```

**使用 Docker 直接构建：**

```bash
# 构建镜像
docker build -t volcengine-api .

# 运行容器
docker run --rm \
  -e ARK_API_KEY="your-api-key" \
  -v $(pwd)/output:/app/output \
  volcengine-api
```

### 预期输出

```
[+] Building 45.2s (12/12) FINISHED
[+] Running 1/1
 ✔ Container seedream-skill-volcengine-skill-1  Started
```

### Docker 常用命令

```bash
# 后台运行
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 进入容器
docker compose exec volcengine-skill /bin/bash
```

---

## 方式三：手动安装

### 步骤 1：获取代码

```bash
git clone https://github.com/Lychee-AI-Team/seedream-skill.git
cd seedream-skill
```

### 步骤 2：创建虚拟环境（推荐）

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# 或 venv\Scripts\activate  # Windows
```

### 步骤 3：安装依赖

```bash
python3 -m pip install --upgrade pip
python3 -m pip install -r volcengine-api/requirements.txt
```

### 步骤 4：创建配置文件

```bash
mkdir -p ~/.volcengine
cat > ~/.volcengine/config.yaml << 'EOF'
api_key: "your-api-key-here"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
timeout: 30
max_retries: 3
output_dir: "./output"
EOF
```

### 步骤 5：创建输出目录

```bash
mkdir -p output
```

### 步骤 6：设置环境变量（可选）

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
echo 'export ARK_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

---

## 安装后配置

### 配置方式对比

| 方式 | 优点 | 缺点 |
|------|------|------|
| 环境变量 | 简单、安全、容器友好 | 重启终端后需重新设置 |
| 配置文件 | 持久化、可配置更多选项 | 需要管理文件权限 |

### 环境变量配置

```bash
# 临时设置（当前会话）
export ARK_API_KEY="your-api-key"

# 永久设置（添加到 shell 配置）
echo 'export ARK_API_KEY="your-api-key"' >> ~/.bashrc
source ~/.bashrc
```

### 配置文件说明

配置文件位置：`~/.volcengine/config.yaml`

```yaml
# API 配置
api_key: "your-api-key-here"      # 必需：API 密钥
base_url: "https://ark.cn-beijing.volces.com/api/v3"  # API 基础 URL

# 请求配置
timeout: 30                        # 请求超时时间（秒）
max_retries: 3                     # 最大重试次数

# 输出配置
output_dir: "./output"             # 输出文件保存目录
```

### 配置优先级

1. 环境变量 `ARK_API_KEY`
2. 配置文件 `~/.volcengine/config.yaml`
3. 代码中直接设置（不推荐）

---

## 验证安装

### 快速验证

```bash
./scripts/verify_install.sh
```

### 手动验证

```bash
# 检查 Python
python3 --version

# 检查依赖
python3 -c "import httpx, pydantic, yaml; print('✅ 依赖已安装')"

# 检查配置
if [ -n "$ARK_API_KEY" ]; then
    echo "✅ 环境变量已配置"
elif [ -f ~/.volcengine/config.yaml ]; then
    echo "✅ 配置文件已创建"
else
    echo "❌ 配置未完成"
fi

# 测试 API 连接
python3 -c "
import os
import httpx
api_key = os.getenv('ARK_API_KEY')
if api_key:
    resp = httpx.get(
        'https://ark.cn-beijing.volces.com/api/v3/models',
        headers={'Authorization': f'Bearer {api_key}'}
    )
    print(f'✅ API 连接状态: {resp.status_code}')
else:
    print('❌ 未配置 API Key')
"
```

### 运行示例

```bash
python3 examples/quickstart.py
```

---

## 故障排除

### 常见问题

#### 1. Python 版本过低

**错误信息：**
```
❌ Python 版本过低，需要 3.9 或更高版本
```

**解决方案：**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.11 python3-pip

# macOS
brew install python@3.11

# 验证
python3.11 --version
```

#### 2. pip 安装失败

**错误信息：**
```
pip: command not found
```

**解决方案：**
```bash
# 安装 pip
python3 -m ensurepip --upgrade

# 或使用 get-pip.py
curl -sS https://bootstrap.pypa.io/get-pip.py | python3
```

#### 3. 依赖安装失败

**错误信息：**
```
ERROR: Could not find a version that satisfies the requirement...
```

**解决方案：**
```bash
# 升级 pip
python3 -m pip install --upgrade pip

# 使用国内镜像
python3 -m pip install -r volcengine-api/requirements.txt \
    -i https://pypi.tuna.tsinghua.edu.cn/simple
```

#### 4. API Key 未配置

**错误信息：**
```
❌ API Key 未配置
```

**解决方案：**
```bash
# 方式 A：设置环境变量
export ARK_API_KEY="your-api-key"

# 方式 B：运行配置脚本
./scripts/configure.sh

# 方式 C：创建配置文件
mkdir -p ~/.volcengine
echo 'api_key: "your-api-key"' > ~/.volcengine/config.yaml
```

#### 5. 网络连接失败

**错误信息：**
```
ConnectionError: Failed to connect to ark.cn-beijing.volces.com
```

**解决方案：**
```bash
# 检查网络连接
ping ark.cn-beijing.volces.com

# 检查代理设置
echo $HTTP_PROXY
echo $HTTPS_PROXY

# 临时禁用代理
unset HTTP_PROXY HTTPS_PROXY
```

#### 6. 权限错误

**错误信息：**
```
Permission denied: ~/.volcengine/config.yaml
```

**解决方案：**
```bash
# 修复文件权限
chmod 600 ~/.volcengine/config.yaml
chmod 700 ~/.volcengine
```

#### 7. Docker 构建失败

**错误信息：**
```
ERROR: failed to solve: process "/bin/sh -c pip install..." did not complete successfully
```

**解决方案：**
```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建（无缓存）
docker compose build --no-cache
```

### 获取帮助

如果以上方法无法解决问题：

1. 查看详细日志：
   ```bash
   python3 examples/quickstart.py --verbose
   ```

2. 运行诊断脚本：
   ```bash
   ./scripts/verify_install.sh --verbose
   ```

3. 查看故障排除文档：
   - [troubleshooting.md](./troubleshooting.md)

4. 提交问题：
   - [GitHub Issues](https://github.com/Lychee-AI-Team/seedream-skill/issues)

---

## 下一步

安装完成后，请参考：

- [QUICKSTART.md](./QUICKSTART.md) - 快速开始指南
- [examples.md](./examples.md) - 详细使用示例
- [../README.md](../README.md) - 完整功能文档
