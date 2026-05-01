package cangjie

import std.collection.*
import std.time.*

// ================================================
//  TradeService — 二手交易（基于 Request 流程）
//  流程: 发起BUY申请 → 卖家ACCEPT →
//        post→RESERVED → DONE → post→SOLD
// ================================================
public class TradeService {
    private let postRepo: PostRepository
    private let reqRepo: RequestRepository
    private let sessions: SessionManager

    private static var inst:
        Option<TradeService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
        reqRepo =
            RequestRepository.getInstance()
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

    // 发起购买申请
    public func requestBuy(
        token: String,
        postId: Int64,
        note: String
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (postRepo.findById(postId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.PostNotFound
                        )
                    case Some(post) =>
                        return doRequestBuy(post, uid, note)
                }
        }
    }

    private func doRequestBuy(
        post: Post,
        uid: Int64,
        note: String
    ): ApiResponse<Request> {
        if (post.isDeleted) {
            return ApiResponse<Request>.fail(
                ErrorCode.PostNotFound
            )
        }
        if (post.businessType !=
            BusinessType.SecondHand) {
            return ApiResponse<Request>.fail(
                ErrorCode.PostNotAvailable
            )
        }
        if (post.bizStatus != BizStatus.ON_SALE) {
            return ApiResponse<Request>.fail(
                ErrorCode.PostNotAvailable
            )
        }
        if (post.authorId == uid) {
            return ApiResponse<Request>.fail(
                ErrorCode.CannotBuyOwn
            )
        }
        let req = Request(
            0, post.id, uid,
            RequestType.BUY, note,
            DateTime.now().toString()
        )
        return ApiResponse<Request>.ok(
            reqRepo.save(req)
        )
    }

    // 卖家接受申请 → post→RESERVED
    public func acceptRequest(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        return doAccept(req, uid)
                }
        }
    }

    private func doAccept(
        req: Request,
        uid: Int64
    ): ApiResponse<Request> {
        match (postRepo.findById(req.postId)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.PostNotFound
                )
            case Some(post) =>
                if (post.authorId != uid) {
                    return ApiResponse<Request>.fail(
                        ErrorCode.Forbidden
                    )
                }
                if (post.bizStatus != BizStatus.ON_SALE) {
                    return ApiResponse<Request>.fail(
                        ErrorCode.PostNotAvailable
                    )
                }
                if (req.status != RequestStatus.PENDING) {
                    return ApiResponse<Request>.fail(
                        ErrorCode.InvalidTransition
                    )
                }
                req.status = RequestStatus.ACCEPTED
                req.updatedAt =
                    DateTime.now().toString()
                post.bizStatus = BizStatus.RESERVED
                postRepo.save(post)
                return ApiResponse<Request>.ok(
                    reqRepo.save(req)
                )
        }
    }

    // 拒绝申请
    public func rejectRequest(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        match (postRepo.findById(req.postId)) {
                            case Some(post) =>
                                if (post.authorId != uid) {
                                    return ApiResponse<Request>
                                        .fail(ErrorCode.Forbidden)
                                }
                            case None => ()
                        }
                        if (req.status !=
                            RequestStatus.PENDING) {
                            return ApiResponse<Request>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        req.status = RequestStatus.REJECTED
                        return ApiResponse<Request>.ok(
                            reqRepo.save(req)
                        )
                }
        }
    }

    // 取消申请
    public func cancelRequest(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        if (req.requesterId != uid) {
                            return ApiResponse<Request>.fail(
                                ErrorCode.Forbidden
                            )
                        }
                        if (req.status !=
                            RequestStatus.PENDING) {
                            return ApiResponse<Request>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        req.status = RequestStatus.CANCELLED
                        return ApiResponse<Request>.ok(
                            reqRepo.save(req)
                        )
                }
        }
    }

    // 完成交易 → post→SOLD
    public func doneRequest(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        match (postRepo.findById(req.postId)) {
                            case Some(post) =>
                                if (post.authorId != uid) {
                                    return ApiResponse<Request>
                                        .fail(ErrorCode.Forbidden)
                                }
                            case None => ()
                        }
                        if (req.status !=
                            RequestStatus.ACCEPTED) {
                            return ApiResponse<Request>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        req.status = RequestStatus.DONE
                        req.updatedAt =
                            DateTime.now().toString()
                        match (postRepo.findById(req.postId)) {
                            case Some(post) =>
                                post.bizStatus = BizStatus.SOLD
                                postRepo.save(post)
                            case None => ()
                        }
                        return ApiResponse<Request>.ok(
                            reqRepo.save(req)
                        )
                }
        }
    }

    // 获取某个 post 的申请列表
    public func listRequests(
        token: String,
        postId: Int64
    ): ApiResponse<ArrayList<Request>> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<ArrayList<Request>>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (postRepo.findById(postId)) {
                    case Some(post) =>
                        if (post.authorId != uid) {
                            // 管理员也可查看
                            ()
                        }
                    case None => ()
                }
                return ApiResponse<ArrayList<Request>>
                    .ok(reqRepo.findByPost(postId))
        }
    }
}

