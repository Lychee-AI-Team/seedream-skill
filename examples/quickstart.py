#!/usr/bin/env python3
# pyright: reportMissingImports=false
"""Volcengine API quickstart examples.

This script demonstrates three common workflows:
1) Image generation
2) Video generation
3) Vision understanding

It expects `ARK_API_KEY` to be available in the environment.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Any


# Add project root (one level above `examples/`) to import `toolkit` modules.
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from toolkit.api_client import VolcengineAPIClient  # noqa: E402
from toolkit.config import ConfigManager  # noqa: E402


def _require_api_key() -> str:
    """Read ARK_API_KEY and raise a clear error if it is missing."""
    api_key = os.getenv("ARK_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError(
            "Missing ARK_API_KEY. Please export it before running this script."
        )
    return api_key


def image_generation_example(client: VolcengineAPIClient) -> dict[str, Any]:
    """Run a text-to-image request using Seedream 4.0 model."""
    payload = {
        "model": "doubao-seedream-4-0-250828",
        "prompt": "A cinematic sunset over a quiet coastal town, warm tones, ultra detailed",
        "size": "1024x1024",
        "n": 1,
    }
    return client.post("/images/generate", json=payload)


def video_generation_example(client: VolcengineAPIClient) -> dict[str, Any]:
    """Run a text-to-video request using Seedance 1.5 Pro model."""
    payload = {
        "model": "doubao-seedance-1-5-pro-251215",
        "prompt": "A drone shot flying forward through a bamboo forest at dawn, smooth camera motion",
        "duration": 5,
        "resolution": "720p",
    }
    return client.post("/videos/generate", json=payload)


def vision_understanding_example(client: VolcengineAPIClient) -> dict[str, Any]:
    """Run a multimodal understanding request using Seed 1.6 Vision model."""
    payload = {
        "model": "doubao-seed-1-6-vision-250815",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Describe the image in detail and list the key objects.",
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": "https://images.unsplash.com/photo-1501785888041-af3ef285b470"
                        },
                    },
                ],
            }
        ],
    }
    return client.post("/chat/completions", json=payload)


def main() -> int:
    """Execute all three examples with defensive error handling.

    We intentionally run each call in its own `try` block to make it easier
    to identify which workflow failed when debugging credentials, permissions,
    payload shape, or endpoint configuration.
    """
    try:
        api_key = _require_api_key()
    except RuntimeError as exc:
        print(f"[config error] {exc}")
        return 1

    # Configure client from environment-driven key to avoid hardcoded secrets.
    config = ConfigManager()
    config.set("api_key", api_key)

    try:
        with VolcengineAPIClient(config) as client:
            try:
                image_result = image_generation_example(client)
                print("[image generation] success")
                print(image_result)
            except Exception as exc:  # pylint: disable=broad-except
                print(f"[image generation] failed: {exc}")

            try:
                video_result = video_generation_example(client)
                print("[video generation] success")
                print(video_result)
            except Exception as exc:  # pylint: disable=broad-except
                print(f"[video generation] failed: {exc}")

            try:
                vision_result = vision_understanding_example(client)
                print("[vision understanding] success")
                print(vision_result)
            except Exception as exc:  # pylint: disable=broad-except
                print(f"[vision understanding] failed: {exc}")
    except Exception as exc:  # pylint: disable=broad-except
        print(f"[fatal] unexpected error while creating/using API client: {exc}")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
