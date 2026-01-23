#!/usr/bin/env python3
"""
媒体生成器 - Remotion 桥接工具
为社交媒体发布生成图片和视频内容
"""

import json
import os
import subprocess
import sys
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List

# 配置
CONFIG_DIR = Path(__file__).parent.parent / ".social_publisher"
OUTPUT_DIR = CONFIG_DIR / "media_output"

# 平台预设尺寸
PLATFORM_PRESETS = {
    "twitter": {
        "video": {"width": 1280, "height": 720, "fps": 30},
        "image": {"width": 1200, "height": 675}
    },
    "xiaohongshu": {
        "video": {"width": 1080, "height": 1920, "fps": 30},  # 竖屏
        "image": {"width": 1080, "height": 1440}  # 3:4 比例
    },
    "wechat": {
        "video": {"width": 1920, "height": 1080, "fps": 30},
        "image": {"width": 900, "height": 500}
    }
}

# Remotion 模板映射
REMOTION_TEMPLATES = {
    "text_animation": "TextAnimation",
    "data_visualization": "DataVisualization",
    "list_countdown": "ListCountdown",
    "product_showcase": "ProductShowcase"
}


@dataclass
class MediaSpec:
    """媒体规格"""
    platform: str
    media_type: str  # "image" or "video"
    width: int
    height: int
    fps: int = 30
    duration_seconds: int = 15
    template: str = "text_animation"


@dataclass
class MediaResult:
    """媒体生成结果"""
    success: bool
    file_path: str = ""
    width: int = 0
    height: int = 0
    duration_seconds: int = 0
    template: str = ""
    error: str = ""


def ensure_dirs():
    """确保目录存在"""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def get_preset(platform: str, media_type: str) -> Dict:
    """获取平台预设配置"""
    preset = PLATFORM_PRESETS.get(platform, PLATFORM_PRESETS["twitter"])
    return preset.get(media_type, preset["image"])


def find_remotion_project() -> Optional[Path]:
    """查找 Remotion 项目路径"""
    # 检查常见位置
    possible_paths = [
        Path.home() / ".claude" / "skills" / "video-producer",
        Path(__file__).parent.parent.parent / "video-producer",
        Path.cwd() / "video-producer"
    ]

    for path in possible_paths:
        if (path / "package.json").exists():
            return path

    return None


def generate_remotion_props(spec: MediaSpec, content: Dict) -> Dict:
    """生成 Remotion 组件 props"""
    return {
        "title": content.get("title", ""),
        "subtitle": content.get("subtitle", ""),
        "items": content.get("items", []),
        "backgroundColor": content.get("background_color", "#1a1a2e"),
        "textColor": content.get("text_color", "#ffffff"),
        "accentColor": content.get("accent_color", "#4ecdc4")
    }


def sanitize_filename(name: str) -> str:
    """清理文件名，防止路径遍历攻击"""
    if not name:
        return ""
    # 只保留字母数字、下划线和连字符
    return "".join(c for c in name if c.isalnum() or c in "_-")


