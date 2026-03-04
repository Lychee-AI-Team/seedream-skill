#!/usr/bin/env python3

import argparse
import importlib
import json
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "volcengine-api"))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run standardized Volcengine end-to-end smoke test")
    parser.add_argument("--image-prompt", default="赛博朋克风格的城市夜景")
    parser.add_argument("--video-prompt", default="镜头向上升，天空中飞行汽车呼啸而过")
    parser.add_argument("--poll-interval", type=float, default=5.0)
    parser.add_argument("--max-polls", type=int, default=24)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    run_smoke_test = importlib.import_module("toolkit.smoke_e2e").run_smoke_test

    result = run_smoke_test(
        image_prompt=args.image_prompt,
        video_prompt=args.video_prompt,
        poll_interval=args.poll_interval,
        max_polls=args.max_polls,
    )
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result.get("ok") else 1


if __name__ == "__main__":
    raise SystemExit(main())
