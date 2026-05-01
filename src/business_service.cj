package cangjie

import std.collection.*
import std.time.*

// ================================================
//  TradeService — 二手交易状态机
//  状态: Idle → Reserved → Sold / Idle
//  约束: 只有 Approved 状态的二手商品可交易
// ================================================
public class TradeService {
    private let itemRepo: ItemRepository
    private let sessions: SessionManager

    private static var inst:
        Option<TradeService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : TradeService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = TradeService()
                inst = Some(s)
                return s
        }
    }

    // 买家发起交易
    public func reserve(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doReserve(item, uid)
                }
        }
    }

    private func doReserve(
        item: BaseItem,
        buyerId: Int64
    ): ApiResponse<BaseItem> {
        if (item.itemType != ItemType.SecondHand) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        if (item.status != ItemStatus.Approved) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        if (item.tradeStatus != TradeStatus.Idle) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.AlreadyReserved)
        }
        if (item.publisherId == buyerId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.CannotBuyOwn)
        }
        item.tradeStatus = TradeStatus.Reserved
        item.buyerId = Some(buyerId)
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 卖家确认交易完成
    public func completeTrade(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doComplete(item, uid)
                }
        }
    }

    private func doComplete(
        item: BaseItem,
        userId: Int64
    ): ApiResponse<BaseItem> {
        if (item.publisherId != userId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        if (item.tradeStatus != TradeStatus.Reserved) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.TradeNotFound)
        }
        item.tradeStatus = TradeStatus.Sold
        item.status = ItemStatus.Closed
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 取消交易（买家或卖家均可）
    public func cancelTrade(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doCancel(item, uid)
                }
        }
    }

    private func doCancel(
        item: BaseItem,
        userId: Int64
    ): ApiResponse<BaseItem> {
        if (item.tradeStatus != TradeStatus.Reserved) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.TradeNotFound)
        }
        let isSeller = item.publisherId == userId
        let isBuyer = match (item.buyerId) {
            case Some(bid) => bid == userId
            case None      => false
        }
        if (!isSeller && !isBuyer) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        item.tradeStatus = TradeStatus.Idle
        item.buyerId = None
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 卖家下架商品
    public func delist(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doDelist(item, uid)
                }
        }
    }

    private func doDelist(
        item: BaseItem,
        userId: Int64
    ): ApiResponse<BaseItem> {
        if (item.publisherId != userId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        if (item.status != ItemStatus.Approved) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        if (item.tradeStatus == TradeStatus.Reserved) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        item.status = ItemStatus.Closed
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 卖家重新上架
    public func relist(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doRelist(item, uid)
                }
        }
    }

    private func doRelist(
        item: BaseItem,
        userId: Int64
    ): ApiResponse<BaseItem> {
        if (item.publisherId != userId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        if (item.status != ItemStatus.Closed) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        if (item.tradeStatus == TradeStatus.Sold) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.InvalidTransition)
        }
        item.status = ItemStatus.Approved
        item.tradeStatus = TradeStatus.Idle
        item.buyerId = None
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }
}

// ================================================
//  ClaimService — 失物认领状态机
//  状态: Idle → Claimed → Returned / Idle
//  约束: 只有 Approved 状态的失物可被认领
// ================================================
public class ClaimService {
    private let itemRepo: ItemRepository
    private let sessions: SessionManager

