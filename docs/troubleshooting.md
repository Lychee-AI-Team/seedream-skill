# 故障排查指南

## 目录

1. [常见错误](#常见错误)
2. [认证问题](#认证问题)
3. [网络问题](#网络问题)
4. [参数错误](#参数错误)
5. [任务失败](#任务失败)
6. [性能优化](#性能优化)

---

## 常见错误

### 错误: "API key not configured"

**原因**: 未设置API密钥

**解决方案**:
```bash
# 方式1: 环境变量（推荐）
export ARK_API_KEY="your-api-key"

# 方式2: 配置文件
mkdir -p .volcengine
echo 'api_key: "your-api-key"' > .volcengine/config.yaml
```

---

### 错误: "Rate limit exceeded"

**原因**: 请求频率超过限制

**解决方案**:
1. 等待一段时间后重试
2. 减少并发请求数量
3. 使用队列管理请求

```python
from toolkit.utils.retry import RetryConfig, retry_with_backoff

config = RetryConfig(
    max_attempts=5,
    base_delay=2.0,  # 增加重试延迟
    max_delay=120.0
)

@retry_with_backoff(config)
def api_call_with_retry():
    return client.post("/images/generate", json=params)
```

---

### 错误: "Network connection failed"

**原因**: 网络连接问题

**解决方案**:
1. 检查网络连接
2. 检查防火墙设置
3. 尝试使用代理

```python
# 配置代理
config.set("proxy", "http://proxy.example.com:8080")
```

---

## 认证问题

### 问题: 401 Unauthorized

**可能原因**:
1. API密钥无效
2. API密钥已过期
3. API密钥权限不足

**排查步骤**:
```python
# 1. 检查API密钥是否设置
config = ConfigManager()
api_key = config.get_api_key()
print(f"API Key: {api_key[:8]}..." if api_key else "未设置")

# 2. 测试API密钥
try:
    with VolcengineAPIClient(config) as client:
        result = client.get("/user/info")
        print("认证成功")
except AuthenticationError as e:
    print(f"认证失败: {e.message}")
```

### 问题: 403 Forbidden

**可能原因**:
1. API密钥没有访问该接口的权限
2. 账户余额不足

**解决方案**:
1. 检查API密钥权限
2. 充值账户

---

## 网络问题

### 问题: 连接超时

**解决方案**:
```python
# 增加超时时间
config = ConfigManager()
config.set("timeout", 60)  # 60秒

# 或在创建客户端时指定
client = VolcengineAPIClient(config)
client.timeout = 60
```

### 问题: SSL证书错误

**解决方案**:
```python
# 临时禁用SSL验证（仅用于测试）
import httpx
client = httpx.Client(verify=False)
```

⚠️ **警告**: 生产环境请勿禁用SSL验证

---

## 参数错误

### 问题: "Invalid parameters"

**常见原因**:
1. 缺少必需参数
2. 参数类型错误
3. 参数值超出范围

**解决方案**:
```python
# 使用验证器检查参数
from toolkit.validator import Validator

# 图像生成参数验证
result = Validator.validate_image_generation_params(
    prompt="测试",
    width=1024,
    height=768
)

if not result.is_valid:
    print("错误:")
    for error in result.errors:
        print(f"  - {error}")

if result.warnings:
    print("警告:")
    for warning in result.warnings:
        print(f"  - {warning}")
```

### 常见参数问题

#### 图像尺寸

```python
# ❌ 错误: 尺寸过小
width = 32  # 最小64

# ❌ 错误: 尺寸过大
width = 4096  # 最大2048

# ✅ 正确
width = 1024
height = 768

# ⚠️ 警告: 不是64的倍数
width = 100  # 会生成警告，建议使用64的倍数
```

#### 视频时长

```python
# ❌ 错误: 时长过短
duration = 0.5  # 最小1.0秒

# ❌ 错误: 时长过长
duration = 15.0  # 最大10.0秒

# ✅ 正确
duration = 5.0
```

---

## 任务失败

### 问题: 任务一直处于 RUNNING 状态

**可能原因**:
1. 服务器处理时间较长
2. 任务实际已失败但状态未更新

**解决方案**:
```python
import time

# 设置最大等待时间
max_wait = 300  # 5分钟
start_time = time.time()

while True:
    task = task_manager.get_task(task.id)
    
    # 检查超时
    if time.time() - start_time > max_wait:
        print("任务超时")
        break
    
    if task.status == TaskStatus.SUCCEEDED:
        print("成功")
        break
    elif task.status == TaskStatus.FAILED:
        print(f"失败: {task.error}")
        break
    
    time.sleep(5)
```

### 问题: 任务失败但错误信息不明确

**解决方案**:
```python
# 获取详细错误信息
task = task_manager.get_task(task.id)

if task.status == TaskStatus.FAILED:
    print(f"错误: {task.error}")
    
    # 检查是否有更多细节
    if task.result and task.result.metadata:
        print(f"详细信息: {task.result.metadata}")
```

---

## 性能优化

### 优化1: 并发请求

```python
import asyncio
from toolkit.api_client import VolcengineAPIClient

async def batch_generate(prompts):
    config = ConfigManager()
    
    async def generate(prompt):
        async with VolcengineAPIClient(config) as client:
            return await client.post("/images/generate", json={"prompt": prompt})
    
    tasks = [generate(p) for p in prompts]
    results = await asyncio.gather(*tasks)
    return results

# 运行
prompts = ["图片1", "图片2", "图片3"]
results = asyncio.run(batch_generate(prompts))
```

### 优化2: 缓存配置

```python
# 避免重复创建ConfigManager
_config = None

def get_config():
    global _config
    if _config is None:
        _config = ConfigManager()
    return _config
```

### 优化3: 批量下载

```python
from concurrent.futures import ThreadPoolExecutor

def batch_download(urls, output_dir):
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = []
        for i, url in enumerate(urls):
            path = f"{output_dir}/image_{i}.png"
            futures.append(executor.submit(FileUtils.download_file, url, path))
        
        for future in futures:
            future.result()
```

---

## 调试技巧

### 启用详细日志

```python
import logging

# 启用HTTP请求日志
logging.basicConfig(level=logging.DEBUG)

# 或只针对httpx
logging.getLogger("httpx").setLevel(logging.DEBUG)
```

### 检查请求详情

```python
# 使用curl测试API
import subprocess

def test_api_with_curl(endpoint, data):
    curl_cmd = f'''
    curl -X POST "{endpoint}" \
         -H "Authorization: Bearer {api_key}" \
         -H "Content-Type: application/json" \
         -d '{json.dumps(data)}'
    '''
    result = subprocess.run(curl_cmd, shell=True, capture_output=True, text=True)
    print(result.stdout)
```

---

## 获取帮助

如果以上方案都无法解决问题：

1. **查看文档**: [README.md](../README.md)
2. **搜索Issues**: [GitHub Issues](https://github.com/your-org/volcengine-api-skill/issues)
3. **提交新Issue**: 包含以下信息：
   - 错误消息
   - 重现步骤
   - 环境信息（Python版本、操作系统）
   - 相关代码片段

---

## 常见问题FAQ

**Q: 支持哪些图像格式？**
A: 支持PNG、JPEG、WebP格式

**Q: 视频最大时长是多少？**
A: 当前支持1-10秒的视频

**Q: 可以取消正在运行的任务吗？**
A: 可以，使用 `task_manager.update_task_status(task_id, TaskStatus.CANCELLED)`

**Q: 结果会保存多久？**
A: 生成的结果URL通常有效期为24小时，建议及时下载

**Q: 支持批量操作吗？**
A: 支持，请参考[高级用法](../docs/examples.md#批量生成)
