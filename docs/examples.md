# 使用示例

## 目录

1. [基础示例](#基础示例)
2. [图像生成](#图像生成)
3. [视频生成](#视频生成)
4. [音频生成](#音频生成)
5. [视觉理解](#视觉理解)
6. [高级用法](#高级用法)

---

## 基础示例

### 完整工作流

```python
from toolkit import (
    VolcengineAPIClient,
    ConfigManager,
    TaskManager,
    Validator,
    FileUtils,
    Formatters
)
from toolkit.models.base import TaskType, TaskStatus

# 1. 配置
config = ConfigManager()
config.set("api_key", "your-api-key")

# 2. 创建客户端
with VolcengineAPIClient(config) as client:
    # 3. 创建任务管理器
    task_manager = TaskManager(client)
    
    # 4. 验证参数
    validation = Validator.validate_image_generation_params(
        prompt="美丽的日落",
        width=1024,
        height=768
    )
    
    if not validation.is_valid:
        print("参数错误:", validation.errors)
        return
    
    # 5. 创建任务
    task = task_manager.create_task(
        TaskType.IMAGE_GENERATION,
        {"prompt": "美丽的日落", "width": 1024, "height": 768}
    )
    print(f"任务ID: {task.id}")
    
    # 6. 等待完成
    import time
    while True:
        task = task_manager.get_task(task.id)
        print(f"状态: {task.status}")
        
        if task.status == TaskStatus.SUCCEEDED:
            break
        elif task.status == TaskStatus.FAILED:
            print(f"失败: {task.error}")
            return
        
        time.sleep(2)
    
    # 7. 下载结果
    output_path = FileUtils.get_unique_filename(
        config.get_output_dir(),
        "sunset",
        ".png"
    )
    FileUtils.download_file(task.result.url, output_path)
    print(f"保存到: {output_path}")
```

---

## 图像生成

### 文本生成图片

```python
# 简单用法
task = task_manager.create_task(
    TaskType.IMAGE_GENERATION,
    {"prompt": "一只可爱的猫咪"}
)

# 高级用法
task = task_manager.create_task(
    TaskType.IMAGE_GENERATION,
    {
        "prompt": "一只橙色的猫坐在窗台上，看着窗外的雨",
        "width": 1920,
        "height": 1080,
        "style": "realistic",
        "quality": "high"
    }
)
```

### 图片编辑

```python
task = task_manager.create_task(
    TaskType.IMAGE_EDIT,
    {
        "prompt": "给这只猫戴上红色蝴蝶结",
        "image_url": "https://example.com/cat.jpg",
        "mask_url": "https://example.com/mask.png"  # 可选
    }
)
```

### 图生图

```python
task = task_manager.create_task(
    TaskType.IMAGE_EDIT,
    {
        "prompt": "将这张照片转换为油画风格",
        "image_url": "https://example.com/photo.jpg",
        "strength": 0.7  # 编辑强度 0-1
    }
)
```

---

## 视频生成

### 文本生成视频

```python
# 简单用法
task = task_manager.create_task(
    TaskType.VIDEO_T2V,
    {"prompt": "海浪拍打沙滩的镜头"}
)

# 高级用法 - 控制镜头
task = task_manager.create_task(
    TaskType.VIDEO_T2V,
    {
        "prompt": "镜头从远处缓缓推进，展现山顶的风景",
        "duration": 5.0,
        "fps": 30,
        "resolution": "1080p"
    }
)
```

### 图片生成视频

```python
task = task_manager.create_task(
    TaskType.VIDEO_I2V,
    {
        "prompt": "让这只猫眨眼并摇尾巴",
        "image_url": "https://example.com/cat.jpg",
        "duration": 3.0
    }
)
```

### 首尾帧控制

```python
task = task_manager.create_task(
    TaskType.VIDEO_FRAMES,
    {
        "prompt": "从日出到日落的过渡",
        "first_frame_url": "https://example.com/sunrise.jpg",
        "last_frame_url": "https://example.com/sunset.jpg",
        "duration": 5.0
    }
)
```

---

## 音频生成

### 文本转语音

```python
# 简单用法
task = task_manager.create_task(
    TaskType.AUDIO_TTS,
    {"text": "欢迎使用火山引擎API"}
)

# 高级用法
task = task_manager.create_task(
    TaskType.AUDIO_TTS,
    {
        "text": "这是一段测试文本",
        "voice": "female_gentle",  # 音色选择
        "speed": 1.0,              # 语速
        "pitch": 0                 # 音调
    }
)
```

---

## 视觉理解

### 图像分析

```python
task = task_manager.create_task(
    TaskType.VISION_DETECTION,
    {
        "image_url": "https://example.com/scene.jpg",
        "task": "describe"  # 或 "detect", "segment"
    }
)

# 获取结果
result = task_manager.get_task(task.id)
print(f"描述: {result.result.metadata['description']}")
```

### 对象检测

```python
task = task_manager.create_task(
    TaskType.VISION_DETECTION,
    {
        "image_url": "https://example.com/street.jpg",
        "task": "detect",
        "objects": ["car", "person", "bicycle"]  # 要检测的对象
    }
)

# 获取检测结果
result = task_manager.get_task(task.id)
for obj in result.result.metadata['objects']:
    print(f"{obj['label']}: {obj['confidence']:.2%}")
```

---

## 高级用法

### 批量生成

```python
# 批量生成图像
prompts = [
    "日落时的海滩",
    "雪山上的日出",
    "森林中的小溪"
]

tasks = []
for prompt in prompts:
    task = task_manager.create_task(
        TaskType.IMAGE_GENERATION,
        {"prompt": prompt}
    )
    tasks.append(task)

# 等待所有任务完成
for task in tasks:
    while True:
        task = task_manager.get_task(task.id)
        if task.status in [TaskStatus.SUCCEEDED, TaskStatus.FAILED]:
            break
        time.sleep(2)
    
    if task.status == TaskStatus.SUCCEEDED:
        print(f"完成: {task.result.url}")
```

### 带重试的下载

```python
from toolkit.utils.retry import retry_with_backoff, RetryConfig

config = RetryConfig(max_attempts=5, base_delay=1.0)

@retry_with_backoff(config=config)
def download_with_retry(url, path):
    return FileUtils.download_file(url, path)

download_with_retry(task.result.url, "./output/image.png")
```

### 进度跟踪

```python
from toolkit.utils.formatters import Formatters

# 显示进度
tasks = task_manager.list_tasks()
total = len(tasks)
completed = sum(1 for t in tasks if t.status == TaskStatus.SUCCEEDED)

progress = Formatters.format_progress(completed, total)
print(f"进度: {progress}")
```

### 任务历史

```python
from toolkit.state_manager import StateManager

state = StateManager()

# 获取历史记录
history = state.get_history(limit=10)
for entry in history:
    print(f"{entry['timestamp']}: {entry['operation']}")

# 获取统计
total_ops = state.get_total_operations()
image_count = state.get_operation_count("create_image_generation")
print(f"总操作: {total_ops}, 图像生成: {image_count}")
```

### 上下文引导

```python
from toolkit.guide_generator import GuideGenerator

# 获取欢迎引导
welcome = GuideGenerator.get_welcome_guide()
print(welcome)

# 获取操作后引导
guide = GuideGenerator.get_post_operation_guide(
    TaskType.IMAGE_GENERATION,
    {"url": "https://example.com/image.png"}
)
print(guide)

# 获取上下文建议
suggestions = GuideGenerator.get_contextual_suggestions(
    state_manager,
    {"has_image": True}
)
for suggestion in suggestions:
    print(f"- {suggestion}")
```

---

## 完整示例应用

```python
#!/usr/bin/env python3
"""
火山引擎API示例应用
"""

import os
import time
from toolkit import (
    VolcengineAPIClient,
    ConfigManager,
    TaskManager,
    Validator,
    FileUtils,
    Formatters,
    GuideGenerator
)
from toolkit.models.base import TaskType, TaskStatus
from toolkit.error_handler import VolcengineError

def main():
    # 配置
    config = ConfigManager()
    if not config.get_api_key():
        print("请设置 ARK_API_KEY 环境变量")
        return
    
    # 显示欢迎信息
    print(GuideGenerator.get_welcome_guide())
    
    # 创建客户端
    with VolcengineAPIClient(config) as client:
        task_manager = TaskManager(client)
        
        while True:
            # 获取用户输入
            user_input = input("\n请输入命令 (或 'quit' 退出): ").strip()
            
            if user_input.lower() == 'quit':
                break
            
            # 解析命令
            if "生成图片" in user_input or "图像" in user_input:
                handle_image_generation(task_manager, user_input)
            elif "生成视频" in user_input or "视频" in user_input:
                handle_video_generation(task_manager, user_input)
            else:
                print("未识别的命令，请重试")

def handle_image_generation(task_manager, user_input):
    """处理图像生成"""
    # 提取提示词
    prompt = user_input.replace("生成图片", "").replace("图像", "").strip()
    
    # 验证
    result = Validator.validate_image_generation_params(prompt=prompt)
    if not result.is_valid:
        print(f"错误: {result.errors}")
        return
    
    # 创建任务
    task = task_manager.create_task(
        TaskType.IMAGE_GENERATION,
        {"prompt": prompt}
    )
    print(f"任务已创建: {task.id}")
    
    # 等待完成
    print("生成中...")
    while True:
        task = task_manager.get_task(task.id)
        if task.status == TaskStatus.SUCCEEDED:
            print(f"\n✅ 成功!")
            print(f"URL: {task.result.url}")
            
            # 显示后续引导
            guide = GuideGenerator.get_post_operation_guide(
                TaskType.IMAGE_GENERATION,
                {"url": task.result.url}
            )
            print(guide)
            break
        elif task.status == TaskStatus.FAILED:
            print(f"\n❌ 失败: {task.error}")
            break
        time.sleep(2)

if __name__ == "__main__":
    try:
        main()
    except VolcengineError as e:
        print(f"\n❌ {e.message}")
        print(f"💡 {e.solution}")
```

---

## 更多示例

查看 `examples/` 目录获取更多完整示例：

- `examples/basic_usage.py` - 基础用法
- `examples/batch_processing.py` - 批量处理
- `examples/advanced_features.py` - 高级功能
- `examples/cli_app.py` - 命令行应用