    private static var inst:
        Option<ClaimService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : ClaimService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = ClaimService()
                inst = Some(s)
                return s
        }
    }

    // 发起认领
    public func claim(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doClaim(item, uid)
                }
        }
    }

    private func doClaim(
        item: BaseItem,
        claimerId: Int64
    ): ApiResponse<BaseItem> {
        if (item.itemType != ItemType.LostFound) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        if (item.status != ItemStatus.Approved) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.ItemNotAvailable)
        }
        if (item.claimStatus != ClaimStatus.Idle) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.AlreadyClaimed)
        }
        if (item.publisherId == claimerId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.CannotClaimOwn)
        }
        item.claimStatus = ClaimStatus.Claimed
        item.claimerId = Some(claimerId)
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 确认归还（发布者确认）
    public func confirmReturn(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doConfirm(item, uid)
                }
        }
    }

    private func doConfirm(
        item: BaseItem,
        userId: Int64
    ): ApiResponse<BaseItem> {
        if (item.publisherId != userId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        if (item.claimStatus != ClaimStatus.Claimed) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.TradeNotFound)
        }
        item.claimStatus = ClaimStatus.Returned
        item.status = ItemStatus.Closed
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 驳回认领（发布者或管理员）
    public func rejectClaim(
        token: String,
        itemId: Int64,
        isAdmin: Bool
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doReject(item, uid, isAdmin)
                }
        }
    }

    private func doReject(
        item: BaseItem,
        userId: Int64,
        isAdmin: Bool
    ): ApiResponse<BaseItem> {
        if (!isAdmin && item.publisherId != userId) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        if (item.claimStatus != ClaimStatus.Claimed) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.TradeNotFound)
        }
        item.claimStatus = ClaimStatus.Idle
        item.claimerId = None
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }

    // 认领者取消认领
    public func cancelClaim(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        return doCancelClaim(item, uid)
                }
        }
    }

    private func doCancelClaim(
        item: BaseItem,
        userId: Int64
    ): ApiResponse<BaseItem> {
        if (item.claimStatus != ClaimStatus.Claimed) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.TradeNotFound)
        }
        match (item.claimerId) {
            case Some(cid) =>
                if (cid != userId) {
                    return ApiResponse<BaseItem>
                        .fail(ErrorCode.Forbidden)
                }
            case None => ()
        }
        item.claimStatus = ClaimStatus.Idle
        item.claimerId = None
        return ApiResponse<BaseItem>
            .ok(itemRepo.save(item))
    }
}

// ================================================
//  EnhancedAdminService — 增强审核（带审核记录）
// ================================================
public class EnhancedAdminService {
    private let itemRepo: ItemRepository
    private let userRepo: UserRepository
    private let reviewRepo: ReviewRepository
    private let sessions: SessionManager

    private static var inst:
        Option<EnhancedAdminService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
        userRepo =
            UserRepository.getInstance()
        reviewRepo =
            ReviewRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : EnhancedAdminService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = EnhancedAdminService()
                inst = Some(s)
                return s
        }
    }

    private func isAdmin(
        token: String
    ): Bool {
        match (sessions.getUserId(token)) {
            case None => return false
            case Some(uid) =>
                match (userRepo.findById(uid)) {
                    case Some(u) =>
                        match (u.role) {
                            case Role.Admin => return true
                            case _ => return false
                        }
                    case None => return false
                }
        }
    }

    // 审核通过（写入审核记录）
    public func approveWithRecord(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        if (!isAdmin(token)) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(reviewerId) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        if (item.status != ItemStatus.Pending) {
                            return ApiResponse<BaseItem>
                                .fail(ErrorCode.InvalidTransition)
                        }
                        item.status = ItemStatus.Approved
                        // 写审核记录
                        let nowStr = currentTimeStr()
                        reviewRepo.save(ReviewRecord(
                            0, "item", itemId,
                            reviewerId, ReviewResult.Approved,
                            "", nowStr
                        ))
                        return ApiResponse<BaseItem>
                            .ok(itemRepo.save(item))
                }
        }
    }

    // 审核驳回（必须填写原因）
    public func rejectWithRecord(
        token: String,
        itemId: Int64,
        reason: String
    ): ApiResponse<BaseItem> {
        if (!isAdmin(token)) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        if (reason.isEmpty()) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.BadRequest)
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(reviewerId) =>
                match (itemRepo.findById(itemId)) {
                    case None =>
                        return ApiResponse<BaseItem>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(item) =>
                        if (item.status != ItemStatus.Pending) {
                            return ApiResponse<BaseItem>
                                .fail(ErrorCode.InvalidTransition)
                        }
                        item.status = ItemStatus.Rejected
                        let nowStr = currentTimeStr()
                        reviewRepo.save(ReviewRecord(
                            0, "item", itemId,
                            reviewerId, ReviewResult.Rejected,
                            reason, nowStr
                        ))
                        return ApiResponse<BaseItem>
                            .ok(itemRepo.save(item))
                }
        }
    }

    // 获取审核历史
    public func getReviewHistory(
        token: String,
        itemId: Int64
    ): ApiResponse<ArrayList<ReviewRecord>> {
        if (!isAdmin(token)) {
            return ApiResponse<
                ArrayList<ReviewRecord>
            >.fail(ErrorCode.Forbidden)
        }
        let records =
            reviewRepo.findByTarget("item", itemId)
        return ApiResponse<
            ArrayList<ReviewRecord>
        >.ok(records)
    }

    // 获取当前时间字符串
    private func currentTimeStr(): String {
        let now = DateTime.now()
        return now.toString()
    }
}