def generate_video(spec: MediaSpec, content: Dict, output_name: str = None) -> MediaResult:
    """使用 Remotion 生成视频"""
    ensure_dirs()

    remotion_path = find_remotion_project()
    if not remotion_path:
        return MediaResult(
            success=False,
            error="Remotion 项目未找到。请确保 video-producer skill 已安装。"
        )

    # 生成输出文件名（清理用户输入防止路径遍历）
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    if output_name:
        output_name = sanitize_filename(output_name)
    output_name = output_name or f"{spec.platform}_{timestamp}"
    output_file = OUTPUT_DIR / f"{output_name}.mp4"

    # 获取 Remotion 组件 ID
    composition_id = REMOTION_TEMPLATES.get(spec.template, "TextAnimation")

    # 生成 props
    props = generate_remotion_props(spec, content)
    props_json = json.dumps(props)

    # 计算帧数
    total_frames = spec.duration_seconds * spec.fps

    # 构建 Remotion 命令
    cmd = [
        "npx", "remotion", "render",
        f"src/index.ts",
        composition_id,
        str(output_file),
        "--props", props_json,
        "--width", str(spec.width),
        "--height", str(spec.height),
        "--fps", str(spec.fps),
        "--frames", f"0-{total_frames - 1}"
    ]

    try:
        result = subprocess.run(
            cmd,
            cwd=str(remotion_path),
            capture_output=True,
            text=True,
            timeout=300  # 5分钟超时
        )

        if result.returncode == 0 and output_file.exists():
            return MediaResult(
                success=True,
                file_path=str(output_file),
                width=spec.width,
                height=spec.height,
                duration_seconds=spec.duration_seconds,
                template=spec.template
            )
        else:
            error_details = []
            if result.stderr:
                error_details.append(f"Stderr: {result.stderr}")
            if result.stdout:
                error_details.append(f"Stdout: {result.stdout}")
            error_msg = "Remotion 渲染失败\n" + "\n".join(error_details) if error_details else "Remotion 渲染失败 (无输出)"
            return MediaResult(success=False, error=error_msg)

    except subprocess.TimeoutExpired:
        return MediaResult(success=False, error="渲染超时 (5分钟)")
    except Exception as e:
        return MediaResult(success=False, error=str(e))


def generate_image(spec: MediaSpec, content: Dict, output_name: str = None) -> MediaResult:
    """生成静态图片 (使用 Remotion 渲染单帧)"""
    ensure_dirs()

    remotion_path = find_remotion_project()
    if not remotion_path:
        return MediaResult(
            success=False,
            error="Remotion 项目未找到。请确保 video-producer skill 已安装。"
        )

    # 生成输出文件名（清理用户输入防止路径遍历）
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    if output_name:
        output_name = sanitize_filename(output_name)
    output_name = output_name or f"{spec.platform}_{timestamp}"
    output_file = OUTPUT_DIR / f"{output_name}.png"

    # 获取 Remotion 组件 ID
    composition_id = REMOTION_TEMPLATES.get(spec.template, "TextAnimation")

    # 生成 props
    props = generate_remotion_props(spec, content)
    props_json = json.dumps(props)

    # 构建 Remotion still 命令
    cmd = [
        "npx", "remotion", "still",
        f"src/index.ts",
        composition_id,
        str(output_file),
        "--props", props_json,
        "--width", str(spec.width),
        "--height", str(spec.height),
        "--frame", "0"
    ]

    try:
        result = subprocess.run(
            cmd,
            cwd=str(remotion_path),
            capture_output=True,
            text=True,
            timeout=120  # 2分钟超时
        )

        if result.returncode == 0 and output_file.exists():
            return MediaResult(
                success=True,
                file_path=str(output_file),
                width=spec.width,
                height=spec.height,
                duration_seconds=0,
                template=spec.template
            )
        else:
            error_details = []
            if result.stderr:
                error_details.append(f"Stderr: {result.stderr}")
            if result.stdout:
                error_details.append(f"Stdout: {result.stdout}")
            error_msg = "Remotion 渲染失败\n" + "\n".join(error_details) if error_details else "Remotion 渲染失败 (无输出)"
            return MediaResult(success=False, error=error_msg)

    except subprocess.TimeoutExpired:
        return MediaResult(success=False, error="渲染超时 (2分钟)")
    except Exception as e:
        return MediaResult(success=False, error=str(e))


def generate_media(platform: str, media_type: str, content: Dict,
                   template: str = "text_animation",
                   duration: int = 15,
                   output_name: str = None) -> MediaResult:
    """统一媒体生成接口"""
    preset = get_preset(platform, media_type)

    spec = MediaSpec(
        platform=platform,
        media_type=media_type,
        width=preset["width"],
        height=preset["height"],
        fps=preset.get("fps", 30),
        duration_seconds=duration,
        template=template
    )

    if media_type == "video":
        return generate_video(spec, content, output_name)
    else:
        return generate_image(spec, content, output_name)


def list_templates() -> List[str]:
    """列出可用模板"""
    return list(REMOTION_TEMPLATES.keys())


def list_platforms() -> List[str]:
    """列出支持的平台"""
    return list(PLATFORM_PRESETS.keys())


