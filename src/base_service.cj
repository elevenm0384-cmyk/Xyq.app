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
        email: String
    ): ApiResponse<String> {
        if (userRepo.existsByUsername(
            username
        )) {
            return ApiResponse<String>.fail(
                ErrorCode.UserAlreadyExists
            )
        }
        let u = User(
            0, username, password,
            email, Role.Student
        )
        userRepo.save(u)
        return ApiResponse<String>.ok("注册成功")
    }

    public func login(
        username: String,
        password: String
    ): ApiResponse<String> {
        match (userRepo.findByUsername(
            username
        )) {
            case None =>
                return ApiResponse<String>.fail(
                    ErrorCode.UserNotFound
                )
            case Some(u) =>
                if (u.password != password) {
                    return ApiResponse<String>
                        .fail(
                            ErrorCode.WrongPassword
                        )
                }
                let token =
                    sessions.createToken(u.id)
                return ApiResponse<String>
                    .ok(token)
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
                        return ApiResponse<User>
                            .ok(u)
                    case None =>
                        return ApiResponse<User>
                            .fail(
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

    public func listRoots()
        : ApiResponse<ArrayList<Category>>
    {
        return ApiResponse<
            ArrayList<Category>
        >.ok(catRepo.findRoots())
    }

    public func findById(
        id: Int64
    ): ApiResponse<Category> {
        match (catRepo.findById(id)) {
            case Some(c) =>
                return ApiResponse<Category>
                    .ok(c)
            case None =>
                return ApiResponse<Category>
                    .fail(
                        ErrorCode.CategoryNotFound
                    )
        }
    }
}

// ===== ItemBaseService =====
public class ItemBaseService {
    private let itemRepo: ItemRepository
    private let sessions: SessionManager

    private static var inst:
        Option<ItemBaseService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
        sessions =
            SessionManager.getInstance()
    }

    public static func getInstance()
        : ItemBaseService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = ItemBaseService()
                inst = Some(s)
                return s
        }
    }

    public func publish(
        token: String,
        req: PublishItemReq
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                let item = BaseItem(
                    0,
                    req.title,
                    req.description,
                    req.categoryId,
                    uid,
                    req.itemType,
                    ItemStatus.Pending,
                    req.imageUrl,
                    req.contactInfo
                )
                return ApiResponse<BaseItem>
                    .ok(itemRepo.save(item))
        }
    }

    public func getById(
        id: Int64
    ): ApiResponse<BaseItem> {
        match (itemRepo.findById(id)) {
            case Some(item) =>
                return ApiResponse<BaseItem>
                    .ok(item)
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.ItemNotFound)
        }
    }

    public func listPage(
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<BaseItem>> {
        let data =
            itemRepo.findPage(page, size)
        let total = itemRepo.count()
        let pr = PageResult<BaseItem>(
            total, page, size, data.toArray()
        )
        return ApiResponse<
            PageResult<BaseItem>
        >.ok(pr)
    }

    public func listByType(
        t: ItemType
    ): ApiResponse<ArrayList<BaseItem>> {
        return ApiResponse<
            ArrayList<BaseItem>
        >.ok(itemRepo.findByType(t))
    }

    public func close(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        match (sessions.getUserId(token)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.Unauthorized)
            case Some(uid) =>
                match (
                    itemRepo.findById(itemId)
                ) {
                    case None =>
                        return ApiResponse<
                            BaseItem
                        >.fail(
                            ErrorCode.ItemNotFound
                        )
                    case Some(item) =>
                        if (item.publisherId != uid) {
                            return ApiResponse<
                                BaseItem
                            >.fail(
                                ErrorCode.Forbidden
                            )
                        }
                        match (item.status) {
                            case ItemStatus
                                .Closed =>
                                return ApiResponse<
                                    BaseItem
                                >.fail(
                                    ErrorCode
                                    .ItemAlreadyClosed
                                )
                            case _ =>
                                item.status =
                                    ItemStatus
                                    .Closed
                                return ApiResponse<
                                    BaseItem
                                >.ok(
                                    itemRepo
                                    .save(item)
                                )
                        }
                }
        }
    }
}

// ===== AdminService =====
public class AdminService {
    private let itemRepo: ItemRepository
    private let userRepo: UserRepository
    private let sessions: SessionManager

    private static var inst:
        Option<AdminService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
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
                match (
                    userRepo.findById(uid)
                ) {
                    case None => return false
                    case Some(u) =>
                        match (u.role) {
                            case Role.Admin =>
                                return true
                            case _ =>
                                return false
                        }
                }
        }
    }

    public func approve(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        if (!checkAdmin(token)) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        return updateStatus(
            itemId, ItemStatus.Approved
        )
    }

    public func reject(
        token: String,
        itemId: Int64
    ): ApiResponse<BaseItem> {
        if (!checkAdmin(token)) {
            return ApiResponse<BaseItem>
                .fail(ErrorCode.Forbidden)
        }
        return updateStatus(
            itemId, ItemStatus.Rejected
        )
    }

    public func listPending(
        token: String,
        page: Int64,
        size: Int64
    ): ApiResponse<PageResult<BaseItem>> {
        if (!checkAdmin(token)) {
            return ApiResponse<
                PageResult<BaseItem>
            >.fail(ErrorCode.Forbidden)
        }
        let all = itemRepo.findByStatus(
            ItemStatus.Pending
        )
        let total = Int64(all.size)
        let from = (page - 1) * size
        let result = ArrayList<BaseItem>()
        var i = from
        while (
            i < from + size &&
            i < Int64(all.size)
        ) {
            result.add(all[i])
            i++
        }
        let pr = PageResult<BaseItem>(
            total, page, size,
            result.toArray()
        )
        return ApiResponse<
            PageResult<BaseItem>
        >.ok(pr)
    }

    public func listUsers(
        token: String
    ): ApiResponse<ArrayList<User>> {
        if (!checkAdmin(token)) {
            return ApiResponse<
                ArrayList<User>
            >.fail(ErrorCode.Forbidden)
        }
        return ApiResponse<
            ArrayList<User>
        >.ok(userRepo.findAll())
    }

    private func updateStatus(
        itemId: Int64,
        newStatus: ItemStatus
    ): ApiResponse<BaseItem> {
        match (itemRepo.findById(itemId)) {
            case None =>
                return ApiResponse<BaseItem>
                    .fail(ErrorCode.ItemNotFound)
            case Some(item) =>
                item.status = newStatus
                return ApiResponse<BaseItem>
                    .ok(itemRepo.save(item))
        }
    }
}
