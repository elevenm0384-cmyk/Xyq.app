# 校园二手交易与失物招领平台 —— 第三组成员3负责部分

## 项目简介

本模块为校园二手交易与失物招领平台的核心后端实现，使用**仓颉语言（Cangjie 1.0.5）**编写，采用纯内存存储模拟数据库，完整实现用户认证、物品管理、分类管理和管理员审核四大功能。

---

## 模块职责

本部分负责平台的**公共层、数据模型层、数据仓库层和基础服务层**，对应需求文档中的 Module 1～4。

---

## 目录结构

```
cangjie/
├── src/
│   ├── common.cj        # 公共层：错误码、ApiResponse、PageResult
│   ├── models.cj        # 模型层：枚举、实体类、DTO
│   ├── repository.cj    # 仓库层：内存存储、SessionManager、Mock数据初始化
│   ├── base_service.cj  # 服务层：AuthService、ItemBaseService、AdminService、CategoryService
│   └── main.cj          # 入口：端到端演示
└── out/
    └── main             # 编译产物
```

---

## 分层架构

```
main.cj
  └── base_service.cj   （服务层）
        └── repository.cj  （仓库层）
              └── models.cj    （模型层）
                    └── common.cj  （公共层）
```

---

## 各层说明

### 公共层 `common.cj`

| 类型 | 说明 |
|------|------|
| `ErrorCode` | 枚举，定义 HTTP 状态码（200/400/401/403/404/500）及业务码（1001-1003 用户类，2001-2002 物品类，3001 分类类） |
| `ApiResponse<T>` | 泛型响应包装，包含 `code`、`msg`、`data` 三个字段，提供 `ok()`、`okEmpty()`、`fail()` 三个工厂方法 |
| `PageResult<T>` | 分页结果包装，包含 `total`、`currentPage`、`pageSize`、`list`，提供 `totalPages()` 计算 |

### 模型层 `models.cj`

| 类型 | 说明 |
|------|------|
| `Role` | 枚举：`Student` / `Admin` |
| `ItemType` | 枚举：`SecondHand`（二手交易）/ `LostFound`（失物招领），实现 `Equatable` |
| `ItemStatus` | 枚举：`Pending` / `Approved` / `Rejected` / `Closed`，实现 `Equatable` |
| `User` | 用户实体：id、username、password、email、role |
| `BaseItem` | 物品实体：id、title、description、categoryId、publisherId、itemType、status、imageUrl、contactInfo |
| `Category` | 分类实体：id、name、parentId（支持父子分类） |
| `PublishItemReq` | 发布物品请求 DTO |
| `LoginReq` | 登录请求 DTO |

### 仓库层 `repository.cj`

| 类 | 说明 |
|----|------|
| `SessionManager` | Token 管理，`createToken()` 生成随机 Token，`getUserId()` 验证，`invalidate()` 登出 |
| `UserRepository` | 用户内存存储，支持按 id / username 查询 |
| `ItemRepository` | 物品内存存储，支持按类型、状态查询及分页 |
| `CategoryRepository` | 分类内存存储，初始化5个默认分类（教材书籍、数码电器、生活用品、运动户外、失物招领） |
| `mockDataInit()` | 初始化测试数据：admin + alice + bob 用户，5条二手物品，3条失物招领 |

所有仓库类均采用**单例模式**，通过 `getInstance()` 获取实例。

### 服务层 `base_service.cj`

| 服务 | 主要方法 |
|------|---------|
| `AuthService` | `register()` 注册、`login()` 登录、`logout()` 登出、`whoami()` 查询当前用户 |
| `CategoryService` | `listAll()` 全部分类、`listRoots()` 根分类、`findById()` 按 id 查询 |
| `ItemBaseService` | `publish()` 发布物品、`getById()` 查询、`listPage()` 分页、`listByType()` 按类型查询、`close()` 关闭物品 |
| `AdminService` | `approve()` 审核通过、`reject()` 审核拒绝、`listPending()` 待审核列表、`listUsers()` 用户列表 |

---

## 编译与运行

```bash
# 编译
cjc src/common.cj src/models.cj src/repository.cj src/base_service.cj src/main.cj -o out/main

# 运行
./out/main
```

环境要求：Cangjie 编译器 1.0.5+

---

## 运行结果

```
=== 分类列表 ===
ApiResponse{code=200, msg=操作成功, data=(有数据)}

=== 注册新用户 ===
ApiResponse{code=200, msg=操作成功, data=(有数据)}

=== 重复注册（应报错）===
ApiResponse{code=1001, msg=用户已存在, data=null}

=== 登录 charlie ===
ApiResponse{code=200, msg=操作成功, data=(有数据)}

=== 管理员审核通过 itemId=1 ===
ApiResponse{code=200, msg=操作成功, data=(有数据)}

=== 非管理员审核（应403）===
ApiResponse{code=403, msg=权限不足, data=null}

=== 重复关闭（应报错）===
ApiResponse{code=2002, msg=物品已关闭, data=null}

=== 登出后发布（应401）===
ApiResponse{code=401, msg=未登录或Token已过期, data=null}
```

所有业务场景均通过验证：权限控制（403）、登录态校验（401）、重复操作拦截（1001/2002）均符合预期。

---

## 关键设计说明

- **单例模式**：所有 Service 和 Repository 均通过 `getInstance()` 保证全局唯一实例，模拟 Spring Bean 的生命周期管理。
- **泛型响应**：`ApiResponse<T>` 统一封装所有接口返回值，调用方通过 `code` 判断成功与否，通过 `data` 取出业务数据。
- **Token 会话**：使用随机数生成 Token，存入 `HashMap` 映射到 userId，登出时删除，模拟无状态 Token 认证。
- **内存存储**：所有数据存储在 `HashMap<Int64, Entity>` 中，id 自增，无需数据库依赖，便于演示和测试。
