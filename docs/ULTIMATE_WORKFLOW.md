# Ultimate Workflow: Trend → Verify → Develop → Re-verify → Publish

**CC-Suite 终极工作流：从趋势发现到内容发布的完整闭环**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   🔍 DISCOVER        🛡️ VERIFY         ⚡ DEVELOP        🛡️ RE-VERIFY       📢 PUBLISH    │
│   ───────────────────────────────────────────────────────────────────────    │
│                                                                              │
│   SocialPublisher    CrossCheck       BorisWorkflow     CrossCheck      SocialPublisher   │
│   (搜索趋势)         (验证方向)        (自主开发)         (验证质量)       (多平台发布)    │
│                                                                              │
│        │                │                  │                │                │          │
│        ▼                ▼                  ▼                ▼                ▼          │
│   ┌─────────┐      ┌─────────┐        ┌─────────┐      ┌─────────┐      ┌─────────┐     │
│   │ 热点帖子 │  →   │ 3模型   │   →    │ Ralph   │  →   │ 代码    │  →   │ Twitter │     │
│   │ 趋势分析 │      │ 交叉验证 │        │ Loop    │      │ 架构验证 │      │ 小红书   │     │
│   │ 核心洞察 │      │ 共识结论 │        │ TDD迭代 │      │ 最佳实践 │      │ 公众号   │     │
│   └─────────┘      └─────────┘        └─────────┘      └─────────┘      └─────────┘     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: 环境准备 (一次性)

```bash
# 1. 初始化 Claude Code 环境
/init

# 2. 配置权限
/setup-permissions --preset recommended

# 3. 配置 MCP 插件
/setup-plugins --preset full    # 包含 Codex + Gemini + Playwright

# 4. 启用 Ralph Loop
/setup-ralph-loop --enable

# 5. 验证安装
./scripts/verify.sh
```

**预期输出：**
```
✅ 环境准备完成
   - Codex MCP: Connected
   - Gemini MCP: Connected
   - Playwright MCP: Connected
   - Ralph Loop: Enabled
```

---

## Phase 1: DISCOVER - 趋势发现

> **工具**: SocialPublisher
> **目标**: 发现技术热点，获取社区最新动态

### 1.1 搜索热门讨论

```bash
/social-media-publisher "搜索 15 个今天最热的 {TOPIC} 帖子，只看不互动"
```

**不同领域示例：**
```bash
# 前端开发
/social-media-publisher "搜索 15 个今天最热的 React Server Components 帖子，只看不互动"

# 后端架构
/social-media-publisher "搜索 15 个今天最热的 微服务 vs 单体架构 帖子，只看不互动"

# AI/ML
/social-media-publisher "搜索 15 个今天最热的 RAG 优化 帖子，只看不互动"

# DevOps
/social-media-publisher "搜索 15 个今天最热的 Kubernetes 成本优化 帖子，只看不互动"

# 通用技术趋势
/social-media-publisher "搜索 15 个今天最热的 2024 技术栈选择 帖子，只看不互动"
```

### 1.2 分析输出

系统会返回：
```yaml
🔍 搜索主题: {TOPIC}
📅 时间范围: 最近 24 小时
📊 找到 15 条热门帖子:

1. @expert1 (❤️ 5.2k 🔄 1.2k 💬 340) ⭐ 9.2
   "关于 {TOPIC} 的核心观点..."

2. @expert2 (❤️ 4.8k 🔄 980 💬 280) ⭐ 8.9
   "实践经验分享..."

... (more posts)

📈 趋势摘要:
- 趋势1: {主流观点}
- 趋势2: {新兴方向}
- 趋势3: {争议焦点}
```

### 1.3 提炼核心洞察

从搜索结果中识别：
- **共识观点**: 多数人认同的趋势
- **争议话题**: 存在分歧的技术决策
- **实践经验**: 来自一线开发者的反馈

