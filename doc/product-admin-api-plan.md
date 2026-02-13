# Product Admin 对齐计划（仅管理端）

## 目标与边界
- 目标：对齐 `eg/ruoyi-vue-pro-2026.01-jdk17-21-/yudao-module-mall/yudao-module-product` 的 **admin 商品管理功能**。
- 仅做管理端：admin controller 能力对齐。
- 不接权限体系：本期不实现 `PreAuthorize` 等权限控制。
- 不做导出：本期不实现 `export-excel`。

## 当前现状（e-store）
- 已有：`product_brand`、`product_category`、`product_property`、`product_property_value`、`product_spu`、`product_sku`、`product_comment` 的 PO/Mapper 基础结构。
- 缺失：管理端 Controller、Service 业务层、分页查询能力、商品收藏/浏览历史表与对应 DAO。

## 对齐接口清单（admin）

### 1) 品牌 `/product/brand`
- `POST /create`
- `PUT /update`
- `DELETE /delete`
- `GET /get`
- `GET /list-all-simple`
- `GET /page`
- `GET /list`

### 2) 分类 `/product/category`
- `POST /create`
- `PUT /update`
- `DELETE /delete`
- `GET /get`
- `GET /list`

### 3) 规格属性 `/product/property`
- `POST /create`
- `PUT /update`
- `DELETE /delete`
- `GET /get`
- `GET /page`
- `GET /simple-list`

### 4) 规格值 `/product/property/value`
- `POST /create`
- `PUT /update`
- `DELETE /delete`
- `GET /get`
- `GET /page`
- `GET /simple-list`

### 5) SPU `/product/spu`
- `POST /create`
- `PUT /update`
- `PUT /update-status`
- `DELETE /delete`
- `GET /get-detail`
- `GET /list-all-simple`
- `GET /list`
- `GET /page`
- `GET /get-count`
- `GET /export-excel`（本期不做）

### 6) 评论管理 `/product/comment`
- `GET /page`
- `PUT /update-visible`
- `PUT /reply`
- `POST /create`

### 7) 收藏管理 `/product/favorite`
- `GET /page`

### 8) 浏览历史 `/product/browse-history`
- `GET /page`

## 功能拆分（执行顺序）

### 阶段 A：公共基础（P0）
1. 定义统一分页模型（PageReq / PageResp），并兼容 `Out<T>`。
2. 增加 product 领域错误码（唯一性、状态非法、层级非法、删除约束等）。
3. 增加 admin DTO/VO 命名规范与包结构（brand/category/property/spu/comment/favorite/history）。

验收：
- 所有后续 controller/service 可复用统一分页/错误码模型。

### 阶段 B：DAO 与数据结构补齐（P0）
1. 新增 `product_favorite`、`product_browse_history` 的 PO + Mapper + XML。
2. 为现有 Mapper 增加管理端所需查询（分页、列表、统计、按条件筛选）。
3. 更新 `app/product/src/main/resources/sql/create_tables.sql`（补齐缺失表）。

验收：
- 管理端全部接口所需查询在 DAO 层可表达。

### 阶段 C：基础管理能力（P0）
1. 品牌：CRUD + page + list + simple-list。
2. 分类：CRUD + list，含父子层级校验、删除约束（子分类/SPU引用）。
3. 规格属性：CRUD + page + simple-list。
4. 规格值：CRUD + page + simple-list（按 propertyId）。

验收：
- 上述四类接口按清单可调用且返回结构稳定。

### 阶段 D：SPU/SKU 核心能力（P0）
1. SPU 创建/更新：校验品牌、分类、SKU 组合合法性。
2. SKU 组合校验：单规格默认属性、多规格去重、库存/价格汇总回写 SPU。
3. SPU 状态更新、删除（回收站约束）、详情聚合（SPU + SKU）、分页与计数。

验收：
- SPU 全链路（建、改、查、状态、删）可用；`get-count` 可用。

### 阶段 E：运营管理能力（P1）
1. 评论管理：分页、可见性更新、回复、后台创建。
2. 收藏管理：分页查询。
3. 浏览历史：分页查询。

验收：
- 三类管理接口可用于后台运营查询和处理。

### 阶段 F：联调与回归（P0）
1. 提供 `api.http` 覆盖上述管理端接口。
2. 增加关键 service 测试（品牌/分类/SPU/SKU/评论）。
3. 输出“已实现 vs eg 差异”清单（明确仅 admin、无权限、无导出）。

验收：
- 关键路径可通过 HTTP 用例与测试验证。

## 业务规则基线（本期）
- 分类层级：沿用 eg 规则，SPU 必须挂到有效层级分类（非根）。
- 品牌/分类/属性/属性值：支持状态字段校验与“删除前引用检查”。
- SPU 删除：保留“非回收状态不可删”的规则。
- 权限：本期不做权限校验（接口默认可访问，后续再接入）。

## 非目标（本期明确不做）
- app 端商品接口。
- 导出 Excel。
- 细粒度权限控制与菜单权限点联动。
