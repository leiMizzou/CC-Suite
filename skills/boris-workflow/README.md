# Boris Workflow

**Claude Code 开发环境增强工具集**

灵感来源于 [Boris Cherny](https://github.com/bcherny) 的 Claude Code 最佳实践。

## 包含的 Skills

| Skill | 图标 | 描述 | 使用频率 |
|-------|------|------|----------|
| [claude-code-setup](./claude-code-setup/) | ⚙️ | 初始化开发环境 | 一次性 |
| [create-subagent](./create-subagent/) | ⚡ | 创建自定义 Agent | 持续使用 |

## claude-code-setup ⚙️

一键初始化 Boris 风格的 Claude Code 开发环境。

**触发方式**：
```
初始化 Claude Code 环境
setup claude code
```

**创建内容**：
```
.claude/
├── commands/
│   └── commit-push-pr.md
├── agents/
│   ├── code-simplifier.md
│   └── verify-app.md
└── settings/
    └── settings.json
CLAUDE.md
```

**自定义选项**：
- `--minimal`：只创建 CLAUDE.md
- `--typescript`：TypeScript 项目模板
- `--python`：Python 项目模板

## create-subagent ⚡

交互式创建自定义 Claude Code Subagent。

**触发方式**：
```
创建 subagent
create subagent
```

**Agent 模板类型**：
| 类型 | 示例 |
|------|------|
| 🔍 代码质量 | code-reviewer, code-simplifier |
| 🧪 测试 | test-generator, verify-app |
| 📝 文档 | doc-generator |
| 🔧 运维 | oncall-guide |
| 🏗️ 架构 | code-architect |
| 📦 自定义 | 根据需求生成 |

## 安装

通过 CC Suite 安装：
```bash
# 安装整个 boris-workflow 系列
./install.sh boris-workflow

# 或安装单个 skill
./install.sh claude-code-setup
./install.sh create-subagent
```

## 相关链接

- [Boris Cherny's Blog](https://borischerny.com/)
- [Claude Code Best Practices](https://www.anthropic.com/claude-code)