**记录发现模板（供后续验证）：**
```markdown
## 发现记录 - {TOPIC}

### 共识观点
1. {大多数人同意的观点1}
2. {大多数人同意的观点2}

### 争议话题
1. {方案A vs 方案B}：哪个更好？
2. {选择1 vs 选择2}：如何权衡？

### 值得深挖
1. @user1 提到的 "{具体方案}"
2. @user2 的 "{实践经验}"
```

---

## Phase 2: VERIFY - 验证方向

> **工具**: CrossCheck
> **目标**: 多模型交叉验证，确认技术方向可行性

### 2.1 验证争议话题

对发现阶段识别的**争议话题**进行验证：

```bash
/crosscheck "{方案A} 和 {方案B} 各有什么优缺点？在什么场景下应该选择哪种？"
```

**不同领域示例：**
```bash
# 前端
/crosscheck "React Server Components vs 传统 CSR：各有什么优缺点？什么场景该用哪个？"

# 后端
/crosscheck "GraphQL vs REST API：各有什么优缺点？新项目该如何选择？"

# 数据库
/crosscheck "PostgreSQL vs MongoDB：对于用户行为数据，哪个更合适？"

# 架构
/crosscheck "微服务 vs 模块化单体：中型团队该如何选择？"

# DevOps
/crosscheck "自建 Kubernetes vs 托管服务(EKS/GKE)：成本和复杂度如何权衡？"
```

### 2.2 验证技术方案

对打算开发的功能进行可行性验证：

```bash
/crosscheck "我打算用 {技术栈} 实现 {功能}。这个方案是否合适？有什么潜在问题？"
```

**示例：**
```bash
/crosscheck "我打算用 Next.js 14 + Prisma + PostgreSQL 实现一个多租户 SaaS。这个技术栈是否合适？"

/crosscheck "用 Rust + Axum 重写 Node.js 后端，性能提升值得迁移成本吗？"

/crosscheck "使用 tRPC 替代 REST，对于 10 人前后端团队是否合适？"
```

### 2.3 分析验证结果

CrossCheck 会返回：
```markdown
## Cross-Check Results: {方案A} vs {方案B}

**Mode**: Full Verification

### Round 1: Independent Answers

| Model | Status | Core View | Key Points |
|-------|--------|-----------|------------|
| Claude | OK | {观点1} | {要点} |
| Codex | OK | {观点2} | {要点} |
| Gemini | OK | {观点3} | {要点} |

### Round 3: Final Conclusion

#### Consensus (All Agree)
- {方案A} 适合：{场景列表}
- {方案B} 适合：{场景列表}
- 最佳实践：{综合建议}

#### Final Answer
建议采用 **{最终方案}**：
1. {具体建议1}
2. {具体建议2}
3. {具体建议3}
```

### 2.4 做出决策

基于验证结果，确定：
- **技术方案**: {选择的方案和原因}
- **开发优先级**: {先做什么，后做什么}
- **验收标准**: {明确的成功指标}

---

## Phase 3: DEVELOP - 自主开发

> **工具**: BorisWorkflow (Ralph Loop)
> **目标**: 基于验证结论，自主迭代开发

### 3.1 创建项目专属 Subagent（可选）

```bash
/create-subagent {project-name}-developer
```

配置模板：
```markdown
# {Project} Developer Subagent

## 目标
专门用于开发 {功能描述}

## 技术栈
- {语言/框架}
- {核心库}
- {测试框架}

## 验收标准
- 类型检查通过
- 测试覆盖 > 80%
- {项目特定标准}
```

### 3.2 启动 Ralph Loop 自主开发

**通用模板：**
```bash
/ralph-loop "
## 任务
{基于 CrossCheck 验证结论的具体任务描述}

## 背景（来自 Phase 2 验证）
{粘贴验证结论的关键点}

## 技术要求
1. {需求1}
2. {需求2}
3. {需求3}

## 验收标准
1. 类型检查通过
2. 测试全部通过
3. {其他标准}

## 工作流程（TDD）
1. 先编写测试
2. 实现功能使测试通过
3. 重构优化
4. 循环直到所有测试通过

## 完成信号
所有验收标准达成后输出：<promise>DONE</promise>
" --completion-promise "DONE" --max-iterations 40
```

