# 校园二手交易与失物招领平台

仓颉语言期末大作业后端，仓颉 1.0.5，内存存储。

## 项目结构

```
src/
├── common.cj              # ErrorCode、ApiResponse、PageResult
├── models.cj              # 枚举、实体、DTO
├── repository.cj          # 内存仓库 + Session + Mock 数据
├── base_service.cj        # Auth、Category、PostBase、Admin
├── business_repo.cj       # Message 仓库、Audit 仓库
├── business_service.cj    # Trade、Claim、EnhancedAdmin、Message
├── search_service.cj      # 搜索、筛选、排序
├── statistics_service.cj  # 统计
└── main.cj                # 入口
```

## 划分

- **3号（基础后端）**：common.cj、models.cj、repository.cj、base_service.cj
- **4号（业务逻辑）**：business_repo.cj、business_service.cj、search_service.cj、statistics_service.cj

## 编译运行

需要 Cangjie 1.0.5。

```bash
cjc -p src -o out/main
./out/main
```

## 状态设计

### 审核状态（audit_status）

| 值 | 含义 |
|----|------|
| PENDING | 待审核 |
| APPROVED | 已通过 |
| REJECTED | 已驳回 |

### 业务状态（biz_status）

**二手商品**

| 值 | 含义 |
|----|------|
| ON_SALE | 在售 |
| RESERVED | 预定中 |
| SOLD | 已售出 |
| CLOSED | 已关闭 |

**失物/招领**

| 值 | 含义 |
|----|------|
| OPEN | 待认领 |
| MATCHING | 认领处理中 |
| CLAIMED | 已认领 |
| CLOSED | 已关闭 |

## 核心流程

### 二手交易

发布 → 待审核 → 审核通过（ON_SALE） → 买家发起 BUY 申请 → 卖家接受（RESERVED） → 完成（SOLD）

### 失物认领

发布 → 待审核 → 审核通过（OPEN） → 认领人发起 CLAIM 申请 → 发布者接受（MATCHING） → 完成（CLAIMED）
