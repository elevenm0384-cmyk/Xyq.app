package cangjie

// ===== 枚举：角色 =====
public enum Role <: ToString {
    | Student
    | Admin

    public func toString(): String {
        match (this) {
            case Student => "STUDENT"
            case Admin   => "ADMIN"
        }
    }
}

// ===== 枚举：物品类型 =====
public enum ItemType <: ToString & Equatable<ItemType> {
    | SecondHand
    | LostFound

    public func toString(): String {
        match (this) {
            case SecondHand => "二手交易"
            case LostFound  => "失物招领"
        }
    }

    public operator func ==(
        right: ItemType
    ): Bool {
        match ((this, right)) {
            case (SecondHand, SecondHand) => true
            case (LostFound,  LostFound)  => true
            case _ => false
        }
    }

    public operator func !=(
        right: ItemType
    ): Bool {
        return !(this == right)
    }
}

// ===== 枚举：物品状态 =====
public enum ItemStatus <: ToString & Equatable<ItemStatus> {
    | Pending
    | Approved
    | Rejected
    | Closed

    public func toString(): String {
        match (this) {
            case Pending  => "待审核"
            case Approved => "已上架"
            case Rejected => "已拒绝"
            case Closed   => "已关闭"
        }
    }

    public operator func ==(
        right: ItemStatus
    ): Bool {
        match ((this, right)) {
            case (Pending,  Pending)  => true
            case (Approved, Approved) => true
            case (Rejected, Rejected) => true
            case (Closed,   Closed)   => true
            case _ => false
        }
    }

    public operator func !=(
        right: ItemStatus
    ): Bool {
        return !(this == right)
    }
}

// ===== 枚举：交易状态（二手商品精细流转）=====
public enum TradeStatus <: ToString & Equatable<TradeStatus> {
    | Idle
    | Reserved
    | Sold

    public func toString(): String {
        match (this) {
            case Idle     => "空闲"
            case Reserved => "交易中"
            case Sold     => "已售出"
        }
    }

    public operator func ==(
        right: TradeStatus
    ): Bool {
        match ((this, right)) {
            case (Idle,     Idle)     => true
            case (Reserved, Reserved) => true
            case (Sold,     Sold)     => true
            case _ => false
        }
    }

    public operator func !=(
        right: TradeStatus
    ): Bool {
        return !(this == right)
    }
}

// ===== 枚举：认领状态（失物精细流转）=====
public enum ClaimStatus <: ToString & Equatable<ClaimStatus> {
    | Idle
    | Claimed
    | Returned

    public func toString(): String {
        match (this) {
            case Idle     => "空闲"
            case Claimed  => "已认领"
            case Returned => "已归还"
        }
    }

    public operator func ==(
        right: ClaimStatus
    ): Bool {
        match ((this, right)) {
            case (Idle,     Idle)     => true
            case (Claimed,  Claimed)  => true
            case (Returned, Returned) => true
            case _ => false
        }
    }

    public operator func !=(
        right: ClaimStatus
    ): Bool {
        return !(this == right)
    }
}

// ===== 枚举：留言类型 =====
public enum MessageType <: ToString & Equatable<MessageType> {
    | Comment
    | PrivateMsg

    public func toString(): String {
        match (this) {
            case Comment    => "留言"
            case PrivateMsg => "私信"
        }
    }

    public operator func ==(
        right: MessageType
    ): Bool {
        match ((this, right)) {
            case (Comment,    Comment)    => true
            case (PrivateMsg, PrivateMsg) => true
            case _ => false
        }
    }

    public operator func !=(
        right: MessageType
    ): Bool {
        return !(this == right)
    }
}

// ===== Entity: User =====
public class User {
    public var id: Int64
    public let username: String
    public let password: String
    public let email: String
    public let role: Role

    public init(
        id: Int64,
        username: String,
        password: String,
        email: String,
        role: Role
    ) {
        this.id       = id
        this.username = username
        this.password = password
        this.email    = email
        this.role     = role
    }

    public func toString(): String {
        return "User{id=${id}" +
            ", username=${username}" +
            ", role=${role}}"
    }
}

// ===== Entity: Category =====
public class Category {
    public var id: Int64
    public let name: String
    public let parentId: Option<Int64>

    public init(
        id: Int64,
        name: String,
        parentId: Option<Int64>
    ) {
        this.id       = id
        this.name     = name
        this.parentId = parentId
    }

    public func toString(): String {
        return "Category{id=${id}" +
            ", name=${name}}"
    }
}

// ===== Entity: BaseItem =====
public class BaseItem {
    public var id: Int64
    public let title: String
    public let description: String
    public let categoryId: Int64
    public let publisherId: Int64
    public let itemType: ItemType
    public var status: ItemStatus
    public let imageUrl: String
    public let contactInfo: String
    // 交易扩展字段（仅二手）
    public var buyerId: Option<Int64>
    public var tradeStatus: TradeStatus
    // 认领扩展字段（仅失物）
    public var claimerId: Option<Int64>
    public var claimStatus: ClaimStatus