**不同场景示例：**

```bash
# 示例1: API 开发
/ralph-loop "
实现用户认证 API，基于 CrossCheck 建议使用 JWT。

要求：
1. POST /auth/register
2. POST /auth/login
3. GET /auth/me (需要 JWT)
4. 输入验证
5. 错误处理

测试覆盖 > 80%，完成后输出 <promise>DONE</promise>
" --completion-promise "DONE" --max-iterations 30

# 示例2: 前端组件
/ralph-loop "
实现数据表格组件，基于 CrossCheck 建议使用虚拟滚动。

要求：
1. 支持 10000+ 行数据
2. 排序、筛选、分页
3. 响应式设计
4. 键盘导航

Storybook 示例完整，完成后输出 <promise>DONE</promise>
" --completion-promise "DONE" --max-iterations 35

# 示例3: 重构任务
/ralph-loop "
将 REST API 迁移到 GraphQL，基于 CrossCheck 建议渐进式迁移。

要求：
1. 保持 REST 端点兼容
2. 添加 GraphQL 层
3. 迁移 3 个核心查询
4. 性能不低于原实现

所有测试通过，完成后输出 <promise>DONE</promise>
" --completion-promise "DONE" --max-iterations 40
```

### 3.3 开发过程监控

Ralph Loop 会自动：
```
迭代 1: 分析需求，创建项目结构
迭代 2: 编写测试骨架
迭代 3: 实现核心功能
迭代 4: 运行测试，发现失败
迭代 5: 修复问题
...
迭代 N: 所有测试通过！
<promise>DONE</promise>
```

### 3.4 开发产物模板

```
src/
├── {feature}/
│   ├── {module1}.ts
│   ├── {module2}.ts
│   └── index.ts
├── types/
│   └── {feature}.types.ts
└── tests/
    ├── {module1}.test.ts
    └── {module2}.test.ts
```

---

## Phase 4: RE-VERIFY - 代码验证

> **工具**: CrossCheck
> **目标**: 验证开发产物的质量和最佳实践

### 4.1 架构验证

```bash
/crosscheck "
请审查以下架构设计：

{粘贴你的架构图或描述}

这个架构有什么问题？有没有更好的模式？
"
```

**示例：**
```bash
# API 架构审查
/crosscheck "
审查这个 API 分层架构：
Controller → Service → Repository → Database

问题：Service 层是否应该直接调用外部 API？还是应该抽象一层？
"

# 前端架构审查
/crosscheck "
审查这个状态管理方案：
Zustand store + React Query 缓存

问题：两者职责是否有重叠？如何划分边界？
"
```

### 4.2 代码质量验证

```bash
/crosscheck "
审查这段代码：

\`\`\`{language}
{粘贴核心代码}
\`\`\`

重点关注：
1. 类型安全性
2. 错误处理
3. 可扩展性
4. 性能问题
"
```

### 4.3 处理验证反馈

如果 CrossCheck 发现问题：

```bash
/ralph-loop "
修复 CrossCheck 识别的问题：

1. 问题: {问题描述1}
   修复: {修复方案1}

2. 问题: {问题描述2}
   修复: {修复方案2}

完成后运行测试确保无回归。
输出：<promise>FIX_DONE</promise>
" --completion-promise "FIX_DONE" --max-iterations 15
```

### 4.4 最终验证

```bash
# 运行完整验证套件（根据你的项目调整）
bun run typecheck && bun run test && bun run build
# 或
npm run lint && npm test && npm run build
# 或
pnpm check && pnpm test

# 使用 verify-app agent
/agent verify-app
```

---

## Phase 5: PUBLISH - 多平台发布

> **工具**: SocialPublisher
> **目标**: 将开发成果转化为内容，发布到多平台

### 5.1 准备发布内容

