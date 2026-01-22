# CC Suite

**Claude Code 工作流标准库**

[English](README.md) | 中文

[![Claude Code](https://img.shields.io/badge/Claude_Code-Skills-blueviolet)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

精选的 Claude Code 技能集合，通过**信任**、**传播**和**效率**增强您的 AI 工作流。

## 技能列表

| 技能 | 图标 | 描述 | MCP 依赖 |
|------|------|------|----------|
| [CrossCheck](skills/crosscheck/) | 🛡️ | 多模型交叉验证 (Claude + Codex + Gemini) | Codex, Gemini |
| [SocialPublisher](skills/social-publisher/) | 📢 | 社交媒体自动发布 | Playwright |
| [BorisWorkflow](skills/boris-workflow/) | ⚙️⚡ | Claude Code 环境工具集 | Codex |

### BorisWorkflow 子技能

| 技能 | 图标 | 描述 | 使用频率 |
|------|------|------|----------|
| [claude-code-setup](skills/boris-workflow/claude-code-setup/) | ⚙️ | 初始化开发环境 | 一次性 |
| [create-subagent](skills/boris-workflow/create-subagent/) | ⚡ | 创建自定义 Agent | 持续使用 |

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

## 技能组合

组合使用技能实现强大工作流：

```
# 工作流：验证 → 发布
1. /crosscheck "最新AI趋势分析"
2. /social-media-publisher <已验证内容> all
```

## 项目结构

```
CC-Suite/
├── skills/
│   ├── crosscheck/              # 🛡️ 多模型验证
│   ├── social-publisher/        # 📢 社媒自动发布
│   └── boris-workflow/          # ⚙️⚡ Boris 工作流工具集
│       ├── README.md
│       ├── claude-code-setup/   # ⚙️ 环境配置
│       └── create-subagent/     # ⚡ 子代理创建
├── assets/                      # 共享资源
├── docs/                        # 文档
└── install.sh                   # 统一安装脚本
```

## 验证安装

```bash
claude mcp list
# codex: codex mcp-server - ✓ Connected
# gemini: npx -y gemini-mcp-tool - ✓ Connected
```

检查已安装的技能：
```bash
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