// ================================================
//  MessageService — 留言 / 站内信
// ================================================
public class MessageService {
    private let msgRepo: MessageRepository
    private let itemRepo: ItemRepository
    private let sessions: SessionManager

    private static var inst:
        Option<MessageService> = None

    private init() {
        msgRepo =
            MessageRepository.getInstance()
        itemRepo =
            ItemRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : MessageService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = MessageService()
                inst = Some(s)
                return s
        }
    }

    // 发表留言
    public func postComment(
        token: String,
        targetType: String,
        targetId: Int64,
        content: String
    ): ApiResponse<Message> {
        if (content.isEmpty()) {
            return ApiResponse<Message>
                .fail(ErrorCode.BadRequest)
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Message>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (itemRepo.findById(targetId)) {
                    case None =>
                        return ApiResponse<Message>
                            .fail(ErrorCode.ItemNotFound)
                    case Some(_) =>
                        let nowStr = DateTime.now()
                            .toString()
                        let msg = Message(
                            0, targetType, targetId,
                            uid, None,
                            MessageType.Comment,
                            content, None, nowStr
                        )
                        return ApiResponse<Message>
                            .ok(msgRepo.save(msg))
                }
        }
    }

    // 发送私信
    public func sendPrivateMsg(
        token: String,
        toUserId: Int64,
        targetType: String,
        targetId: Int64,
        content: String
    ): ApiResponse<Message> {
        if (content.isEmpty()) {
            return ApiResponse<Message>
                .fail(ErrorCode.BadRequest)
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Message>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                if (uid == toUserId) {
                    return ApiResponse<Message>
                        .fail(ErrorCode.BadRequest)
                }
                let nowStr = DateTime.now().toString()
                let msg = Message(
                    0, targetType, targetId,
                    uid, Some(toUserId),
                    MessageType.PrivateMsg,
                    content, None, nowStr
                )
                return ApiResponse<Message>
                    .ok(msgRepo.save(msg))
        }
    }

    // 获取留言列表
    public func getComments(
        targetType: String,
        targetId: Int64,
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<Message>> {
        let list = msgRepo.findByTarget(
            targetType, targetId, page, size
        )
        let total = msgRepo.countByTarget(
            targetType, targetId
        )
        let pr = PageResult<Message>(
            total, page, size, list.toArray()
        )
        return ApiResponse<PageResult<Message>>
            .ok(pr)
    }

    // 获取未读私信数
    public func getUnreadCount(
        token: String
    ): ApiResponse<Int64> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Int64>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                let c = msgRepo.countUnread(uid)
                return ApiResponse<Int64>.ok(c)
        }
    }

    // 标记已读
    public func markRead(
        token: String,
        msgId: Int64
    ): ApiResponse<Unit> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Unit>
                    .fail(ErrorCode.Unauthorized)
            case Some(_) =>
                let ok = msgRepo.markRead(msgId)
                if (ok) {
                    return ApiResponse<Unit>
                        .okEmpty()
                }
                return ApiResponse<Unit>
                    .fail(ErrorCode.MessageNotFound)
        }
    }

    // 删除留言
    public func deleteMessage(
        token: String,
        msgId: Int64
    ): ApiResponse<Unit> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Unit>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (msgRepo.findById(msgId)) {
                    case None =>
                        return ApiResponse<Unit>
                            .fail(ErrorCode.MessageNotFound)
                    case Some(msg) =>
                        if (msg.fromUserId != uid) {
                            return ApiResponse<Unit>
                                .fail(ErrorCode.Forbidden)
                        }
                        return ApiResponse<Unit>
                            .okEmpty()
                }
        }
    }
}
