package cangjie

import std.collection.*

// ===== 枚举：角色 =====
public enum Role <: ToString {
    | User
    | Admin

    public func toString(): String {
        match (this) {
            case User  => "USER"
            case Admin => "ADMIN"
        }
    }
}

// ===== 枚举：用户状态 =====
public enum UserStatus <: ToString & Equatable<UserStatus> {
    | Active
    | Disabled

    public func toString(): String {
        match (this) {
            case Active   => "ACTIVE"
            case Disabled => "DISABLED"
        }
    }

    public operator func ==(right: UserStatus): Bool {
        match ((this, right)) {
            case (Active, Active) => true
            case (Disabled, Disabled) => true
            case _ => false
        }
    }

    public operator func !=(right: UserStatus): Bool {
        return !(this == right)
    }
}

// ===== 枚举：业务类型 =====
public enum BusinessType <: ToString & Equatable<BusinessType> {
    | SecondHand
    | LOST
    | FOUND

    public func toString(): String {
        match (this) {
            case SecondHand => "SECONDHAND"
            case LOST       => "LOST"
            case FOUND      => "FOUND"
        }
    }

    public operator func ==(right: BusinessType): Bool {
        match ((this, right)) {
            case (SecondHand, SecondHand) => true
            case (LOST,       LOST)       => true
            case (FOUND,      FOUND)      => true
            case _ => false
        }
    }

    public operator func !=(right: BusinessType): Bool {
        return !(this == right)
    }
}

// ===== 枚举：审核状态 =====
public enum AuditStatus <: ToString & Equatable<AuditStatus> {
    | PENDING
    | APPROVED
    | REJECTED

    public func toString(): String {
        match (this) {
            case PENDING  => "待审核"
            case APPROVED => "已通过"
            case REJECTED => "已驳回"
        }
    }

    public operator func ==(right: AuditStatus): Bool {
        match ((this, right)) {
            case (PENDING,  PENDING)  => true
            case (APPROVED, APPROVED) => true
            case (REJECTED, REJECTED) => true
            case _ => false
        }
    }

    public operator func !=(right: AuditStatus): Bool {
        return !(this == right)
    }
}

// ===== 枚举：业务状态 =====
public enum BizStatus <: ToString & Equatable<BizStatus> {
    | ON_SALE    // 二手：在售
    | RESERVED   // 二手：预定中
    | SOLD       // 二手：已售出
    | CLOSED     // 通用：已关闭
    | OPEN       // 失物/招领：待认领
    | MATCHING   // 失物/招领：认领处理中
    | CLAIMED    // 失物/招领：已认领

    public func toString(): String {
        match (this) {
            case ON_SALE  => "在售"
            case RESERVED => "预定中"
            case SOLD     => "已售出"
            case CLOSED   => "已关闭"
            case OPEN     => "待认领"
            case MATCHING => "认领处理中"
            case CLAIMED  => "已认领"
        }
    }

    public operator func ==(right: BizStatus): Bool {
        match ((this, right)) {
            case (ON_SALE,  ON_SALE)  => true
            case (RESERVED, RESERVED) => true
            case (SOLD,     SOLD)     => true
            case (CLOSED,   CLOSED)   => true
            case (OPEN,     OPEN)     => true
            case (MATCHING, MATCHING) => true
            case (CLAIMED,  CLAIMED)  => true
            case _ => false
        }
    }

    public operator func !=(right: BizStatus): Bool {
        return !(this == right)
    }
}

// ===== 枚举：留言类型 =====
public enum MessageType <: ToString & Equatable<MessageType> {
    | PUBLIC_COMMENT
    | PRIVATE_MESSAGE

    public func toString(): String {
        match (this) {
            case PUBLIC_COMMENT  => "PUBLIC_COMMENT"
            case PRIVATE_MESSAGE => "PRIVATE_MESSAGE"
        }
    }

    public operator func ==(right: MessageType): Bool {
        match ((this, right)) {
            case (PUBLIC_COMMENT,  PUBLIC_COMMENT)  => true
            case (PRIVATE_MESSAGE, PRIVATE_MESSAGE) => true
            case _ => false
        }
    }

    public operator func !=(right: MessageType): Bool {
        return !(this == right)
    }
}

// ===== 枚举：申请类型 =====
public enum RequestType <: ToString & Equatable<RequestType> {
    | BUY
    | CLAIM

    public func toString(): String {
        match (this) {
            case BUY   => "BUY"
            case CLAIM => "CLAIM"
        }
    }

    public operator func ==(right: RequestType): Bool {
        match ((this, right)) {
            case (BUY,   BUY)   => true
            case (CLAIM, CLAIM) => true
            case _ => false
        }
    }

    public operator func !=(right: RequestType): Bool {
        return !(this == right)
    }
}

// ===== 枚举：申请状态 =====
public enum RequestStatus <: ToString & Equatable<RequestStatus> {
    | PENDING
    | ACCEPTED
    | REJECTED
    | CANCELLED
    | DONE

