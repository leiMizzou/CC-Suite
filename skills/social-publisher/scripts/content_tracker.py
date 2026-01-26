#!/usr/bin/env python3
"""
内容追踪和核查系统
用于记录社交媒体运营全流程的内容，并在发布后进行验证

Features:
- Atomic file writes (temp file + rename) to prevent data corruption
- JSON validation on load to detect corrupted files
- Backup creation before writes for recovery
"""

import json
import os
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Any

# 配置目录
CONFIG_DIR = Path(__file__).parent.parent / ".social_publisher"
SESSIONS_DIR = CONFIG_DIR / "sessions"
BACKUP_DIR = CONFIG_DIR / "backups"


def ensure_dirs():
    """确保目录存在"""
    SESSIONS_DIR.mkdir(parents=True, exist_ok=True)
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)


def validate_json_data(data: Any, schema_name: str = "session") -> bool:
    """
    验证 JSON 数据的基本结构
    Returns True if valid, raises ValueError if invalid
    """
    if not isinstance(data, dict):
        raise ValueError(f"Invalid {schema_name}: expected dict, got {type(data).__name__}")

    if schema_name == "session":
        required_fields = ["session_id", "topic", "created_at", "status"]
        for field in required_fields:
            if field not in data:
                raise ValueError(f"Invalid session: missing required field '{field}'")

    return True


def atomic_write_json(filepath: Path, data: dict, backup: bool = True) -> None:
    """
    原子写入 JSON 文件
    使用临时文件 + 重命名模式，确保写入要么完全成功，要么完全失败

    Args:
        filepath: 目标文件路径
        data: 要写入的数据
        backup: 是否在写入前创建备份
    """
    filepath = Path(filepath)

    # 1. 如果目标文件存在且需要备份，先创建备份
    if backup and filepath.exists():
        backup_name = f"{filepath.stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.bak"
        backup_path = BACKUP_DIR / backup_name
        try:
            shutil.copy2(filepath, backup_path)
        except Exception:
            pass  # 备份失败不阻止写入

    # 2. 先序列化 JSON，确保数据可以正确序列化
    try:
        json_str = json.dumps(data, ensure_ascii=False, indent=2)
    except (TypeError, ValueError) as e:
        raise ValueError(f"Failed to serialize data to JSON: {e}")

    # 3. 写入临时文件（在同一目录下，确保原子重命名）
    fd, temp_path = tempfile.mkstemp(
        dir=filepath.parent,
        prefix=f".{filepath.stem}_",
        suffix=".tmp"
    )

    try:
        # 写入数据
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            f.write(json_str)
            f.flush()
            os.fsync(f.fileno())  # 确保数据写入磁盘

        # 4. 原子重命名（在同一文件系统上是原子的）
        os.replace(temp_path, filepath)

    except Exception as e:
        # 清理临时文件
        try:
            os.unlink(temp_path)
        except OSError:
            pass
        raise IOError(f"Failed to write file: {e}")


def safe_load_json(filepath: Path) -> dict:
    """
    安全加载 JSON 文件，带有验证和错误恢复

    Args:
        filepath: JSON 文件路径

    Returns:
        解析后的 dict

    Raises:
        FileNotFoundError: 文件不存在
        ValueError: JSON 解析失败或验证失败
    """
    filepath = Path(filepath)

    if not filepath.exists():
        raise FileNotFoundError(f"File not found: {filepath}")

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        if not content.strip():
            raise ValueError(f"Empty file: {filepath}")

        data = json.loads(content)
        validate_json_data(data, "session")
        return data

    except json.JSONDecodeError as e:
        # 尝试从备份恢复
        backup_files = sorted(BACKUP_DIR.glob(f"{filepath.stem}_*.bak"), reverse=True)
        if backup_files:
            print(f"⚠️ Corrupted file detected, attempting recovery from backup...")
            try:
                with open(backup_files[0], "r", encoding="utf-8") as f:
                    data = json.load(f)
                # 恢复成功，重写原文件
                atomic_write_json(filepath, data, backup=False)
                print(f"✅ Recovered from backup: {backup_files[0].name}")
                return data
            except Exception:
                pass

        raise ValueError(f"Invalid JSON in {filepath}: {e}")


