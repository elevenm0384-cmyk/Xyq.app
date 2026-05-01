package cangjie

import std.collection.*

// ===== AuthService =====
public class AuthService {
    private let userRepo: UserRepository
    private let sessions: SessionManager

    private static var inst:
        Option<AuthService> = None

    private init() {
        userRepo =
            UserRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : AuthService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = AuthService()
                inst = Some(s)
                return s
        }
    }

    public func register(
        username: String,
        password: String,
        nickname: String,
        phone: String
    ): ApiResponse<String> {
        if (userRepo.existsByUsername(username)) {
            return ApiResponse<String>.fail(
                ErrorCode.UserAlreadyExists
            )
        }
        let u = User(
            0, username, password,
            nickname, "", phone, Role.User
        )
        userRepo.save(u)
        let token = sessions.createToken(u.id)
        return ApiResponse<String>.ok(token)
    }

    public func login(
        username: String,
        password: String
    ): ApiResponse<String> {
        match (userRepo.findByUsername(username)) {
            case None =>
                return ApiResponse<String>.fail(
                    ErrorCode.UserNotFound
                )
            case Some(u) =>
                if (u.password != password) {
                    return ApiResponse<String>.fail(
                        ErrorCode.WrongPassword
                    )
                }
                let token = sessions.createToken(u.id)
                return ApiResponse<String>.ok(token)
        }
    }

    public func logout(
        token: String
    ): ApiResponse<Unit> {
        sessions.invalidate(token)
        return ApiResponse<Unit>.okEmpty()
    }

    public func whoami(
        token: String
    ): ApiResponse<User> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<User>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (userRepo.findById(uid)) {
                    case Some(u) =>
                        return ApiResponse<User>.ok(u)
                    case None =>
                        return ApiResponse<User>.fail(
                            ErrorCode.UserNotFound
                        )
                }
        }
    }
}

// ===== CategoryService =====
public class CategoryService {
    private let catRepo: CategoryRepository

    private static var inst:
        Option<CategoryService> = None

    private init() {
        catRepo =
            CategoryRepository.getInstance()
    }

    public static func getInstance()
        : CategoryService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = CategoryService()
                inst = Some(s)
                return s
        }
    }

    public func listAll()
        : ApiResponse<ArrayList<Category>>
    {
        return ApiResponse<
            ArrayList<Category>
        >.ok(catRepo.findAll())
    }

    public func listByScene(
        scene: SceneType
    ): ApiResponse<ArrayList<Category>> {
        return ApiResponse<
            ArrayList<Category>
        >.ok(catRepo.findByScene(scene))
    }

    public func findById(
        id: Int64
    ): ApiResponse<Category> {
        match (catRepo.findById(id)) {
            case Some(c) =>
                return ApiResponse<Category>.ok(c)
            case None =>
                return ApiResponse<Category>.fail(
                    ErrorCode.CategoryNotFound
                )
        }
    }
}

// ===== PostBaseService =====
public class PostBaseService {
    private let postRepo: PostRepository
    private let sessions: SessionManager