    public func toString(): String {
        match (this) {
            case PENDING   => "PENDING"
            case ACCEPTED  => "ACCEPTED"
            case REJECTED  => "REJECTED"
            case CANCELLED => "CANCELLED"
            case DONE      => "DONE"
        }
    }

    public operator func ==(right: RequestStatus): Bool {
        match ((this, right)) {
            case (PENDING,   PENDING)   => true
            case (ACCEPTED,  ACCEPTED)  => true
            case (REJECTED,  REJECTED)  => true
            case (CANCELLED, CANCELLED) => true
            case (DONE,      DONE)      => true
            case _ => false
        }
    }

    public operator func !=(right: RequestStatus): Bool {
        return !(this == right)
    }
}

// ===== 枚举：分类场景 =====
public enum SceneType <: ToString & Equatable<SceneType> {
    | SECONDHAND
    | LOST
    | FOUND
    | ALL

    public func toString(): String {
        match (this) {
            case SECONDHAND => "SECONDHAND"
            case LOST       => "LOST"
            case FOUND      => "FOUND"
            case ALL        => "ALL"
        }
    }

    public operator func ==(right: SceneType): Bool {
        match ((this, right)) {
            case (SECONDHAND, SECONDHAND) => true
            case (LOST,       LOST)       => true
            case (FOUND,      FOUND)      => true
            case (ALL,        ALL)        => true
            case _ => false
        }
    }

    public operator func !=(right: SceneType): Bool {
        return !(this == right)
    }
}

// ===== Entity: User =====
public class User {
    public var id: Int64
    public let username: String
    public let password: String
    public let nickname: String
    public let avatarUrl: String
    public let phone: String
    public let role: Role
    public var status: UserStatus
    public let createdAt: String
    public var updatedAt: String

    public init(
        id: Int64,
        username: String,
        password: String,
        nickname: String,
        avatarUrl: String,
        phone: String,
        role: Role
    ) {
        this.id       = id
        this.username = username
        this.password = password
        this.nickname = nickname
        this.avatarUrl = avatarUrl
        this.phone    = phone
        this.role     = role
        this.status   = UserStatus.Active
        this.createdAt = ""
        this.updatedAt = ""
    }

    public func toString(): String {
        return "User{id=${id}" +
            ", username=${username}" +
            ", nickname=${nickname}" +
            ", role=${role}}"
    }
}

// ===== Entity: Category =====
public class Category {
    public var id: Int64
    public let name: String
    public let parentId: Option<Int64>
    public let sceneType: SceneType
    public var sortOrder: Int64
    public var isEnabled: Bool

    public init(
        id: Int64,
        name: String,
        parentId: Option<Int64>,
        sceneType: SceneType,
        sortOrder: Int64,
        isEnabled: Bool
    ) {
        this.id       = id
        this.name     = name
        this.parentId = parentId
        this.sceneType = sceneType
        this.sortOrder = sortOrder
        this.isEnabled = isEnabled
    }

    public func toString(): String {
        return "Category{id=${id}" +
            ", name=${name}" +
            ", scene=${sceneType}}"
    }
}

// ===== Entity: Post (原 BaseItem) =====
public class Post {
    public var id: Int64
    public var authorId: Int64
    public var categoryId: Int64
    public let businessType: BusinessType
    public let title: String
    public let description: String
    public var price: Option<Float64>
    public let location: String
    public let imageUrls: String
    public let contactInfo: String
    public var auditStatus: AuditStatus
    public var bizStatus: BizStatus
    public var viewCount: Int64
    public var favoriteCount: Int64
    public let createdAt: String
    public var updatedAt: String
    public var closedAt: Option<String>
    public var isDeleted: Bool

    public init(
        id: Int64,
        authorId: Int64,
        categoryId: Int64,
        businessType: BusinessType,
        title: String,
        description: String,
        price: Option<Float64>,
        location: String,
        imageUrls: String,
        contactInfo: String
    ) {
        this.id         = id
        this.authorId   = authorId
        this.categoryId = categoryId
        this.businessType = businessType
        this.title      = title
        this.description = description
        this.price      = price
        this.location   = location
        this.imageUrls  = imageUrls
        this.contactInfo = contactInfo
        this.auditStatus = AuditStatus.PENDING
        this.bizStatus  = BizStatus.ON_SALE
        this.viewCount  = 0
        this.favoriteCount = 0
        this.createdAt  = ""
        this.updatedAt  = ""
        this.closedAt   = None
        this.isDeleted  = false
    }

    public func toString(): String {
        return "Post{id=${id}" +
            ", title=${title}" +
            ", type=${businessType}" +
            ", audit=${auditStatus}" +
            ", biz=${bizStatus}}"
    }
}

// ===== DTO: PublishPostReq =====
public class PublishPostReq {
    public let categoryId: Int64
    public let businessType: BusinessType
    public let title: String
    public let description: String
    public let price: Option<Float64>
    public let location: String
    public let imageUrls: String
    public let contactInfo: String