class ContentTracker:
    """内容追踪器"""

    def __init__(self, topic: str):
        ensure_dirs()
        self.topic = topic
        self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_file = SESSIONS_DIR / f"session_{self.session_id}.json"

        self.data = {
            "session_id": self.session_id,
            "topic": topic,
            "created_at": datetime.now().isoformat(),
            "status": "initialized",

            # Phase 1: 搜索结果
            "search": {
                "query": "",
                "time_range": "",
                "total_found": 0,
                "posts": []  # 所有找到的帖子
            },

            # Phase 2: 选定互动的帖子
            "engagement": {
                "selected_posts": [],  # 选定要互动的帖子ID
                "liked": [],           # 已点赞的帖子ID
                "replied": [],         # 已回复的帖子ID
                "replies_content": {}  # 回复内容 {post_id: reply_text}
            },

            # Phase 3: 提炼的内容
            "distilled": {
                "trends": [],
                "key_points": [],
                "quotes": [],
                "summary": ""
            },

            # Phase 4: 各平台生成的内容
            "generated_content": {
                "twitter": {
                    "thread": [],  # 每条推文
                    "total_tweets": 0
                },
                "xiaohongshu": {
                    "title": "",
                    "content": "",
                    "hashtags": []
                },
                "wechat": {
                    "title": "",
                    "content": "",
                    "summary": ""
                }
            },

            # Phase 4.5: 生成的媒体内容 (图片/视频)
            "generated_media": {
                "twitter": {
                    "type": "",          # image, video, none
                    "file_path": "",
                    "dimensions": {"width": 0, "height": 0},
                    "duration_seconds": 0,  # 仅视频
                    "template": "",      # Remotion 模板名
                    "generated_at": ""
                },
                "xiaohongshu": {
                    "type": "",
                    "file_path": "",
                    "dimensions": {"width": 0, "height": 0},
                    "duration_seconds": 0,
                    "template": "",
                    "generated_at": ""
                },
                "wechat": {
                    "type": "",
                    "file_path": "",
                    "dimensions": {"width": 0, "height": 0},
                    "duration_seconds": 0,
                    "template": "",
                    "generated_at": ""
                }
            },

            # Phase 5: 发布状态
            "publish_status": {
                "twitter": {
                    "status": "pending",  # pending, published, failed, partial
                    "published_count": 0,
                    "expected_count": 0,
                    "urls": [],
                    "errors": []
                },
                "xiaohongshu": {
                    "status": "pending",
                    "url": "",
                    "errors": []
                },
                "wechat": {
                    "status": "pending",
                    "url": "",
                    "errors": []
                }
            },

            # Phase 5.5: 媒体上传状态
            "media_upload_status": {
                "twitter": {
                    "status": "pending",  # pending, uploaded, failed, skipped
                    "uploaded_at": "",
                    "errors": []
                },
                "xiaohongshu": {
                    "status": "pending",
                    "uploaded_at": "",
                    "errors": []
                },
                "wechat": {
                    "status": "pending",
                    "uploaded_at": "",
                    "errors": []
                }
            },

            # Phase 6: 核查结果
            "verification": {
                "verified_at": "",
                "twitter_verified": False,
                "xiaohongshu_verified": False,
                "wechat_verified": False,
                "issues": [],
                "notes": ""
            }
        }

        self._save()

    def _save(self):
        """保存会话数据（原子写入）"""
        atomic_write_json(self.session_file, self.data, backup=True)

    @classmethod
    def load(cls, session_id: str) -> "ContentTracker":
        """加载已有会话（带验证和错误恢复）"""
        session_file = SESSIONS_DIR / f"session_{session_id}.json"

        try:
            data = safe_load_json(session_file)
        except FileNotFoundError:
            raise FileNotFoundError(f"Session {session_id} not found")
        except ValueError as e:
            raise ValueError(f"Failed to load session {session_id}: {e}")

        tracker = cls.__new__(cls)
        tracker.topic = data["topic"]
        tracker.session_id = session_id
        tracker.session_file = session_file
        tracker.data = data
        return tracker

    @classmethod
    def get_latest_session(cls) -> Optional["ContentTracker"]:
        """获取最新的会话"""
        ensure_dirs()
        sessions = list(SESSIONS_DIR.glob("session_*.json"))
        if not sessions:
            return None
        latest = max(sessions, key=lambda p: p.stat().st_mtime)
        session_id = latest.stem.replace("session_", "")
        return cls.load(session_id)

    # ========== Phase 1: 搜索 ==========

    def record_search(self, query: str, time_range: str, posts: List[Dict]):
        """记录搜索结果"""
        self.data["search"]["query"] = query
        self.data["search"]["time_range"] = time_range
        self.data["search"]["total_found"] = len(posts)
        self.data["search"]["posts"] = posts
        self.data["status"] = "searched"
        self._save()
        print(f"📝 已记录 {len(posts)} 条搜索结果")

    # ========== Phase 2: 互动 ==========

    def record_selected_for_engagement(self, post_ids: List[str]):
        """记录选定要互动的帖子"""
        self.data["engagement"]["selected_posts"] = post_ids
        self._save()
        print(f"📝 已记录 {len(post_ids)} 条选定互动的帖子")

    def record_like(self, post_id: str):
        """记录点赞"""
        if post_id not in self.data["engagement"]["liked"]:
            self.data["engagement"]["liked"].append(post_id)
            self._save()

    def record_reply(self, post_id: str, reply_text: str):
        """记录回复"""
        if post_id not in self.data["engagement"]["replied"]:
            self.data["engagement"]["replied"].append(post_id)
        self.data["engagement"]["replies_content"][post_id] = reply_text
        self._save()

    # ========== Phase 3: 提炼 ==========

    def record_distilled_content(self, trends: List[str], key_points: List[str],
                                  quotes: List[Dict], summary: str):
        """记录提炼的内容"""
        self.data["distilled"] = {
            "trends": trends,
            "key_points": key_points,
            "quotes": quotes,
            "summary": summary
        }
        self.data["status"] = "distilled"
        self._save()
        print(f"📝 已记录提炼内容: {len(trends)} 个趋势, {len(key_points)} 个要点")

    # ========== Phase 4: 生成内容 ==========

    def record_twitter_content(self, thread: List[str]):
        """记录 Twitter Thread 内容"""
        self.data["generated_content"]["twitter"]["thread"] = thread
        self.data["generated_content"]["twitter"]["total_tweets"] = len(thread)
        self.data["publish_status"]["twitter"]["expected_count"] = len(thread)
        self._save()
        print(f"📝 已记录 Twitter Thread: {len(thread)} 条推文")

    def record_xiaohongshu_content(self, title: str, content: str, hashtags: List[str] = None):
        """记录小红书内容"""
        self.data["generated_content"]["xiaohongshu"] = {
            "title": title,
            "content": content,
            "hashtags": hashtags or []
        }
        self._save()
        print(f"📝 已记录小红书内容: {title}")

    def record_wechat_content(self, title: str, content: str, summary: str = ""):
        """记录微信公众号内容"""
        self.data["generated_content"]["wechat"] = {
            "title": title,
            "content": content,
            "summary": summary
        }
        self._save()
        print(f"📝 已记录微信公众号内容: {title}")

    # ========== Phase 4.5: 媒体生成 ==========

    def record_media_generation(self, platform: str, media_type: str, file_path: str,
                                 width: int, height: int, duration: int = 0,
                                 template: str = ""):
        """记录媒体生成结果"""
        valid_platforms = list(self.data["generated_media"].keys())
        if platform not in self.data["generated_media"]:
            raise ValueError(f"不支持的平台: {platform}. 支持的平台: {valid_platforms}")

        self.data["generated_media"][platform] = {
            "type": media_type,  # image, video
            "file_path": file_path,
            "dimensions": {"width": width, "height": height},
            "duration_seconds": duration,
            "template": template,
            "generated_at": datetime.now().isoformat()
        }
        self._save()
        print(f"🎬 已记录 {platform} 媒体生成: {media_type} ({width}x{height})")

    def record_media_upload(self, platform: str, status: str = "uploaded",
                            error: str = None):
        """记录媒体上传状态"""
        valid_platforms = list(self.data["media_upload_status"].keys())
        if platform not in self.data["media_upload_status"]:
            raise ValueError(f"不支持的平台: {platform}. 支持的平台: {valid_platforms}")

        self.data["media_upload_status"][platform]["status"] = status
        if status == "uploaded":
            self.data["media_upload_status"][platform]["uploaded_at"] = datetime.now().isoformat()
        if error:
            self.data["media_upload_status"][platform]["errors"].append(error)
        self._save()
        print(f"📤 已记录 {platform} 媒体上传状态: {status}")

    def get_media_for_platform(self, platform: str) -> Optional[Dict]:
        """获取平台的媒体信息"""
        media = self.data["generated_media"].get(platform, {})
        if media.get("type") and media.get("file_path"):
            return media
        return None

    # ========== Phase 5: 发布状态 ==========

    def record_twitter_publish(self, published_count: int, urls: List[str] = None,
                                status: str = "published", error: str = None):
        """记录 Twitter 发布状态"""
        self.data["publish_status"]["twitter"]["published_count"] = published_count
        self.data["publish_status"]["twitter"]["status"] = status
        if urls:
            self.data["publish_status"]["twitter"]["urls"] = urls
        if error:
            self.data["publish_status"]["twitter"]["errors"].append(error)
        self._save()

    def record_xiaohongshu_publish(self, url: str = "", status: str = "published",
                                    error: str = None):
        """记录小红书发布状态"""
        self.data["publish_status"]["xiaohongshu"]["status"] = status
        self.data["publish_status"]["xiaohongshu"]["url"] = url
        if error:
            self.data["publish_status"]["xiaohongshu"]["errors"].append(error)
        self._save()

    def record_wechat_publish(self, url: str = "", status: str = "published",
                               error: str = None):
        """记录微信发布状态"""
        self.data["publish_status"]["wechat"]["status"] = status
        self.data["publish_status"]["wechat"]["url"] = url
        if error:
            self.data["publish_status"]["wechat"]["errors"].append(error)
        self._save()

    # ========== Phase 6: 核查 ==========

    def verify(self) -> Dict:
        """执行核查并返回结果"""
        issues = []

        # 检查 Twitter
        twitter_status = self.data["publish_status"]["twitter"]
        twitter_content = self.data["generated_content"]["twitter"]

        if twitter_status["expected_count"] > 0:
            if twitter_status["published_count"] < twitter_status["expected_count"]:
                issues.append({
                    "platform": "twitter",
                    "type": "incomplete",
                    "expected": twitter_status["expected_count"],
                    "actual": twitter_status["published_count"],
                    "message": f"Twitter Thread 未发完: 预期 {twitter_status['expected_count']} 条, 实际 {twitter_status['published_count']} 条"
                })
            elif twitter_status["status"] != "published":
                issues.append({
                    "platform": "twitter",
                    "type": "status",
                    "message": f"Twitter 状态异常: {twitter_status['status']}"
                })

        # 检查小红书
        xhs_status = self.data["publish_status"]["xiaohongshu"]
        if self.data["generated_content"]["xiaohongshu"]["title"]:
            if xhs_status["status"] != "published":
                issues.append({
                    "platform": "xiaohongshu",
                    "type": "status",
                    "message": f"小红书状态: {xhs_status['status']}"
                })

        # 检查微信
        wechat_status = self.data["publish_status"]["wechat"]
        if self.data["generated_content"]["wechat"]["title"]:
            if wechat_status["status"] not in ["published", "draft"]:
                issues.append({
                    "platform": "wechat",
                    "type": "status",
                    "message": f"微信公众号状态: {wechat_status['status']}"
                })

        # 检查媒体上传状态
        for platform in ["twitter", "xiaohongshu", "wechat"]:
            media = self.data["generated_media"].get(platform, {})
            upload_status = self.data["media_upload_status"].get(platform, {})

            # 如果生成了媒体但未上传
            if media.get("type") and media.get("file_path"):
                if upload_status.get("status") not in ["uploaded", "skipped"]:
                    issues.append({
                        "platform": platform,
                        "type": "media_not_uploaded",
                        "message": f"{platform} 媒体已生成但未上传: {media['type']}"
                    })

        # 更新核查结果
        self.data["verification"] = {
            "verified_at": datetime.now().isoformat(),
            "twitter_verified": len([i for i in issues if i["platform"] == "twitter"]) == 0,
            "xiaohongshu_verified": len([i for i in issues if i["platform"] == "xiaohongshu"]) == 0,
            "wechat_verified": len([i for i in issues if i["platform"] == "wechat"]) == 0,
            "issues": issues,
            "notes": ""
        }
        self.data["status"] = "verified"
        self._save()

        return self.data["verification"]

    def get_report(self) -> str:
        """生成核查报告"""
        report = []
        report.append("=" * 60)
        report.append(f"📋 内容追踪报告")
        report.append(f"   会话ID: {self.session_id}")
        report.append(f"   主题: {self.topic}")
        report.append(f"   时间: {self.data['created_at']}")
        report.append("=" * 60)

        # 搜索阶段
        search = self.data["search"]
        report.append(f"\n🔍 搜索阶段:")
        report.append(f"   查询: {search['query']}")
        report.append(f"   时间范围: {search['time_range']}")
        report.append(f"   找到帖子: {search['total_found']} 条")

        # 互动阶段
        engagement = self.data["engagement"]
        report.append(f"\n💬 互动阶段:")
        report.append(f"   选定互动: {len(engagement['selected_posts'])} 条")
        report.append(f"   已点赞: {len(engagement['liked'])} 条")
        report.append(f"   已回复: {len(engagement['replied'])} 条")

        # 生成内容
        generated = self.data["generated_content"]
        report.append(f"\n📝 生成内容:")
        report.append(f"   Twitter Thread: {generated['twitter']['total_tweets']} 条推文")
        report.append(f"   小红书: {generated['xiaohongshu']['title'] or '(无)'}")
        report.append(f"   微信公众号: {generated['wechat']['title'] or '(无)'}")

        # 媒体内容
        media = self.data.get("generated_media", {})
        has_media = any(m.get("type") for m in media.values() if isinstance(m, dict))
        if has_media:
            report.append(f"\n🎬 生成媒体:")
            for platform, m in media.items():
                if isinstance(m, dict) and m.get("type"):
                    dims = m.get("dimensions", {})
                    size_str = f"{dims.get('width', 0)}x{dims.get('height', 0)}"
                    duration_str = f", {m.get('duration_seconds', 0)}s" if m.get("duration_seconds") else ""
                    report.append(f"   {platform}: {m['type']} ({size_str}{duration_str})")

            # 媒体上传状态
            upload = self.data.get("media_upload_status", {})
            report.append(f"\n📤 媒体上传:")
            for platform, u in upload.items():
                if isinstance(u, dict) and media.get(platform, {}).get("type"):
                    status_emoji = "✅" if u.get("status") == "uploaded" else "⏳"
                    report.append(f"   {status_emoji} {platform}: {u.get('status', 'pending')}")

        # 发布状态
        publish = self.data["publish_status"]
        report.append(f"\n📤 发布状态:")

        # Twitter
        tw = publish["twitter"]
        tw_emoji = "✅" if tw["status"] == "published" and tw["published_count"] == tw["expected_count"] else "⚠️"
        report.append(f"   {tw_emoji} Twitter: {tw['status']} ({tw['published_count']}/{tw['expected_count']} 条)")

        # 小红书
        xhs = publish["xiaohongshu"]
        xhs_emoji = "✅" if xhs["status"] == "published" else "⚠️"
        report.append(f"   {xhs_emoji} 小红书: {xhs['status']}")

        # 微信
        wc = publish["wechat"]
        wc_emoji = "✅" if wc["status"] in ["published", "draft"] else "⚠️"
        report.append(f"   {wc_emoji} 微信公众号: {wc['status']}")

        # 核查结果
        if self.data["verification"]["verified_at"]:
            verification = self.data["verification"]
            report.append(f"\n🔎 核查结果:")

            if verification["issues"]:
                for issue in verification["issues"]:
                    report.append(f"   ⚠️ {issue['message']}")
            else:
                report.append("   ✅ 所有内容发布完整")

        report.append("\n" + "=" * 60)

        return "\n".join(report)

    def get_unpublished_twitter_content(self) -> List[str]:
        """获取未发布的 Twitter 内容"""
        twitter = self.data["generated_content"]["twitter"]
        publish = self.data["publish_status"]["twitter"]

        published_count = publish["published_count"]
        all_tweets = twitter["thread"]

        if published_count < len(all_tweets):
            return all_tweets[published_count:]
        return []