// ================================================
//  ClaimService — 失物认领（基于 Request 流程）
//  流程: 发起CLAIM申请 → 发布者ACCEPT →
//        post→MATCHING → DONE → post→CLAIMED
// ================================================
public class ClaimService {
    private let postRepo: PostRepository
    private let reqRepo: RequestRepository
    private let sessions: SessionManager

    private static var inst:
        Option<ClaimService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
        reqRepo =
            RequestRepository.getInstance()
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

    // 发起认领申请
    public func requestClaim(
        token: String,
        postId: Int64,
        note: String
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (postRepo.findById(postId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.PostNotFound
                        )
                    case Some(post) =>
                        return doRequestClaim(post, uid, note)
                }
        }
    }

    private func doRequestClaim(
        post: Post,
        uid: Int64,
        note: String
    ): ApiResponse<Request> {
        if (post.isDeleted) {
            return ApiResponse<Request>.fail(
                ErrorCode.PostNotFound
            )
        }
        let bt = post.businessType
        if (bt != BusinessType.LOST &&
            bt != BusinessType.FOUND) {
            return ApiResponse<Request>.fail(
                ErrorCode.PostNotAvailable
            )
        }
        if (post.bizStatus != BizStatus.OPEN) {
            return ApiResponse<Request>.fail(
                ErrorCode.PostNotAvailable
            )
        }
        if (post.authorId == uid) {
            return ApiResponse<Request>.fail(
                ErrorCode.CannotClaimOwn
            )
        }
        let req = Request(
            0, post.id, uid,
            RequestType.CLAIM, note,
            DateTime.now().toString()
        )
        return ApiResponse<Request>.ok(
            reqRepo.save(req)
        )
    }

    // 发布者接受认领 → post→MATCHING
    public func acceptClaim(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        return doAcceptClaim(req, uid)
                }
        }
    }

    private func doAcceptClaim(
        req: Request,
        uid: Int64
    ): ApiResponse<Request> {
        match (postRepo.findById(req.postId)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.PostNotFound
                )
            case Some(post) =>
                if (post.authorId != uid) {
                    return ApiResponse<Request>.fail(
                        ErrorCode.Forbidden
                    )
                }
                if (post.bizStatus != BizStatus.OPEN) {
                    return ApiResponse<Request>.fail(
                        ErrorCode.PostNotAvailable
                    )
                }
                if (req.status != RequestStatus.PENDING) {
                    return ApiResponse<Request>.fail(
                        ErrorCode.InvalidTransition
                    )
                }
                req.status = RequestStatus.ACCEPTED
                req.updatedAt =
                    DateTime.now().toString()
                post.bizStatus = BizStatus.MATCHING
                postRepo.save(post)
                return ApiResponse<Request>.ok(
                    reqRepo.save(req)
                )
        }
    }

    // 拒绝认领
    public func rejectClaim(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        match (postRepo.findById(req.postId)) {
                            case Some(post) =>
                                if (post.authorId != uid) {
                                    return ApiResponse<Request>
                                        .fail(ErrorCode.Forbidden)
                                }
                            case None => ()
                        }
                        if (req.status !=
                            RequestStatus.PENDING) {
                            return ApiResponse<Request>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        req.status = RequestStatus.REJECTED
                        return ApiResponse<Request>.ok(
                            reqRepo.save(req)
                        )
                }
        }
    }

    // 完成认领 → post→CLAIMED
    public func doneClaim(
        token: String,
        requestId: Int64
    ): ApiResponse<Request> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Request>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (reqRepo.findById(requestId)) {
                    case None =>
                        return ApiResponse<Request>.fail(
                            ErrorCode.RequestNotFound
                        )
                    case Some(req) =>
                        match (postRepo.findById(req.postId)) {
                            case Some(post) =>
                                if (post.authorId != uid) {
                                    return ApiResponse<Request>
                                        .fail(ErrorCode.Forbidden)
                                }
                            case None => ()
                        }
                        if (req.status !=
                            RequestStatus.ACCEPTED) {
                            return ApiResponse<Request>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        req.status = RequestStatus.DONE
                        req.updatedAt =
                            DateTime.now().toString()
                        match (postRepo.findById(req.postId)) {
                            case Some(post) =>
                                post.bizStatus = BizStatus.CLAIMED
                                postRepo.save(post)
                            case None => ()
                        }
                        return ApiResponse<Request>.ok(
                            reqRepo.save(req)
                        )
                }
        }
    }
}

