# Boris Workflow

**Claude Code 开发环境增强工具集 - 完整版**

灵感来源于 [Boris Cherny](https://github.com/bcherny) 的 Claude Code 最佳实践。

## 目录结构

```
boris-workflow/
├── claude-code-setup/     # Skill: 环境初始化
├── create-subagent/       # Skill: Agent 创建器
├── commands/              # 7 个斜杠命令
│   ├── init.md
│   ├── add-rule.md
│   ├── commit-push-pr.md
│   ├── setup-permissions.md
│   ├── setup-plugins.md
│   ├── setup-format-hook.md
│   └── setup-ralph-loop.md
└── templates/             # 预设模板
    ├── CLAUDE.md
    ├── settings.json
    ├── agents/            # 4 个 Agent 模板
    ├── permissions/       # 3 个权限预设
    └── plugins/           # 5 个插件预设
```

## Skills (2个)

| Skill | 描述 | 触发方式 |
|-------|------|----------|
| **claude-code-setup** | 初始化开发环境 | `setup claude code` |
| **create-subagent** | 创建自定义 Agent | `创建 subagent` |

## Commands (7个)

| 命令 | 描述 |
|------|------|
| `/init` | 初始化 Claude Code 环境入口 |
| `/add-rule` | 添加规则到 CLAUDE.md |
| `/commit-push-pr` | 一键 commit、push、创建 PR |
| `/setup-permissions` | 配置权限预设 |
| `/setup-plugins` | 配置 MCP 插件 |
| `/setup-format-hook` | 配置格式化钩子 |
| `/setup-ralph-loop` | 配置 Ralph Loop 自主循环 |

## Templates

### Agent 模板 (`templates/agents/`)

| 模板 | 用途 |
|------|------|
| `code-reviewer.md` | 代码审查 |
| `code-simplifier.md` | 代码简化 |
| `test-generator.md` | 测试生成 |
| `verify-app.md` | 应用验证 |

### 权限预设 (`templates/permissions/`)

| 预设 | 说明 |
|------|------|
| `minimal.json` | 最小权限，最安全 |
| `recommended.json` | 推荐配置，平衡安全与效率 |
| `full.json` | 完整权限，最大自由度 |

### 插件预设 (`templates/plugins/`)

| 预设 | 包含的 MCP 服务器 |
|------|------------------|
| `minimal.json` | 基础配置 |
| `recommended.json` | 推荐的常用插件 |
| `web-dev.json` | Web 开发套件 |
| `data-science.json` | 数据科学套件 |
| `enterprise.json` | 企业级套件 |

## 核心功能：Ralph Loop

Ralph Loop 是 Boris 工作流的核心功能之一，让 Claude 能够自主迭代直到任务完成。

```bash
/setup-ralph-loop --enable

/ralph-loop "实现功能 X，完成后输出 <promise>DONE</promise>" \
  --max-iterations 30 \
  --completion-promise "DONE"
```

适用场景：
- TDD 工作流（写测试 -> 实现 -> 修复 -> 重复）
- 过夜开发任务
- 有明确验收标准的任务

## 安装

```bash
# 安装完整的 boris-workflow（推荐）
./install.sh boris-workflow

# 这会安装：
# - Skills 到 ~/.claude/skills/
# - Commands 到 ~/.claude/commands/
# - Templates 到 ~/.claude/templates/
```

## 安装后的文件位置

```
~/.claude/
├── skills/
│   ├── claude-code-setup/
│   └── create-subagent/
├── commands/
│   ├── init.md
│   ├── add-rule.md
│   ├── commit-push-pr.md
│   ├── setup-permissions.md
│   ├── setup-plugins.md
│   ├── setup-format-hook.md
│   └── setup-ralph-loop.md
└── templates/
    ├── CLAUDE.md
    ├── settings.json
    ├── agents/
    ├── permissions/
    └── plugins/
```

## 相关链接

- [Boris Cherny's Blog](https://borischerny.com/)
- [Geoffrey Huntley's Ralph](https://ghuntley.com/ralph/)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