    private static var inst:
        Option<PostBaseService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : PostBaseService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = PostBaseService()
                inst = Some(s)
                return s
        }
    }

    public func publish(
        token: String,
        req: PublishPostReq
    ): ApiResponse<Post> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Post>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                let post = Post(
                    0, uid,
                    req.categoryId,
                    req.businessType,
                    req.title,
                    req.description,
                    req.price,
                    req.location,
                    req.imageUrls,
                    req.contactInfo
                )
                // 初始 biz_status
                match (req.businessType) {
                    case BusinessType.SecondHand =>
                        post.bizStatus = BizStatus.ON_SALE
                    case _ =>
                        post.bizStatus = BizStatus.OPEN
                }
                return ApiResponse<Post>.ok(
                    postRepo.save(post)
                )
        }
    }

    public func getById(
        id: Int64
    ): ApiResponse<Post> {
        match (postRepo.findById(id)) {
            case Some(post) =>
                if (post.isDeleted) {
                    return ApiResponse<Post>.fail(
                        ErrorCode.PostNotFound
                    )
                }
                return ApiResponse<Post>.ok(post)
            case None =>
                return ApiResponse<Post>.fail(
                    ErrorCode.PostNotFound
                )
        }
    }

    public func listPage(
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<Post>> {
        let data = postRepo.findPage(page, size)
        let total = postRepo.count()
        let pr = PageResult<Post>(
            total, page, size, data.toArray()
        )
        return ApiResponse<PageResult<Post>>.ok(pr)
    }

    public func listByType(
        t: BusinessType
    ): ApiResponse<ArrayList<Post>> {
        return ApiResponse<ArrayList<Post>>.ok(
            postRepo.findByType(t)
        )
    }

    public func listMyPosts(
        token: String
    ): ApiResponse<ArrayList<Post>> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<ArrayList<Post>>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                return ApiResponse<ArrayList<Post>>
                    .ok(postRepo.findByAuthor(uid))
        }
    }

    public func close(
        token: String,
        postId: Int64
    ): ApiResponse<Post> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<Post>.fail(
                    ErrorCode.Unauthorized
                )
            case Some(uid) =>
                match (postRepo.findById(postId)) {
                    case None =>
                        return ApiResponse<Post>.fail(
                            ErrorCode.PostNotFound
                        )
                    case Some(post) =>
                        if (post.authorId != uid) {
                            return ApiResponse<Post>
                                .fail(ErrorCode.Forbidden)
                        }
                        if (post.bizStatus == BizStatus.CLOSED ||
                            post.bizStatus == BizStatus.SOLD ||
                            post.bizStatus == BizStatus.CLAIMED) {
                            return ApiResponse<Post>
                                .fail(ErrorCode.PostAlreadyClosed)
                        }
                        post.bizStatus = BizStatus.CLOSED
                        return ApiResponse<Post>.ok(
                            postRepo.save(post)
                        )
                }
        }
    }
}

// ===== AdminService =====
public class AdminService {
    private let postRepo: PostRepository
    private let userRepo: UserRepository
    private let sessions: SessionManager

    private static var inst:
        Option<AdminService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
        userRepo =
            UserRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : AdminService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = AdminService()
                inst = Some(s)
                return s
        }
    }

    private func checkAdmin(
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

    public func approve(
        token: String,
        postId: Int64
    ): ApiResponse<Post> {
        if (!checkAdmin(token)) {
            return ApiResponse<Post>.fail(
                ErrorCode.Forbidden
            )
        }
        return updateAuditStatus(
            postId, AuditStatus.APPROVED
        )
    }

    public func reject(
        token: String,
        postId: Int64
    ): ApiResponse<Post> {
        if (!checkAdmin(token)) {
            return ApiResponse<Post>.fail(
                ErrorCode.Forbidden
            )
        }
        return updateAuditStatus(
            postId, AuditStatus.REJECTED
        )
    }

    public func listPending(
        token: String,
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<Post>> {
        if (!checkAdmin(token)) {
            return ApiResponse<
                PageResult<Post>
            >.fail(ErrorCode.Forbidden)
        }
        let all = postRepo.findByAuditStatus(
            AuditStatus.PENDING
        )
        let total = Int64(all.size)
        let from = (page - 1) * size
        let result = ArrayList<Post>()
        var i = from
        while (i < from + size &&
            i < Int64(all.size)) {
            result.add(all[i])
            i++
        }
        let pr = PageResult<Post>(
            total, page, size, result.toArray()
        )
        return ApiResponse<PageResult<Post>>.ok(pr)
    }

    public func listUsers(
        token: String
    ): ApiResponse<ArrayList<User>> {
        if (!checkAdmin(token)) {
            return ApiResponse<ArrayList<User>>
                .fail(ErrorCode.Forbidden)
        }
        return ApiResponse<ArrayList<User>>.ok(
            userRepo.findAll()
        )
    }

    private func updateAuditStatus(
        postId: Int64,
        newStatus: AuditStatus
    ): ApiResponse<Post> {
        match (postRepo.findById(postId)) {
            case None =>
                return ApiResponse<Post>.fail(
                    ErrorCode.PostNotFound
                )
            case Some(post) =>
                post.auditStatus = newStatus
                return ApiResponse<Post>.ok(
                    postRepo.save(post)
                )
        }
    }
}
