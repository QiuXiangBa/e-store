# 开发流程

## 阶段闸门（Stage Gate）

本项目统一采用 S1-S7 流程：

1. S1：PRD 文档
2. S2：技术方案（含数据库设计 + API 设计 + 时序图 + UML）
3. S3：测试用例
4. S4：服务端接口开发 + 单元测试
5. S5：客户端页面开发 + 语法/构建检查
6. S6：按测试用例执行完整联调测试
7. S7：用户验收

## 轻量流程（Fast Lane）

以下场景允许走轻量流程，避免完整 S1-S7 带来的过度开销：

1. 文案/UI 微调，不改接口和数据结构
2. 小型缺陷修复，不改表结构和核心流程
3. 非功能性改造（lint、注释、重命名、脚手架清理）

轻量流程规则：

1. 仍需创建/关联 Issue
2. 将 S1+S2 合并为一个 `mini-design` 段落写入 Issue
3. 保留 S3（最小测试点）与 S5/S6（构建与回归验证）
4. 涉及 Java 后端逻辑时，仍强制执行 `java-backend-standards`

## Java 后端执行规范（强制）

涉及 Java 后端开发（尤其 S4）时，必须遵循 `java-backend-standards`：

1. 分层调用：Controller -> Service -> BizMapper -> Mapper
2. Service 仅操作 DTO；BizMapper 返回 DTO
3. VO/DTO/PO 转换必须通过 Convert（MapStruct）
4. 非 boolean 魔法值使用常量或枚举
5. 批处理禁止循环内逐条查询/逐条写入，必须批量查询+批量写入

## 规范缺失确认规则（强制）

当任务需要遵循某类开发规范，但未找到对应规范文档（或规范路径不可读）时：

1. 必须先暂停进入实现阶段
2. 必须先向用户确认规范来源或替代规范
3. 未经用户确认，不得按默认习惯继续开发

## 用户确认规则

仅 S1、S2 需要用户确认：

1. S1 完成后，等待用户确认再进入 S2
2. S2 完成后，等待用户确认再进入 S3
3. S3-S7 不再等待用户确认，按流程自动推进

## S2 范围约束（强制）

S2 技术方案必须包含：

1. 数据库设计（表结构、字段、索引、约束、变更策略）
2. API 设计（路径、方法、请求/响应、错误码、兼容策略）
3. API 时序图（Mermaid sequenceDiagram）
4. UML 图（Mermaid classDiagram 或实体关系/领域关系图）

S2 技术方案禁止包含：

1. 具体实现代码细节
2. 过细的类内方法实现步骤

## 每阶段产物

每个需求（Issue #N）统一在 docs 仓库维护文档目录：

`repos/docs/requirements/<repo>/<issue-number>/`

建议文件：

1. `01-prd.md`（S1）
2. `02-tech-design.md`（S2）
3. `03-test-cases.md`（S3）
4. `04-test-report.md`（S6）
5. `05-acceptance.md`（S7）

## 文档提交流程（强制）

所有阶段文档（S1-S7）在生成或更新后，必须按以下顺序执行：

1. 提交到 docs 仓库（git commit）
2. 推送到远端仓库（git push）
3. 在回复中提供网络可访问地址：
   - 文件链接（blob URL）
   - 提交链接（commit URL）

## GitHub Issue 模板清单

在 Issue body 中使用如下清单跟踪阶段：

```markdown
- [ ] S1 PRD 已确认
- [ ] S2 技术方案（DB + API + 时序图 + UML）已确认
- [ ] S3 测试用例已完成
- [ ] S4 服务端接口 + 单元测试已完成
- [ ] S5 客户端页面 + 语法检查已通过
- [ ] S6 按测试用例联调测试已通过
- [ ] S7 用户验收通过
```

## Issue 与 Comment 角色边界（强制）

1. Issue checklist 是唯一阶段状态源
2. Comment 不重复“阶段状态”，只写：
   - 本次变更摘要
   - 产物/PR/提交链接
   - 风险与阻塞
   - 下一步
3. Board 列状态由 Issue 驱动，不在本地维护副本

## 与 Code Relay 的结合

1. 每阶段关键结论写入 Issue comment
2. 会话中断时必须写 `## HANDOFF`
3. `## HANDOFF` 里明确当前阶段、下一阶段、阻塞项
4. S4 阶段完成前必须自检并确认符合 `java-backend-standards`