# ========== CLI ==========

def main():
    import argparse

    parser = argparse.ArgumentParser(description="媒体生成器 - Remotion 桥接工具")
    subparsers = parser.add_subparsers(dest="command")

    # generate 命令
    gen_parser = subparsers.add_parser("generate", help="生成媒体")
    gen_parser.add_argument("--platform", "-p", choices=list_platforms(), required=True)
    gen_parser.add_argument("--type", "-t", choices=["image", "video"], required=True)
    gen_parser.add_argument("--template", choices=list_templates(), default="text_animation")
    gen_parser.add_argument("--duration", "-d", type=int, default=15, help="视频时长（秒）")
    gen_parser.add_argument("--title", required=True, help="标题")
    gen_parser.add_argument("--subtitle", help="副标题")
    gen_parser.add_argument("--items", help="列表项目（JSON 数组）")
    gen_parser.add_argument("--output", "-o", help="输出文件名（不含扩展名）")
    gen_parser.add_argument("--json", "-j", action="store_true", help="输出 JSON 格式")

    # info 命令
    info_parser = subparsers.add_parser("info", help="显示配置信息")

    # check 命令
    check_parser = subparsers.add_parser("check", help="检查 Remotion 环境")

    args = parser.parse_args()

    if args.command == "generate":
        content = {
            "title": args.title,
            "subtitle": args.subtitle or "",
            "items": json.loads(args.items) if args.items else []
        }

        result = generate_media(
            platform=args.platform,
            media_type=args.type,
            content=content,
            template=args.template,
            duration=args.duration,
            output_name=args.output
        )

        if args.json:
            print(json.dumps(asdict(result), ensure_ascii=False, indent=2))
        else:
            if result.success:
                print(f"✅ 媒体生成成功!")
                print(f"   文件: {result.file_path}")
                print(f"   尺寸: {result.width}x{result.height}")
                if result.duration_seconds:
                    print(f"   时长: {result.duration_seconds}s")
            else:
                print(f"❌ 媒体生成失败: {result.error}")
                sys.exit(1)

    elif args.command == "info":
        print("🎬 媒体生成器配置")
        print("\n📁 输出目录:")
        print(f"   {OUTPUT_DIR}")

        print("\n📐 平台预设:")
        for platform, presets in PLATFORM_PRESETS.items():
            print(f"\n   {platform}:")
            for media_type, preset in presets.items():
                size = f"{preset['width']}x{preset['height']}"
                fps = f", {preset.get('fps', 30)}fps" if 'fps' in preset else ""
                print(f"      {media_type}: {size}{fps}")

        print("\n🎭 可用模板:")
        for name, composition in REMOTION_TEMPLATES.items():
            print(f"   • {name} -> {composition}")

        remotion_path = find_remotion_project()
        print(f"\n🔧 Remotion 项目:")
        if remotion_path:
            print(f"   ✅ {remotion_path}")
        else:
            print("   ❌ 未找到")

    elif args.command == "check":
        print("🔍 检查 Remotion 环境...")

        # 检查 Node.js
        try:
            result = subprocess.run(["node", "--version"], capture_output=True, text=True)
            print(f"   ✅ Node.js: {result.stdout.strip()}")
        except:
            print("   ❌ Node.js 未安装")
            sys.exit(1)

        # 检查 npx
        try:
            result = subprocess.run(["npx", "--version"], capture_output=True, text=True)
            print(f"   ✅ npx: {result.stdout.strip()}")
        except:
            print("   ❌ npx 未找到")
            sys.exit(1)

        # 检查 Remotion 项目
        remotion_path = find_remotion_project()
        if remotion_path:
            print(f"   ✅ Remotion 项目: {remotion_path}")

            # 检查依赖
            if (remotion_path / "node_modules").exists():
                print("   ✅ 依赖已安装")
            else:
                print("   ⚠️ 依赖未安装，需要运行 npm install")
        else:
            print("   ❌ Remotion 项目未找到")
            print("   💡 请确保 video-producer skill 已安装")
            sys.exit(1)

        print("\n✅ 环境检查完成")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