    public init(
        id: Int64,
        title: String,
        description: String,
        categoryId: Int64,
        publisherId: Int64,
        itemType: ItemType,
        status: ItemStatus,
        imageUrl: String,
        contactInfo: String
    ) {
        this.id          = id
        this.title       = title
        this.description = description
        this.categoryId  = categoryId
        this.publisherId = publisherId
        this.itemType    = itemType
        this.status      = status
        this.imageUrl    = imageUrl
        this.contactInfo = contactInfo
        this.buyerId     = None
        this.tradeStatus = TradeStatus.Idle
        this.claimerId   = None
        this.claimStatus = ClaimStatus.Idle
    }

    public func toString(): String {
        return "BaseItem{id=${id}" +
            ", title=${title}" +
            ", type=${itemType}" +
            ", status=${status}" +
            ", trade=${tradeStatus}" +
            ", claim=${claimStatus}}"
    }
}

// ===== DTO: PublishItemReq =====
public class PublishItemReq {
    public let title: String
    public let description: String
    public let categoryId: Int64
    public let itemType: ItemType
    public let imageUrl: String
    public let contactInfo: String

    public init(
        title: String,
        description: String,
        categoryId: Int64,
        itemType: ItemType,
        imageUrl: String,
        contactInfo: String
    ) {
        this.title       = title
        this.description = description
        this.categoryId  = categoryId
        this.itemType    = itemType
        this.imageUrl    = imageUrl
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
    public var itemType: Option<ItemType>
    public var minPrice: Option<Float64>
    public var maxPrice: Option<Float64>
    public var status: Option<ItemStatus>
    public var sortBy: String
    public var page: Int64
    public var pageSize: Int64

    public init() {
        keyword = ""
        categoryId = None
        itemType = None
        minPrice = None
        maxPrice = None
        status = None
        sortBy = "time_desc"
        page = 1
        pageSize = 20
    }
}

// ===== DTO: OverviewStats =====
public class OverviewStats {
    public var totalItems: Int64
    public var totalSecondHand: Int64
    public var totalLostFound: Int64
    public var pendingReviews: Int64
    public var activeTrades: Int64
    public var soldItems: Int64
    public var activeClaims: Int64
    public var returnedItems: Int64

    public init() {
        totalItems = 0
        totalSecondHand = 0
        totalLostFound = 0
        pendingReviews = 0
        activeTrades = 0
        soldItems = 0
        activeClaims = 0
        returnedItems = 0
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
    public let targetType: String
    public let targetId: Int64
    public let fromUserId: Int64
    public let toUserId: Option<Int64>
    public let msgType: MessageType
    public let content: String
    public let parentId: Option<Int64>
    public var isRead: Bool
    public let createdAt: String

    public init(
        id: Int64,
        targetType: String,
        targetId: Int64,
        fromUserId: Int64,
        toUserId: Option<Int64>,
        msgType: MessageType,
        content: String,
        parentId: Option<Int64>,
        createdAt: String
    ) {
        this.id         = id
        this.targetType = targetType
        this.targetId   = targetId
        this.fromUserId = fromUserId
        this.toUserId   = toUserId
        this.msgType    = msgType
        this.content    = content
        this.parentId   = parentId
        this.isRead     = false
        this.createdAt  = createdAt
    }

    public func toString(): String {
        return "Message{id=${id}" +
            ", type=${msgType}" +
            ", from=${fromUserId}" +
            ", content=${content}}"
    }
}

// ===== Entity: ReviewRecord =====
public enum ReviewResult <: ToString & Equatable<ReviewResult> {
    | Pending
    | Approved
    | Rejected

    public func toString(): String {
        match (this) {
            case Pending  => "待审核"
            case Approved => "已通过"
            case Rejected => "已驳回"
        }
    }

    public operator func ==(
        right: ReviewResult
    ): Bool {
        match ((this, right)) {
            case (Pending,  Pending)  => true
            case (Approved, Approved) => true
            case (Rejected, Rejected) => true
            case _ => false
        }
    }

    public operator func !=(
        right: ReviewResult
    ): Bool {
        return !(this == right)
    }
}

public class ReviewRecord {
    public var id: Int64
    public let targetType: String
    public let targetId: Int64
    public let reviewerId: Int64
    public let result: ReviewResult
    public let reason: String
    public let reviewedAt: String

    public init(
        id: Int64,
        targetType: String,
        targetId: Int64,
        reviewerId: Int64,
        result: ReviewResult,
        reason: String,
        reviewedAt: String
    ) {
        this.id         = id
        this.targetType = targetType
        this.targetId   = targetId
        this.reviewerId = reviewerId
        this.result     = result
        this.reason     = reason
        this.reviewedAt = reviewedAt
    }

    public func toString(): String {
        return "ReviewRecord{id=${id}" +
            ", target=${targetType}" +
            ", result=${result}}"
    }
}