# ========== CLI ==========

def main():
    import argparse

    parser = argparse.ArgumentParser(description="内容追踪和核查系统")
    subparsers = parser.add_subparsers(dest="command")

    # init 命令 - 初始化新会话
    init_parser = subparsers.add_parser("init", help="初始化新会话")
    init_parser.add_argument("--topic", "-t", required=True, help="主题关键词")

    # search 命令 - 记录搜索结果
    search_parser = subparsers.add_parser("search", help="记录搜索结果")
    search_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    search_parser.add_argument("--query", "-q", required=True, help="搜索查询词")
    search_parser.add_argument("--time-range", "-r", default="24h", help="时间范围")
    search_parser.add_argument("--posts", "-p", help="帖子JSON数组（或从stdin读取）")

    # engage 命令 - 记录互动
    engage_parser = subparsers.add_parser("engage", help="记录互动")
    engage_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    engage_parser.add_argument("--action", "-a", choices=["select", "like", "reply"], required=True)
    engage_parser.add_argument("--post-id", "-p", help="帖子ID")
    engage_parser.add_argument("--post-ids", help="多个帖子ID，逗号分隔")
    engage_parser.add_argument("--reply-text", help="回复内容")

    # distill 命令 - 记录提炼内容
    distill_parser = subparsers.add_parser("distill", help="记录提炼内容")
    distill_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    distill_parser.add_argument("--trends", help="趋势JSON数组")
    distill_parser.add_argument("--points", help="要点JSON数组")
    distill_parser.add_argument("--quotes", help="引用JSON数组")
    distill_parser.add_argument("--summary", help="总结")

    # generate 命令 - 记录生成的内容
    generate_parser = subparsers.add_parser("generate", help="记录生成的内容")
    generate_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    generate_parser.add_argument("--platform", "-p", choices=["twitter", "xiaohongshu", "wechat"], required=True)
    generate_parser.add_argument("--title", "-t", help="标题")
    generate_parser.add_argument("--content", "-c", help="内容")
    generate_parser.add_argument("--thread", help="Twitter Thread JSON数组")
    generate_parser.add_argument("--hashtags", help="话题标签，逗号分隔")

    # publish 命令 - 记录发布状态
    publish_parser = subparsers.add_parser("publish", help="记录发布状态")
    publish_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    publish_parser.add_argument("--platform", "-p", choices=["twitter", "xiaohongshu", "wechat"], required=True)
    publish_parser.add_argument("--status", choices=["pending", "published", "partial", "failed", "draft"], default="published")
    publish_parser.add_argument("--url", "-u", help="发布URL")
    publish_parser.add_argument("--count", "-n", type=int, help="已发布数量（Twitter用）")
    publish_parser.add_argument("--error", "-e", help="错误信息")

    # media-gen 命令 - 记录媒体生成
    media_gen_parser = subparsers.add_parser("media-gen", help="记录媒体生成结果")
    media_gen_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    media_gen_parser.add_argument("--platform", "-p", choices=["twitter", "xiaohongshu", "wechat"], required=True)
    media_gen_parser.add_argument("--type", "-t", choices=["image", "video"], required=True, help="媒体类型")
    media_gen_parser.add_argument("--file", "-f", required=True, help="媒体文件路径")
    media_gen_parser.add_argument("--width", "-W", type=int, required=True, help="宽度")
    media_gen_parser.add_argument("--height", "-H", type=int, required=True, help="高度")
    media_gen_parser.add_argument("--duration", "-d", type=int, default=0, help="时长（秒，仅视频）")
    media_gen_parser.add_argument("--template", help="Remotion 模板名")

    # media-upload 命令 - 记录媒体上传状态
    media_upload_parser = subparsers.add_parser("media-upload", help="记录媒体上传状态")
    media_upload_parser.add_argument("--session", "-s", help="会话ID，默认最新")
    media_upload_parser.add_argument("--platform", "-p", choices=["twitter", "xiaohongshu", "wechat"], required=True)
    media_upload_parser.add_argument("--status", choices=["pending", "uploaded", "failed", "skipped"], default="uploaded")
    media_upload_parser.add_argument("--error", "-e", help="错误信息")

    # list 命令
    list_parser = subparsers.add_parser("list", help="列出所有会话")

    # report 命令
    report_parser = subparsers.add_parser("report", help="查看核查报告")
    report_parser.add_argument("--session", "-s", help="指定会话ID，默认最新")

    # verify 命令
    verify_parser = subparsers.add_parser("verify", help="执行核查")
    verify_parser.add_argument("--session", "-s", help="指定会话ID，默认最新")

    # session-id 命令 - 获取当前会话ID
    session_parser = subparsers.add_parser("session-id", help="获取最新会话ID")

    args = parser.parse_args()

    # ========== init ==========
    if args.command == "init":
        tracker = ContentTracker(args.topic)
        print(f"✅ 新会话已创建: {tracker.session_id}")
        print(tracker.session_id)  # 输出ID供脚本捕获

    # ========== search ==========
    elif args.command == "search":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话，请先运行 init")
            return

        posts = []
        try:
            if args.posts:
                posts = json.loads(args.posts)
                if not isinstance(posts, list):
                    raise ValueError("posts must be a JSON array")
            else:
                # 从 stdin 读取
                import sys
                if not sys.stdin.isatty():
                    posts = json.load(sys.stdin)
                    if not isinstance(posts, list):
                        raise ValueError("stdin input must be a JSON array")
        except json.JSONDecodeError as e:
            print(f"❌ Invalid JSON: {e}")
            return
        except ValueError as e:
            print(f"❌ Validation error: {e}")
            return

        tracker.record_search(args.query, args.time_range, posts)

    # ========== engage ==========
    elif args.command == "engage":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话")
            return

        if args.action == "select":
            post_ids = args.post_ids.split(",") if args.post_ids else [args.post_id]
            tracker.record_selected_for_engagement(post_ids)
        elif args.action == "like":
            tracker.record_like(args.post_id)
            print(f"✅ 已记录点赞: {args.post_id}")
        elif args.action == "reply":
            tracker.record_reply(args.post_id, args.reply_text or "")
            print(f"✅ 已记录回复: {args.post_id}")

    # ========== distill ==========
    elif args.command == "distill":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话")
            return

        trends = json.loads(args.trends) if args.trends else []
        points = json.loads(args.points) if args.points else []
        quotes = json.loads(args.quotes) if args.quotes else []
        summary = args.summary or ""

        tracker.record_distilled_content(trends, points, quotes, summary)

    # ========== generate ==========
    elif args.command == "generate":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话")
            return

        if args.platform == "twitter":
            thread = json.loads(args.thread) if args.thread else []
            tracker.record_twitter_content(thread)
        elif args.platform == "xiaohongshu":
            hashtags = args.hashtags.split(",") if args.hashtags else []
            tracker.record_xiaohongshu_content(args.title or "", args.content or "", hashtags)
        elif args.platform == "wechat":
            tracker.record_wechat_content(args.title or "", args.content or "", "")

    # ========== publish ==========
    elif args.command == "publish":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话")
            return

        if args.platform == "twitter":
            tracker.record_twitter_publish(
                published_count=args.count or 0,
                urls=[args.url] if args.url else [],
                status=args.status,
                error=args.error
            )
        elif args.platform == "xiaohongshu":
            tracker.record_xiaohongshu_publish(
                url=args.url or "",
                status=args.status,
                error=args.error
            )
        elif args.platform == "wechat":
            tracker.record_wechat_publish(
                url=args.url or "",
                status=args.status,
                error=args.error
            )
        print(f"✅ 已记录 {args.platform} 发布状态: {args.status}")

    # ========== media-gen ==========
    elif args.command == "media-gen":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话")
            return

        try:
            tracker.record_media_generation(
                platform=args.platform,
                media_type=args.type,
                file_path=args.file,
                width=args.width,
                height=args.height,
                duration=args.duration,
                template=args.template or ""
            )
        except ValueError as e:
            print(f"❌ {e}")
            return

    # ========== media-upload ==========
    elif args.command == "media-upload":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if not tracker:
            print("❌ 未找到会话")
            return

        try:
            tracker.record_media_upload(
                platform=args.platform,
                status=args.status,
                error=args.error
            )
        except ValueError as e:
            print(f"❌ {e}")
            return

    # ========== list ==========
    elif args.command == "list":
        ensure_dirs()
        sessions = list(SESSIONS_DIR.glob("session_*.json"))
        if not sessions:
            print("暂无会话记录")
            return

        print("📁 会话列表:")
        for session_file in sorted(sessions, reverse=True)[:10]:
            with open(session_file, "r", encoding="utf-8") as f:
                data = json.load(f)
            print(f"   {data['session_id']} - {data['topic']} ({data['status']})")

    # ========== report ==========
    elif args.command == "report":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if tracker:
            print(tracker.get_report())
        else:
            print("未找到会话记录")

    # ========== verify ==========
    elif args.command == "verify":
        tracker = ContentTracker.load(args.session) if args.session else ContentTracker.get_latest_session()
        if tracker:
            result = tracker.verify()
            print(tracker.get_report())

            if result["issues"]:
                print("\n💡 建议操作:")
                for issue in result["issues"]:
                    if issue["type"] == "incomplete" and issue["platform"] == "twitter":
                        unpublished = tracker.get_unpublished_twitter_content()
                        if unpublished:
                            print(f"   需要补发 {len(unpublished)} 条推文:")
                            for i, tweet in enumerate(unpublished, 1):
                                print(f"   {i}. {tweet[:50]}...")
        else:
            print("未找到会话记录")

    # ========== session-id ==========
    elif args.command == "session-id":
        tracker = ContentTracker.get_latest_session()
        if tracker:
            print(tracker.session_id)
        else:
            print("")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
