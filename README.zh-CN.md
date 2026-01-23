# CC Suite

**Claude Code 工作流标准库**

[English](README.md) | 中文

[![Claude Code](https://img.shields.io/badge/Claude_Code-Skills-blueviolet)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

精选的 Claude Code 技能集合，通过**信任**、**传播**和**效率**增强您的 AI 工作流。

## 技能概览

```
CC Suite
├── 🛡️ crosscheck          ─── 多模型交叉验证 (Claude + Codex + Gemini)
├── 📢 social-publisher     ─── 社交媒体自动发布
└── ⚙️⚡ boris-workflow      ─── Claude Code 环境工具集
        ├── ⚙️ claude-code-setup  ─── 初始化开发环境 (一次性)
        └── ⚡ create-subagent     ─── 创建自定义 Agent (持续使用)
```

| 技能 | 描述 | MCP 依赖 | 安装命令 |
|------|------|----------|----------|
| crosscheck | 3轮交叉验证，Claude + Codex + Gemini | Codex, Gemini | `./install.sh crosscheck` |
| social-publisher | 发布到 Twitter、微信、小红书 | Playwright | `./install.sh social-publisher` |
| boris-workflow | 开发环境工具 (包含2个子技能) | Codex | `./install.sh boris-workflow` |

> **说明**: `boris-workflow` 是一个技能组，包含两个相关技能。使用 `./install.sh boris-workflow` 同时安装两者，或单独安装 `./install.sh claude-code-setup` 或 `./install.sh create-subagent`。

## 一键安装

```bash
git clone https://github.com/leiMizzou/CC-Suite.git && cd CC-Suite && ./install.sh
```

然后登录并重启：
```bash
codex        # 登录 OpenAI（仅首次需要）
gemini       # 登录 Google（仅首次需要）
/exit        # 重启 Claude Code 以加载技能
```

## 模块化安装

只安装你需要的技能：

```bash
# 安装指定技能
./install.sh crosscheck social-publisher

# 安装技能组
./install.sh boris-workflow    # 安装 claude-code-setup + create-subagent

# 安装单个技能
./install.sh crosscheck

# 强制重新安装
./install.sh --force
```

## 使用示例

### 🛡️ CrossCheck - 多模型验证

通过 3 轮交叉验证减少 AI 幻觉：

```
/crosscheck 这个项目适合用微服务架构吗？
/crosscheck 实现实时协作的最佳方案是什么？
```

### 📢 SocialPublisher - 社媒自动发布

一键发布到多个平台：

```
/social-media-publisher "今日AI热点" xiaohongshu wechat
```

### ⚡ CreateSubagent - 自定义代理构建器

为复杂任务创建专用代理：

```
/create-subagent code-reviewer
```

## 技能协同

CC-Suite 三部分形成强大的闭环系统：

```
┌─────────────────────────────────────────────────────────┐
│                    SocialPublisher                       │
│                (输出层 - 内容分发 & 趋势追踪)              │
└─────────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────────┐
│                      CrossCheck                          │
│                (验证层 - 质量保障 & 决策验证)              │
└─────────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────────┐
│                    BorisWorkflow                         │
│              (基础层 - 环境 & 模板 & 自主开发)             │
└─────────────────────────────────────────────────────────┘
```

### 工作流 1：新项目启动
```bash
/init                                    # 初始化 Claude Code 环境
/setup-permissions --preset recommended  # 配置权限
/setup-plugins --preset web-dev          # 配置 MCP 插件
/create-subagent                         # 创建项目专用 Agent
```

### 工作流 2：自主开发 + 验证
```bash
/setup-ralph-loop --enable               # 启用 Ralph Loop

/ralph-loop "用 TDD 方式实现用户认证，完成后输出 <promise>DONE</promise>" \
  --max-iterations 30                    # 自主迭代开发

/crosscheck "JWT vs Session，哪个更适合这个场景？"  # 验证技术决策
```

### 工作流 3：趋势追踪 → 开发灵感
```bash
# 1. 搜索热门技术讨论
/social-media-publisher "搜索 10 个今天最热的 AI Agent 帖子，只看不互动"

# 2. 验证某个热门观点
/crosscheck "ReAct 模式真的是 AI Agent 的最佳选择吗？"

# 3. 基于验证结果开发
/ralph-loop "实现一个基于 ReAct 模式的 AI Agent" --max-iterations 20
```

### 工作流 4：验证 → 发布
```bash
# 验证技术观点
/crosscheck "React Server Components 是否真的比传统 SSR 更好？"

# 发布已验证的内容
/social-media-publisher "整理今天的技术发现，发布到 Twitter 和小红书"
```

### 协同矩阵

| 组合 | 应用场景 |
|------|---------|
| Boris + CrossCheck | 架构审查、技术选型、代码审查 |
| Boris + Social | 发布项目动态、记录学习笔记 |
| CrossCheck + Social | 发布前验证内容准确性 |
| **三者联动** | 趋势发现 → 验证 → 开发 → 再验证 → 发布 |

### 工作流 5：终极闭环

> **[完整指南：docs/ULTIMATE_WORKFLOW.md](docs/ULTIMATE_WORKFLOW.md)**

```bash
# 阶段 1：发现 - 搜索热门讨论
/social-media-publisher "搜索 15 个今天最热的 {主题} 帖子，只看不互动"

# 阶段 2：验证 - 确认技术方向
/crosscheck "{从发现阶段识别的技术问题}"

# 阶段 3：开发 - TDD 自主迭代
/ralph-loop "{基于验证结论的开发任务}" \
  --completion-promise "DONE" --max-iterations 40

# 阶段 4：再验证 - 代码质量检查
/crosscheck "审查这个实现，有什么问题和改进建议？"

# 阶段 5：发布 - 多平台分发
/social-media-publisher "发布开发实践心得到所有平台"
```

```
   发现            验证            开发           再验证           发布
   ─────────────────────────────────────────────────────────────────────
   SocialPublisher → CrossCheck  →  Ralph Loop  → CrossCheck  → SocialPublisher
   (搜索趋势)        (验证方向)      (TDD 构建)     (代码审查)     (内容分发)
```

## 项目结构

```
CC-Suite/
├── skills/
│   ├── crosscheck/              # 🛡️ 多模型验证
│   │   └── SKILL.md
│   ├── social-publisher/        # 📢 社媒自动发布
│   │   ├── SKILL.md
│   │   ├── scripts/             # check_login.py, content_tracker.py
│   │   └── codex/               # AGENTS.md, login.py
│   └── boris-workflow/          # ⚙️⚡ Boris 工作流工具集
│       ├── claude-code-setup/   # ⚙️ 环境配置
│       ├── create-subagent/     # ⚡ 子代理创建
│       ├── commands/            # 7 个斜杠命令 (init, setup-ralph-loop 等)
│       └── templates/           # 14 个模板 (agents, permissions, plugins)
├── scripts/
│   └── verify.sh                # 安装验证脚本
├── assets/                      # 共享资源
└── install.sh                   # 统一安装脚本
```

## 验证安装

运行完整验证脚本：
```bash
./scripts/verify.sh
```

检查内容包括：
- 已安装技能状态
- MCP 服务器连接
- 工具名称与 SKILL.md 匹配
- 功能覆盖完整性

手动检查：
```bash
claude mcp list
# codex: codex mcp-server - ✓ Connected
# gemini: npx -y gemini-mcp-tool - ✓ Connected

ls ~/.claude/skills/
# crosscheck  social-publisher  claude-code-setup  create-subagent
```

## 常见问题

| 问题 | 解决方案 |
|------|----------|
| MCP "Failed to connect" | 先运行 `codex` 或 `gemini` 登录 |
| 技能不可用 | 重启 Claude Code：`/exit` 然后 `claude` |
| 权限被拒绝 | 运行 `chmod +x install.sh` |

## 交流群

有问题或建议？欢迎加入微信交流群：

<table>
  <tr>
    <td align="center">
      <img src="./assets/wechat-group.jpg" width="200" alt="微信交流群"/>
      <br/>
      <b>扫码加入交流群</b>
    </td>
    <td align="center">
      <img src="./assets/wechat-helper.jpg" width="200" alt="小助手微信"/>
      <br/>
      <b>群码失效请加小助手</b>
    </td>
  </tr>
</table>

## 相关项目

- [CrossCheck](https://github.com/leiMizzou/CrossCheck) - 独立的多模型验证项目
- [SocialPublisher](https://github.com/leiMizzou/SocialPublisher) - 独立的社媒自动化项目
- [BorisWorkflow](https://github.com/leiMizzou/BorisWorkflow) - 工作流自动化工具包

## 许可证

MIT