基于开发过程，整理：
- **技术洞察**: 从趋势发现到验证的过程
- **开发经验**: 实际开发中的决策和权衡
- **代码示例**: 核心代码片段
- **踩坑记录**: 遇到的问题和解决方案

### 5.2 生成多平台内容

**通用模板：**
```bash
/social-media-publisher "
基于今天的 {TOPIC} 开发实践，发布到 Twitter、小红书和微信公众号。

核心内容：
1. 趋势发现：{发现了什么}
2. 技术验证：{验证了什么结论}
3. 开发实践：{构建了什么}
4. 最终成果：{产出是什么}

重点分享：
- {关键决策1}
- {关键决策2}
- {踩坑经验}

平台：all
"
```

**不同场景示例：**
```bash
# 技术选型分享
/social-media-publisher "
分享今天的数据库选型实践。

核心内容：
1. 背景：需要存储时序数据
2. 验证：CrossCheck 对比 TimescaleDB vs InfluxDB vs ClickHouse
3. 结论：选择 TimescaleDB 的原因
4. 实践：迁移过程和性能对比

平台：all
"

# 架构重构分享
/social-media-publisher "
分享微服务拆分的实战经验。

核心内容：
1. 问题：单体应用的痛点
2. 验证：CrossCheck 分析拆分策略
3. 实践：第一个服务的拆分过程
4. 数据：性能提升和成本变化

平台：all
"

# 新技术尝鲜
/social-media-publisher "
分享 React Server Components 的实战体验。

核心内容：
1. 背景：社区热议 RSC
2. 验证：CrossCheck 分析适用场景
3. 实践：用 RSC 重构列表页
4. 对比：与传统方案的差异

平台：all
"
```

### 5.3 内容差异化模板

**Twitter Thread**:
```
🧵 {主题} 实战分享 (1/N)

Here's my journey: Trend Discovery → Verification → Development → Publish

Let me break it down 👇

2/ 🔍 DISCOVERY: {发现了什么}
3/ 🛡️ VERIFY: {验证了什么}
4-N/ ⚡ BUILD: {构建过程}
N/ 📦 {成果和链接}

What's your experience? Let me know below!
```

**小红书**:
```
家人们！今天搞了个 {主题}，来分享一下！

💡 起因：{为什么做这个}
🤔 验证：{怎么确认方向对}
⚡ 实现：{怎么做的}
✨ 成果：{做出了什么}

...

#{主题} #程序员日常 #技术干货 #效率工具
```

**微信公众号**:
```
# {主题}：从调研到落地的完整复盘

## 一、背景
{为什么关注这个问题}

## 二、技术验证
{CrossCheck 验证过程和结论}

## 三、开发过程
{核心实现和关键决策}

## 四、核心代码
{代码示例}

## 五、总结与展望
{经验教训和后续计划}
```

### 5.4 执行发布

```bash
# 检查登录状态
python3 scripts/check_login.py

# 初始化追踪
python3 scripts/content_tracker.py init --topic "AI Agent Development"

# 执行发布（SocialPublisher 会引导完成）
# 发布后核查
python3 scripts/content_tracker.py verify
```

### 5.5 发布报告

```
✅ 发布完成！

📊 本次运营统计:
- 🔍 趋势发现: 15 条热门帖子
- 🛡️ 验证轮次: 2 次 CrossCheck
- ⚡ 开发迭代: 28 次 Ralph Loop
- 📱 内容发布: Twitter Thread (12条) + 小红书 + 微信公众号

🔗 发布链接:
- Twitter: https://x.com/yourname/status/...
- 小红书: https://www.xiaohongshu.com/explore/...
- 微信公众号: https://mp.weixin.qq.com/s/...

📈 形成完整闭环:
   趋势发现 → 验证 → 开发 → 再验证 → 发布 ✓
```

---

## 完整命令速查