// ================================================
//  EnhancedAdminService — 增强审核（带审核记录）
// ================================================
public class EnhancedAdminService {
    private let postRepo: PostRepository
    private let userRepo: UserRepository
    private let auditRepo: AuditRepository
    private let sessions: SessionManager

    private static var inst:
        Option<EnhancedAdminService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
        userRepo =
            UserRepository.getInstance()
        auditRepo =
            AuditRepository.getInstance()
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

    // 审核通过 → audit_status=APPROVED, 写入记录
    public func approveWithRecord(
        token: String,
        postId: Int64
    ): ApiResponse<Post> {
        if (!isAdmin(token)) {
            return ApiResponse<Post>.fail(
                ErrorCode.Forbidden
            )
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Post>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(auditorId) =>
                match (postRepo.findById(postId)) {
                    case None =>
                        return ApiResponse<Post>.fail(
                            ErrorCode.PostNotFound
                        )
                    case Some(post) =>
                        if (post.auditStatus !=
                            AuditStatus.PENDING) {
                            return ApiResponse<Post>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        post.auditStatus =
                            AuditStatus.APPROVED
                        // 审核通过后赋正式业务状态
                        match (post.businessType) {
                            case BusinessType.SecondHand =>
                                post.bizStatus = BizStatus.ON_SALE
                            case _ =>
                                post.bizStatus = BizStatus.OPEN
                        }
                        let nowStr =
                            DateTime.now().toString()
                        auditRepo.save(AuditRecord(
                            0, postId, auditorId,
                            AuditStatus.APPROVED,
                            "", nowStr
                        ))
                        return ApiResponse<Post>.ok(
                            postRepo.save(post)
                        )
                }
        }
    }

    // 审核驳回 → 必须填写原因
    public func rejectWithRecord(
        token: String,
        postId: Int64,
        reason: String
    ): ApiResponse<Post> {
        if (!isAdmin(token)) {
            return ApiResponse<Post>.fail(
                ErrorCode.Forbidden
            )
        }
        if (reason.isEmpty()) {
            return ApiResponse<Post>.fail(
                ErrorCode.BadRequest
            )
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Post>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(auditorId) =>
                match (postRepo.findById(postId)) {
                    case None =>
                        return ApiResponse<Post>.fail(
                            ErrorCode.PostNotFound
                        )
                    case Some(post) =>
                        if (post.auditStatus !=
                            AuditStatus.PENDING) {
                            return ApiResponse<Post>.fail(
                                ErrorCode.InvalidTransition
                            )
                        }
                        post.auditStatus =
                            AuditStatus.REJECTED
                        let nowStr =
                            DateTime.now().toString()
                        auditRepo.save(AuditRecord(
                            0, postId, auditorId,
                            AuditStatus.REJECTED,
                            reason, nowStr
                        ))
                        return ApiResponse<Post>.ok(
                            postRepo.save(post)
                        )
                }
        }
    }

    // 获取审核历史
    public func getAuditHistory(
        token: String,
        postId: Int64
    ): ApiResponse<ArrayList<AuditRecord>> {
        if (!isAdmin(token)) {
            return ApiResponse<
                ArrayList<AuditRecord>
            >.fail(ErrorCode.Forbidden)
        }
        return ApiResponse<
            ArrayList<AuditRecord>
        >.ok(auditRepo.findByPost(postId))
    }
}

// ================================================
//  MessageService — 留言 / 私信
// ================================================
public class MessageService {
    private let msgRepo: MessageRepository
    private let postRepo: PostRepository
    private let sessions: SessionManager

