# CC Suite - 微信朋友圈文案

## 版本 A：问题导向

用 AI 写代码的朋友们，有没有遇到过这种情况：

AI 信誓旦旦地给你一个方案，你照着做了，结果发现是错的。

这就是"AI 幻觉"，而且出现频率比你想象的高得多。

我做了个工具叫 CC Suite，核心思路很简单：让 Claude、Codex、Gemini 三个 AI 互相质疑，只有三个都认可的答案才输出。

实测幻觉率降低 90%+。

开源的，不要钱：github.com/leiMizzou/CC-Suite

---

## 版本 B：成果展示

花了两周做了个小工具，今天开源了。

**CC Suite - Claude Code 标准库**

三个功能：
1. CrossCheck：让 3 个 AI 互相打架，只有真相能活下来
2. SocialPublisher：从发现热点到一键发布，技术人也能做内容
3. BorisWorkflow：Claude Code 之父的最佳实践，一行命令搞定

做这个的初衷是自己用 Claude Code 的时候被幻觉坑过太多次。

有需要的朋友可以试试：github.com/leiMizzou/CC-Suite

觉得有用的话，给个 Star 支持一下~

---

## 版本 C：故事型

昨天用 Claude 写代码，它很自信地告诉我一个 API 的用法。

我信了。

结果调了两小时 bug，才发现那个 API 根本不存在，是它编的。

这种"一本正经胡说八道"的毛病叫 AI 幻觉，几乎所有大模型都有。

后来我想了个办法：让 Claude、Codex、Gemini 三个 AI 互相核实。A 说的话让 B 和 C 来验证，反过来也一样。

只有三方都认可的才算数。

效果出奇的好，幻觉率降了 90% 多。

把这个做成了工具开源出来，叫 CC Suite。

链接：github.com/leiMizzou/CC-Suite

---

## 版本 D：简洁版

**CC Suite 开源了**

一句话介绍：让 Claude、Codex、Gemini 互相打架，消除 AI 幻觉。

三个核心功能：
- 多模型对抗验证
- 趋势发现+全平台发布
- Claude Code 最佳实践一键配置

github.com/leiMizzou/CC-Suite

Star 支持~

---

## 版本 E：技术向

给用 Claude Code 的朋友分享一个工具。

核心解决"锯齿状智能"问题——AI 时灵时不灵，上一秒天才下一秒犯蠢。

**技术方案：**
- 3 轮多模型交叉验证（Claude + Codex + Gemini）
- 对抗式 prompt 设计，强制模型互相质疑
- 只输出共识结论，分歧时给出对比分析

**附加功能：**
- 趋势发现 → 内容提炼 → 多平台分发
- Boris Cherny (Claude Code 作者) 的 Twitter 最佳实践打包

完全开源：github.com/leiMizzou/CC-Suite

---

## 配图建议

1. 宣传视频截图（CrossCheck 三模型对战画面）
2. GitHub Star 数截图
3. 工作流程图
4. 使用效果对比图（有/无 CrossCheck 的幻觉率）

---

## 发布时间建议

- 工作日：12:00-13:00（午休时间）、21:00-22:00（下班后）
- 周末：10:00-11:00、20:00-21:00

技术类内容工作日效果更好，目标用户多为程序员。