```bash
# ===== Phase 0: 环境准备（一次性） =====
/init
/setup-permissions --preset recommended
/setup-plugins --preset full
/setup-ralph-loop --enable

# ===== Phase 1: 趋势发现 =====
/social-media-publisher "搜索 15 个今天最热的 {TOPIC} 帖子，只看不互动"

# ===== Phase 2: 验证方向 =====
/crosscheck "{方案A} vs {方案B}：各有什么优缺点？"
/crosscheck "用 {技术栈} 实现 {功能}，这个方案合适吗？"

# ===== Phase 3: 自主开发 =====
/create-subagent {project}-developer  # 可选
/ralph-loop "
## 任务
{任务描述}

## 要求
1. {需求1}
2. {需求2}

## 验收标准
- 测试通过
- {其他标准}

完成后输出 <promise>DONE</promise>
" --completion-promise "DONE" --max-iterations 40

# ===== Phase 4: 代码验证 =====
/crosscheck "审查这个架构/代码，有什么问题？"
/agent verify-app

# ===== Phase 5: 多平台发布 =====
/social-media-publisher "基于 {TOPIC} 开发实践，发布到 all 平台"
python3 scripts/content_tracker.py verify
```

### 快速启动模板

复制下面的命令，替换 `{TOPIC}` 即可开始：

```bash
# 一键启动完整工作流
/social-media-publisher "搜索 15 个今天最热的 {TOPIC} 帖子，只看不互动"
```

---

## 工作流变体

### 变体 A: 纯研究型（无开发）
```
Discover → Verify → Verify Deep → Publish
```
适用于：技术调研、趋势分析、观点输出

### 变体 B: 纯开发型（无发布）
```
Verify → Develop → Re-verify → Iterate
```
适用于：内部项目、私有开发

### 变体 C: 快速迭代型
```
Discover → Develop → Publish → Discover (Loop)
```
适用于：持续产出、内容创作者

---

## 成本与时间参考

| 阶段 | 工具调用 | API 成本估算 |
|------|----------|--------------|
| Discover | 1-2 次 SocialPublisher | ~$0.5 |
| Verify | 2-3 次 CrossCheck | ~$2-3 |
| Develop | 20-50 次 Ralph Loop | ~$10-30 |
| Re-verify | 1-2 次 CrossCheck | ~$1-2 |
| Publish | 1 次 SocialPublisher | ~$0.5 |

**总计**: ~$15-40 / 完整工作流

---

## FAQ

**Q: 可以跳过某些阶段吗？**
A: 可以。根据需求选择：
- 最小闭环：`Verify → Develop`（内部项目）
- 内容闭环：`Discover → Verify → Publish`（纯研究）
- 开发闭环：`Verify → Develop → Re-verify`（无需发布）

**Q: Ralph Loop 迭代次数怎么设置？**
A: 参考值：
- 小功能（单文件）：10-15 次
- 中功能（多文件）：20-30 次
- 大功能（跨模块）：40-50 次
- 始终设置上限防止失控

**Q: CrossCheck 验证结论不一致怎么办？**
A: 这正是 CrossCheck 的价值。看 Round 3 的综合结论，通常会给出"场景化建议"而非绝对答案。

**Q: 没有趋势可发现怎么办？**
A: 可以跳过 Phase 1，直接从 Phase 2 开始。把你要解决的问题直接用 CrossCheck 验证。

**Q: 发布内容需要人工审核吗？**
A: 强烈建议。SocialPublisher 会在发布前展示预览，可以修改后再发布。技术内容尤其需要审核准确性。

**Q: 如何处理敏感信息？**
A:
- CrossCheck 验证时：脱敏后再提问
- 发布时：SocialPublisher 会预览，确认后再发
- 代码：不要把密钥/凭证放进 prompt

**Q: 工作流太长，有没有简化版？**
A: 有。根据场景选择变体（见下方"工作流变体"）。

---

## 相关文档

- [CrossCheck 使用指南](../skills/crosscheck/SKILL.md)
- [SocialPublisher 使用指南](../skills/social-publisher/SKILL.md)
- [Ralph Loop 配置指南](../skills/boris-workflow/commands/setup-ralph-loop.md)
- [Subagent 创建指南](../skills/boris-workflow/create-subagent/SKILL.md)