    private static var inst:
        Option<MessageService> = None

    private init() {
        msgRepo =
            MessageRepository.getInstance()
        postRepo =
            PostRepository.getInstance()
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

    // 发表公开留言
    public func postComment(
        token: String,
        postId: Int64,
        content: String,
        parentId: Option<Int64>
    ): ApiResponse<Message> {
        if (content.isEmpty()) {
            return ApiResponse<Message>.fail(
                ErrorCode.BadRequest
            )
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Message>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (postRepo.findById(postId)) {
                    case None =>
                        return ApiResponse<Message>.fail(
                            ErrorCode.PostNotFound
                        )
                    case Some(p) =>
                        if (p.isDeleted) {
                            return ApiResponse<Message>
                                .fail(ErrorCode.PostNotFound)
                        }
                        if (p.auditStatus !=
                            AuditStatus.APPROVED) {
                            return ApiResponse<Message>
                                .fail(ErrorCode.PostNotAvailable)
                        }
                        let msg = Message(
                            0, Some(postId),
                            uid, None,
                            MessageType.PUBLIC_COMMENT,
                            content, parentId,
                            DateTime.now().toString()
                        )
                        return ApiResponse<Message>.ok(
                            msgRepo.save(msg)
                        )
                }
        }
    }

    // 发送私信
    public func sendPrivateMsg(
        token: String,
        toUserId: Int64,
        postId: Option<Int64>,
        content: String
    ): ApiResponse<Message> {
        if (content.isEmpty()) {
            return ApiResponse<Message>.fail(
                ErrorCode.BadRequest
            )
        }
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Message>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                if (uid == toUserId) {
                    return ApiResponse<Message>.fail(
                        ErrorCode.BadRequest
                    )
                }
                let msg = Message(
                    0, postId,
                    uid, Some(toUserId),
                    MessageType.PRIVATE_MESSAGE,
                    content, None,
                    DateTime.now().toString()
                )
                return ApiResponse<Message>.ok(
                    msgRepo.save(msg)
                )
        }
    }

    // 获取留言列表
    public func getComments(
        postId: Int64,
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<Message>> {
        let list = msgRepo.findByPost(
            postId, page, size
        )
        let total = msgRepo.countByPost(postId)
        let pr = PageResult<Message>(
            total, page, size, list.toArray()
        )
        return ApiResponse<PageResult<Message>>
            .ok(pr)
    }

    // 获取我的消息列表
    public func getMyMessages(
        token: String,
        msgType: Option<MessageType>,
        isRead: Option<Bool>,
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<Message>> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<PageResult<Message>>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                let list = msgRepo.findByUser(
                    uid, msgType, isRead, page, size
                )
                let pr = PageResult<Message>(
                    Int64(list.size), page, size,
                    list.toArray()
                )
                return ApiResponse<
                    PageResult<Message>
                >.ok(pr)
        }
    }

    // 获取未读私信数
    public func getUnreadCount(
        token: String
    ): ApiResponse<Int64> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Int64>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                return ApiResponse<Int64>.ok(
                    msgRepo.countUnread(uid)
                )
        }
    }

    // 标记已读
    public func markRead(
        token: String,
        msgId: Int64
    ): ApiResponse<Unit> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Unit>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(_) =>
                if (msgRepo.markRead(msgId)) {
                    return ApiResponse<Unit>.okEmpty()
                }
                return ApiResponse<Unit>.fail(
                    ErrorCode.MessageNotFound
                )
        }
    }
}
