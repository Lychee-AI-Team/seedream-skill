# Volcengine API Skill

火山引擎 API 操作 Skill，支持图像生成、视频生成和视觉理解。

## 功能列表

### 1. 图像生成 (Seedream 4.0)
- 文本生成图片 (Text-to-Image)
- 图片编辑 (Image Editing)
- 图生图 (Image-to-Image)
- 支持多种尺寸和风格

### 2. 视频生成 (Seedance 1.5)
- 文本生成视频 (Text-to-Video)
- 图片生成视频 (Image-to-Video)
- 控制镜头运动
- 支持首尾帧控制

### 3. 视觉理解 (Vision)
- 图像内容分析
- 对象检测和定位

### 4. 任务管理
- 查看生成进度
- 下载结果
- 管理历史记录

---

## 快速开始

### 安装

```bash
# 方式一：一键安装（推荐）
./install.sh

# 方式二：Docker
docker compose up --build

# 方式三：手动安装
pip install -r volcengine-api/requirements.txt
```

### 配置

```bash
# 方式一：环境变量（推荐 ✅ 最安全）
export ARK_API_KEY="your-api-key"

# 方式二：交互式配置
./scripts/configure.sh

# 方式三：配置文件
mkdir -p ~/.volcengine
echo 'api_key: "your-api-key"' > ~/.volcengine/config.yaml
chmod 600 ~/.volcengine/config.yaml  # 重要：设置安全权限
```

### 验证

```bash
./scripts/verify_install.sh
```

---

## 🔒 安全最佳实践

> ⚠️ **重要**: API Key 是敏感凭证，请遵循以下安全实践。

### 1. 推荐的密钥管理方式

| 方式 | 安全性 | 推荐场景 |
|------|--------|----------|
| 环境变量 | ⭐⭐⭐⭐⭐ | **推荐** - 所有场景 |
| 密钥管理服务 | ⭐⭐⭐⭐⭐ | 生产环境 |
| 配置文件 (带权限) | ⭐⭐⭐ | 本地开发 |

### 2. 环境变量配置（推荐）

```bash
# 临时设置（当前会话）
export ARK_API_KEY="your-api-key"

# 永久设置（添加到 shell 配置）
echo 'export ARK_API_KEY="your-api-key"' >> ~/.bashrc
source ~/.bashrc

# 验证设置
echo $ARK_API_KEY | head -c 4  # 应显示前4个字符
```

### 3. 配置文件安全

如果必须使用配置文件存储 API Key：

```bash
# 创建配置目录
mkdir -p ~/.volcengine

# 创建配置文件
cat > ~/.volcengine/config.yaml << 'EOF'
api_key: "your-api-key"
base_url: "https://ark.cn-beijing.volces.com/api/v3"
EOF

# 设置安全权限（关键！）
chmod 700 ~/.volcengine          # 目录：仅所有者可访问
chmod 600 ~/.volcengine/config.yaml  # 文件：仅所有者可读写
```

### 4. 文件权限验证

```bash
# 检查目录权限（应为 drwx------ 或 700）
ls -la ~ | grep .volcengine

# 检查文件权限（应为 -rw------- 或 600）
ls -la ~/.volcengine/config.yaml
```

### 5. 禁止事项

| 禁止 | 原因 |
|------|------|
| ❌ 将 API Key 提交到 Git | 会被公开访问 |
| ❌ 在日志中打印 API Key | 可能泄露 |
| ❌ 在 URL 中传递 API Key | 会被记录 |
| ❌ 硬编码 API Key | 难以轮换 |
| ❌ 共享 API Key | 无法追踪责任 |

### 6. .gitignore 配置

确保 `.gitignore` 包含以下内容：

```gitignore
# Volcengine config (may contain API keys)
.volcengine/
*.volcengine/

# Environment files
.env
.env.local
.env.*.local
```

### 7. 密钥轮换建议

```bash
# 定期更换 API Key（建议每90天）
# 1. 在火山引擎控制台生成新密钥
# 2. 更新环境变量或配置文件
# 3. 验证新密钥工作正常
# 4. 在控制台删除旧密钥
```

---

## 使用方法

### 图像生成

```
生成一张图片，内容是：夕阳下的海滩，有椰子树和海浪
```

```
生成图片，尺寸1024x768，内容是：城市夜景
```

### 视频生成

```
生成一个5秒的视频，内容是：镜头缓缓拉出，展现山景
```

```
用这张图片生成视频：https://example.com/image.jpg
```

### 视觉理解

```
分析这张图片：https://example.com/image.jpg
```

### 任务管理

```
查看我的任务列表
```

```
查看任务 task-123 的状态
```

```
下载任务 task-123 的结果
```

---

## 参数说明

### 图像生成参数

| 参数 | 必填 | 说明 | 默认值 |
|------|------|------|--------|
| prompt | 是 | 图片描述 | - |
| width | 否 | 宽度 | 1024 |
| height | 否 | 高度 | 1024 |
| negative_prompt | 否 | 负向提示词 | - |
| model | 否 | 模型ID | doubao-seedream-4-0-250828 |

### 视频生成参数

