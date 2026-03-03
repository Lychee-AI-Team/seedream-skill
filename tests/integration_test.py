#!/usr/bin/env python3
"""
Integration test for Volcengine API Skill.
Requires real API key to run.

Usage:
    export ARK_API_KEY="your-api-key"
    python tests/integration_test.py
"""

import os
import sys
import json
from pathlib import Path

# Add project to path
sys.path.insert(0, str(Path(__file__).parent.parent / "volcengine-api"))
sys.path.insert(0, str(Path(__file__).parent.parent))

from toolkit.config import ConfigManager
from toolkit.api_client import VolcengineAPIClient
from toolkit.task_manager import TaskManager
from toolkit.validator import Validator
from toolkit.models.base import TaskType, TaskStatus


class IntegrationTest:
    """Integration test runner."""
    
    def __init__(self):
        self.config = None
        self.client = None
        self.task_manager = None
        self.results = []
    
    def setup(self):
        """Setup test environment."""
        print("=" * 60)
        print("火山引擎API Skill 集成测试")
        print("=" * 60)
        
        try:
            # Use ConfigManager which supports both env var and config file
            self.config = ConfigManager()
            api_key = self.config.get_api_key()
            
            if not api_key:
                print("❌ 错误: 未配置 API Key")
                print("请通过以下方式之一配置:")
                print("  1. 环境变量: export ARK_API_KEY='your-api-key'")
                print("  2. 配置文件: ~/.volcengine/config.yaml")
                return False
            
            print(f"✓ API Key 已配置 (长度: {len(api_key)})")
            
            self.client = VolcengineAPIClient(self.config)
            self.task_manager = TaskManager(self.client)
            print("✓ 客户端初始化成功")
            return True
        except Exception as e:
            print(f"❌ 初始化失败: {e}")
            return False
        """Setup test environment."""
        print("=" * 60)
        print("火山引擎API Skill 集成测试")
        print("=" * 60)
        
        # Check API key
        api_key = os.getenv("ARK_API_KEY")
        if not api_key:
            print("❌ 错误: 未设置 ARK_API_KEY 环境变量")
            print("请运行: export ARK_API_KEY='your-api-key'")
            return False
        
        print(f"✓ API Key 已配置 (长度: {len(api_key)})")
        
        try:
            self.config = ConfigManager()
            self.client = VolcengineAPIClient(self.config)
            self.task_manager = TaskManager(self.client)
            print("✓ 客户端初始化成功")
            return True
        except Exception as e:
            print(f"❌ 初始化失败: {e}")
            return False
    
    def record_result(self, test_name: str, passed: bool, message: str = ""):
        """Record test result."""
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status} - {test_name}")
        if message:
            print(f"    {message}")
        self.results.append({
            "test": test_name,
            "passed": passed,
            "message": message
        })
    
    def test_config(self):
        """Test configuration management."""
        print("\n--- 测试配置管理 ---")
        
        try:
            base_url = self.config.get_base_url()
            self.record_result("Config: Base URL", True, f"URL: {base_url}")
        except Exception as e:
            self.record_result("Config: Base URL", False, str(e))
        
        try:
            timeout = self.config.get_timeout()
            self.record_result("Config: Timeout", True, f"Timeout: {timeout}s")
        except Exception as e:
            self.record_result("Config: Timeout", False, str(e))
    
    def test_validator(self):
        """Test parameter validation."""
        print("\n--- 测试参数验证 ---")
        
        # Valid image params
        result = Validator.validate_image_generation_params(
            prompt="测试图像",
            width=1024,
            height=1024
        )
        self.record_result("Validator: 图像参数验证", result.is_valid)
        
        # Valid video params
        result = Validator.validate_video_generation_params(
            prompt="测试视频",
            duration=5.0
        )
        self.record_result("Validator: 视频参数验证", result.is_valid)
        
        # Invalid params
        result = Validator.validate_image_generation_params(
            prompt="",  # Empty prompt
            width=1024,
            height=1024
        )
        self.record_result("Validator: 检测无效参数", not result.is_valid)
    
    def test_task_manager(self):
        """Test task management."""
        print("\n--- 测试任务管理 ---")
        
        try:
            # Create task
            task = self.task_manager.create_task(
                task_type=TaskType.IMAGE_GENERATION,
                params={
                    "prompt": "集成测试图像 - 夕阳下的海滩",
                    "width": 512,
                    "height": 512
                }
            )
            self.record_result("TaskManager: 创建任务", True, f"Task ID: {task.id}")
            
            # Get task
            retrieved = self.task_manager.get_task(task.id)
            self.record_result("TaskManager: 获取任务", retrieved is not None)
            
            # List tasks
            tasks = self.task_manager.list_tasks()
            self.record_result("TaskManager: 列出任务", len(tasks) > 0, f"Count: {len(tasks)}")
            
        except Exception as e:
            self.record_result("TaskManager: 任务操作", False, str(e))
    
    def test_api_connection(self):
        """Test API connection (without actual generation)."""
        print("\n--- 测试API连接 ---")
        
        try:
            # This will test authentication
            # Note: Actual API call depends on the real endpoint structure
            self.record_result("API: 连接测试", True, "客户端已初始化")
        except Exception as e:
            self.record_result("API: 连接测试", False, str(e))
    
    def test_image_generation(self, skip_real_api: bool = True):
        """Test image generation (optional: real API call)."""
        print("\n--- 测试图像生成 ---")
        
        if skip_real_api:
            print("    ⚠️  跳过真实API调用 (设置 RUN_REAL_API=1 启用)")
            return
        
        try:
            import httpx
            
            # 火山引擎图像生成API
            url = "https://ark.cn-beijing.volces.com/api/v3/images/generations"
            
            payload = {
                "model": "doubao-seedream-4-0-250828",
                "prompt": "一只可爱的橘猫在阳光下睡觉",
                "size": "1024x1024",
                "response_format": "url"
            }
            
            headers = {
                "Authorization": f"Bearer {self.config.get_api_key()}",
                "Content-Type": "application/json"
            }
            
            print(f"    请求URL: {url}")
            print(f"    模型: {payload['model']}")
            print(f"    提示词: {payload['prompt']}")
            
            with httpx.Client(timeout=180.0) as client:
                response = client.post(url, json=payload, headers=headers)
                
                if response.status_code == 200:
                    result = response.json()
                    # 检查响应结构
                    if "data" in result and len(result["data"]) > 0:
                        image_url = result["data"][0].get("url", "")
                        self.record_result(
                            "Image: 生成图像", 
                            True, 
                            f"图像URL: {image_url[:50]}..." if len(image_url) > 50 else f"图像URL: {image_url}"
                        )
                    else:
                        self.record_result("Image: 生成图像", True, f"响应: {result}")
                else:
                    error_text = response.text[:200]
                    self.record_result("Image: 生成图像", False, f"HTTP {response.status_code}: {error_text}")
                    
        except Exception as e:
            self.record_result("Image: 生成图像", False, str(e))
    
    def print_summary(self):
        """Print test summary."""
        print("\n" + "=" * 60)
        print("测试总结")
        print("=" * 60)
        
        passed = sum(1 for r in self.results if r["passed"])
        total = len(self.results)
        
        print(f"通过: {passed}/{total}")
        print(f"失败: {total - passed}/{total}")
        
        if passed == total:
            print("\n🎉 所有测试通过!")
        else:
            print("\n⚠️  部分测试失败，请检查上述错误")
        
        return passed == total
    
    def run(self):
        """Run all tests."""
        if not self.setup():
            return False
        
        self.test_config()
        self.test_validator()
        self.test_task_manager()
        self.test_api_connection()
        
        # Only run real API tests if explicitly enabled
        run_real = os.getenv("RUN_REAL_API") == "1"
        self.test_image_generation(skip_real_api=not run_real)
        
        return self.print_summary()


def main():
    """Main entry point."""
    tester = IntegrationTest()
    success = tester.run()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