    public init(
        categoryId: Int64,
        businessType: BusinessType,
        title: String,
        description: String,
        price: Option<Float64>,
        location: String,
        imageUrls: String,
        contactInfo: String
    ) {
        this.categoryId = categoryId
        this.businessType = businessType
        this.title      = title
        this.description = description
        this.price      = price
        this.location   = location
        this.imageUrls  = imageUrls
        this.contactInfo = contactInfo
    }
}

// ===== DTO: LoginReq =====
public class LoginReq {
    public let username: String
    public let password: String

    public init(
        username: String,
        password: String
    ) {
        this.username = username
        this.password = password
    }
}

// ===== DTO: SearchParams =====
public class SearchParams {
    public var keyword: String
    public var categoryId: Option<Int64>
    public var businessType: Option<BusinessType>
    public var minPrice: Option<Float64>
    public var maxPrice: Option<Float64>
    public var auditStatus: Option<AuditStatus>
    public var bizStatus: Option<BizStatus>
    public var sortBy: String
    public var page: Int64
    public var pageSize: Int64

    public init() {
        keyword = ""
        categoryId = None
        businessType = None
        minPrice = None
        maxPrice = None
        auditStatus = None
        bizStatus = None
        sortBy = "latest"
        page = 1
        pageSize = 20
    }
}

// ===== DTO: OverviewStats =====
public class OverviewStats {
    public var totalUsers: Int64
    public var totalPosts: Int64
    public var pendingAuditCount: Int64
    public var secondhandCount: Int64
    public var lostCount: Int64
    public var foundCount: Int64
    public var hotCategories: ArrayList<CategoryStats>

    public init() {
        totalUsers = 0
        totalPosts = 0
        pendingAuditCount = 0
        secondhandCount = 0
        lostCount = 0
        foundCount = 0
        hotCategories = ArrayList<CategoryStats>()
    }
}

// ===== DTO: CategoryStats =====
public class CategoryStats {
    public var categoryId: Int64
    public var categoryName: String
    public var count: Int64

    public init(
        id: Int64,
        name: String,
        cnt: Int64
    ) {
        categoryId = id
        categoryName = name
        count = cnt
    }
}

// ===== DTO: StatusDist =====
public class StatusDist {
    public var statusName: String
    public var count: Int64

    public init(name: String, cnt: Int64) {
        statusName = name
        count = cnt
    }
}

// ===== Entity: Message =====
public class Message {
    public var id: Int64
    public let postId: Option<Int64>
    public let fromUserId: Int64
    public let toUserId: Option<Int64>
    public let messageType: MessageType
    public let content: String
    public let parentId: Option<Int64>
    public var isRead: Bool
    public let createdAt: String

    public init(
        id: Int64,
        postId: Option<Int64>,
        fromUserId: Int64,
        toUserId: Option<Int64>,
        messageType: MessageType,
        content: String,
        parentId: Option<Int64>,
        createdAt: String
    ) {
        this.id         = id
        this.postId     = postId
        this.fromUserId = fromUserId
        this.toUserId   = toUserId
        this.messageType = messageType
        this.content    = content
        this.parentId   = parentId
        this.isRead     = false
        this.createdAt  = createdAt
    }

    public func toString(): String {
        return "Message{id=${id}" +
            ", type=${messageType}" +
            ", from=${fromUserId}}"
    }
}

// ===== Entity: AuditRecord =====
public class AuditRecord {
    public var id: Int64
    public let postId: Int64
    public let auditorId: Int64
    public let auditResult: AuditStatus
    public let reason: String
    public let createdAt: String

    public init(
        id: Int64,
        postId: Int64,
        auditorId: Int64,
        auditResult: AuditStatus,
        reason: String,
        createdAt: String
    ) {
        this.id         = id
        this.postId     = postId
        this.auditorId  = auditorId
        this.auditResult = auditResult
        this.reason     = reason
        this.createdAt  = createdAt
    }

    public func toString(): String {
        return "AuditRecord{id=${id}" +
            ", post=${postId}" +
            ", result=${auditResult}}"
    }
}

// ===== Entity: Request（意向申请）=====
public class Request {
    public var id: Int64
    public let postId: Int64
    public let requesterId: Int64
    public let requestType: RequestType
    public var status: RequestStatus
    public let note: String
    public let createdAt: String
    public var updatedAt: String

    public init(
        id: Int64,
        postId: Int64,
        requesterId: Int64,
        requestType: RequestType,
        note: String,
        createdAt: String
    ) {
        this.id          = id
        this.postId      = postId
        this.requesterId = requesterId
        this.requestType = requestType
        this.status      = RequestStatus.PENDING
        this.note        = note
        this.createdAt   = createdAt
        this.updatedAt   = createdAt
    }

    public func toString(): String {
        return "Request{id=${id}" +
            ", post=${postId}" +
            ", type=${requestType}" +
            ", status=${status}}"
    }
}
