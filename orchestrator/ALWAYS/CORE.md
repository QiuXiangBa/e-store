# 工作协议

## GitHub 是唯一真相源

所有任务管理、上下文传递、进度跟踪都在 GitHub 上完成：

| 信息 | 载体 |
|------|------|
| 任务定义 | Issue body |
| 阶段状态 | Issue checklist + Project Board |
| 工作进展 | Issue comment |
| 交接文档 | Issue comment（`## HANDOFF`） |
| 完成记录 | PR + Issue 完成 comment |

---

## 阶段闸门规则（强制）

1. 流程必须按 S1 -> S2 -> S3 -> S4 -> S5 -> S6 -> S7 执行
2. 仅 S1、S2 需要用户确认
3. S3-S7 自动推进，不再向用户请求阶段确认
4. 未完成当前阶段产物时，不允许跳阶段
5. Java 后端阶段（S4）必须符合 `java-backend-standards`，不符合不得进入 S5/S6
6. 找不到对应开发规范时，必须先向用户确认后再继续执行

---

## S2 质量要求（强制）

S2 技术方案必须同时具备：

1. 数据库设计
2. API 设计
3. API 时序图（Mermaid sequenceDiagram）
4. UML 图（Mermaid classDiagram 或领域结构图）

且 S2 不写具体实现代码细节。

---

## Issue Comment 规范

### 开工

```markdown
开始开发，分支: `feature/<issue-number>-<short-name>`
当前阶段: S1
```

### 阶段完成（示例）

```markdown
## 阶段完成

- 阶段: S2
- 产物: repos/docs/requirements/<repo>/<issue-number>/02-tech-design.md
- 状态: 待用户确认
```

### HANDOFF（会话中断必须写）

```markdown
## HANDOFF

### 当前阶段
S4

### 已完成
- xxx

### 下一步
1. xxx
2. xxx

### 分支
`feature/<issue-number>-<short-name>` @ <commit-sha>

### 注意事项
- xxx
```

### 完成

```markdown
## 完成

PR #<id> 已提交/合并。

### 验证
- [x] 单元测试通过
- [x] 构建通过
- [x] 联调测试通过
- [x] 用户验收通过
```

---

## Worktree 使用

推荐使用 `git worktree` 进行任务隔离开发，避免多任务互相污染。

---

## Java 后端质量门禁

当需求涉及 Java 后端改动时，提交前必须通过以下检查：

1. 满足 `java-backend-standards` 的分层、DTO、Convert、常量/枚举规范
2. 不存在循环内逐条查询或逐条写入（批处理必须批量化）
3. 在阶段记录中明确“已按 `java-backend-standards` 自检”

---

## 文件通信原则

1. 阶段产物优先落盘到仓库文档文件
2. 对话中只给摘要与路径
3. 大段内容放文档或 Issue comment，避免污染上下文窗口
4. 若规范缺失或不可读，先确认规范来源，不做默认实现