| 参数 | 必填 | 说明 | 默认值 |
|------|------|------|--------|
| prompt | 是 | 视频描述 | - |
| duration | 否 | 时长(秒) | 5 |
| aspect_ratio | 否 | 宽高比 | 16:9 |
| model | 否 | 模型ID | doubao-seedance-1-5-pro-251215 |

### 视觉理解参数

| 参数 | 必填 | 说明 | 默认值 |
|------|------|------|--------|
| image | 是 | 图片URL或本地路径 | - |
| prompt | 否 | 分析指令 | - |
| model | 否 | 模型ID | doubao-seed-1-6-vision-250815 |

---

## 配置

### 环境变量

| 变量 | 说明 | 必需 |
|------|------|------|
| `ARK_API_KEY` | 火山引擎API密钥 | **是** |
| `VOLCENGINE_BASE_URL` | API基础URL | 否 |
| `VOLCENGINE_OUTPUT_DIR` | 输出目录 | 否 |
| `VOLCENGINE_TIMEOUT` | 请求超时(秒) | 否 |
| `VOLCENGINE_MAX_RETRIES` | 最大重试次数 | 否 |

### 配置文件

**项目配置**: `.volcengine/config.yaml`

**全局配置**: `~/.volcengine/config.yaml`

```yaml
# api_key: "your-api-key"  # 推荐使用环境变量
base_url: "https://ark.cn-beijing.volces.com/api/v3"
timeout: 30
max_retries: 3
output_dir: "./output"
```

### 配置优先级

1. 环境变量 `ARK_API_KEY` （**推荐**）
2. 项目配置 `.volcengine/config.yaml`
3. 全局配置 `~/.volcengine/config.yaml`
4. 默认值

---

## 模型列表

| 功能 | 模型ID |
|------|--------|
| 图像生成 | doubao-seedream-4-0-250828 |
| 视频生成 | doubao-seedance-1-5-pro-251215 |
| 视觉理解 | doubao-seed-1-6-vision-250815 |

---

## 注意事项

1. **API Key 必需** - 请先设置环境变量或配置文件
2. **图像尺寸** - 建议使用64的倍数以获得最佳效果
3. **视频时长** - 限制在1-10秒
4. **异步任务** - 所有生成任务都是异步的，可以查看进度
5. **速率限制** - 注意API调用频率，避免触发限制
6. **数据持久化** - 任务状态和历史保存在 `~/.volcengine/` 目录

---

## 数据持久化说明

本 Skill 会在以下位置存储数据：

| 路径 | 内容 | 敏感性 |
|------|------|--------|
| `~/.volcengine/config.yaml` | 全局配置（可能含API Key） | ⚠️ 敏感 |
| `~/.volcengine/tasks/` | 任务历史 | 普通 |
| `~/.volcengine/state/` | 状态文件 | 普通 |
| `./.volcengine/config.yaml` | 项目配置（可能含API Key） | ⚠️ 敏感 |

**安全建议**:
- 确保配置文件权限为 600
- 不要将 `.volcengine/` 目录提交到版本控制
- 定期清理不需要的历史数据

---

## 错误处理

| 错误类型 | 说明 | 解决方案 |
|----------|------|----------|
| 认证错误 | API Key无效或未设置 | 检查ARK_API_KEY设置 |
| 速率限制 | 请求过于频繁 | 等待后重试 |
| 网络错误 | 无法连接API | 检查网络连接 |
| 参数错误 | 参数格式不正确 | 检查参数格式 |
| 模型错误 | 模型不可用 | 检查模型ID或联系客服 |

---

## 示例工作流

### 完整图像生成流程

```
1. 设置API Key:
   设置API Key: sk-xxx

2. 生成图片:
   生成一张图片：美丽的日落

3. 查看任务状态:
   查看任务状态

4. 下载结果:
   下载图片到本地
```

### 图片到视频流程

```
1. 生成初始图片:
   生成一张图片：山景

2. 用图片生成视频:
   用刚生成的图片生成视频，镜头向右移动

3. 查看进度:
   查看任务状态

4. 下载视频:
   下载视频到本地
```

---

## 部署方式

| 方式 | 时间 | 适用场景 |
|------|------|----------|
| 脚本安装 | 2-3分钟 | 本地开发、快速体验 |
| Docker | 3-5分钟 | 容器化环境、团队协作 |
| 手动安装 | 5-10分钟 | 自定义环境 |

详细部署说明请参考 [INSTALLATION.md](./docs/INSTALLATION.md)

---

## 相关文档

- [快速开始](./docs/QUICKSTART.md) - 30秒快速上手
- [安装指南](./docs/INSTALLATION.md) - 详细安装说明
- [使用示例](./docs/examples.md) - 更多代码示例
- [故障排除](./docs/troubleshooting.md) - 常见问题解决
- [README](./README.md) - 完整项目文档

---

## 获取帮助

```bash
# 查看帮助脚本
./scripts/help.sh

# 验证安装
./scripts/verify_install.sh
```

---

**欢迎使用火山引擎API助手！**

如需帮助，请说 "帮助" 或 "help"。
