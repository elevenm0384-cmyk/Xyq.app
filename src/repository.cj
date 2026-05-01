package cangjie

import std.collection.*
import std.random.*

// ===== SessionManager =====
public class SessionManager {
    private var tokenMap:
        HashMap<String, Int64> =
        HashMap<String, Int64>()

    private static var inst:
        Option<SessionManager> = None

    private init() {}

    public static func getInstance()
        : SessionManager
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = SessionManager()
                inst = Some(s)
                return s
        }
    }

    public func createToken(
        userId: Int64
    ): String {
        let r = Random()
        let token = "${r.nextInt64()}" +
            "${r.nextInt64()}"
        tokenMap.add(token, userId)
        return token
    }

    public func getUserId(
        token: String
    ): Option<Int64> {
        return tokenMap.get(token)
    }

    public func invalidate(
        token: String
    ): Unit {
        tokenMap.remove(token)
    }
}

// ===== UserRepository =====
public class UserRepository {
    private var store:
        HashMap<Int64, User> =
        HashMap<Int64, User>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<UserRepository> = None

    private init() {}

    public static func getInstance()
        : UserRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = UserRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(u: User): User {
        if (u.id == 0) {
            u.id = nextId
            nextId++
        }
        store.add(u.id, u)
        return u
    }

    public func findById(
        id: Int64
    ): Option<User> {
        return store.get(id)
    }

    public func findByUsername(
        name: String
    ): Option<User> {
        for ((_, u) in store) {
            if (u.username == name) {
                return Some(u)
            }
        }
        return None
    }

    public func existsByUsername(
        name: String
    ): Bool {
        match (findByUsername(name)) {
            case Some(_) => return true
            case None    => return false
        }
    }

    public func findAll(): ArrayList<User> {
        let list = ArrayList<User>()
        for ((_, u) in store) {
            list.add(u)
        }
        return list
    }

    public func count(): Int64 {
        return Int64(store.size)
    }
}

// ===== PostRepository =====
public class PostRepository {
    private var store:
        HashMap<Int64, Post> =
        HashMap<Int64, Post>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<PostRepository> = None

    private init() {}

    public static func getInstance()
        : PostRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = PostRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(post: Post): Post {
        if (post.id == 0) {
            post.id = nextId
            nextId++
        }
        store.add(post.id, post)
        return post
    }

    public func findById(
        id: Int64
    ): Option<Post> {
        return store.get(id)
    }

    public func findAll()
        : ArrayList<Post>
    {
        let list = ArrayList<Post>()
        for ((_, post) in store) {
            if (!post.isDeleted) {
                list.add(post)
            }
        }
        return list
    }

    public func findByType(
        t: BusinessType
    ): ArrayList<Post> {
        let list = ArrayList<Post>()
        for ((_, post) in store) {
            if (post.businessType == t &&
                !post.isDeleted) {
                list.add(post)
            }
        }
        return list
    }

    public func findByAuthor(
        authorId: Int64
    ): ArrayList<Post> {
        let list = ArrayList<Post>()
        for ((_, post) in store) {
            if (post.authorId == authorId &&
                !post.isDeleted) {
                list.add(post)
            }
        }
        return list
    }

    public func findByAuditStatus(
        s: AuditStatus
    ): ArrayList<Post> {
        let list = ArrayList<Post>()
        for ((_, post) in store) {
            if (post.auditStatus == s &&
                !post.isDeleted) {
                list.add(post)
            }
        }
        return list
    }

    public func count(): Int64 {
        var c: Int64 = 0
        for ((_, post) in store) {
            if (!post.isDeleted) { c++ }
        }
        return c
    }

    public func findPage(
        page: Int64,
        size: Int64
    ): ArrayList<Post> {
        let all = findAll()
        let from = (page - 1) * size
        let result = ArrayList<Post>()
        var i = from
        while (i < from + size &&
            i < Int64(all.size)) {
            result.add(all[i])
            i++
        }
        return result
    }
}

// ===== CategoryRepository =====
public class CategoryRepository {
    private var store:
        HashMap<Int64, Category> =
        HashMap<Int64, Category>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<CategoryRepository> = None

    private init() {
        initDefaults()
    }

    public static func getInstance()
        : CategoryRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = CategoryRepository()
                inst = Some(r)
                return r
        }
    }

    private func initDefaults(): Unit {
        let defs = [
            ("教材书籍", SceneType.SECONDHAND, 1),
            ("数码电器", SceneType.SECONDHAND, 2),
            ("生活用品", SceneType.ALL, 3),
            ("运动户外", SceneType.ALL, 4),
            ("校园卡/证件", SceneType.LOST, 5),
            ("其他物品", SceneType.ALL, 6)
        ]
        for ((name, scene, order) in defs) {
            let c = Category(
                nextId, name, None,
                scene, Int64(order), true
            )
            store.add(nextId, c)
            nextId++
        }
    }

    public func save(c: Category): Category {
        if (c.id == 0) {
            c.id = nextId
            nextId++
        }
        store.add(c.id, c)
        return c
    }

    public func findById(
        id: Int64
    ): Option<Category> {
        return store.get(id)
    }

    public func findAll()
        : ArrayList<Category>
    {
        let list = ArrayList<Category>()
        for ((_, c) in store) {
            if (c.isEnabled) {
                list.add(c)
            }
        }
        return list
    }

    public func findByScene(
        scene: SceneType
    ): ArrayList<Category> {
        let list = ArrayList<Category>()
        for ((_, c) in store) {
            if (c.isEnabled &&
                (c.sceneType == scene ||
                 c.sceneType == SceneType.ALL)) {
                list.add(c)
            }
        }
        return list
    }
}

// ===== RequestRepository =====
public class RequestRepository {
    private var store:
        HashMap<Int64, Request> =
        HashMap<Int64, Request>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<RequestRepository> = None

    private init() {}

    public static func getInstance()
        : RequestRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = RequestRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(req: Request): Request {
        if (req.id == 0) {
            req.id = nextId
            nextId++
        }
        store.add(req.id, req)
        return req
    }

    public func findById(
        id: Int64
    ): Option<Request> {
        return store.get(id)
    }

    public func findByPost(
        postId: Int64
    ): ArrayList<Request> {
        let list = ArrayList<Request>()
        for ((_, r) in store) {
            if (r.postId == postId) {
                list.add(r)
            }
        }
        return list
    }

    public func countByPost(
        postId: Int64
    ): Int64 {
        var c: Int64 = 0
        for ((_, r) in store) {
            if (r.postId == postId) { c++ }
        }
        return c
    }
}

// ===== MockDataInit =====
public func mockDataInit(): Unit {
    let userRepo =
        UserRepository.getInstance()
    let postRepo =
        PostRepository.getInstance()

    // 管理员
    let admin = User(
        0, "admin", "admin123",
        "管理员", "", "",
        Role.Admin
    )
    userRepo.save(admin)

    // 普通用户
    let alice = User(
        0, "alice", "pass123",
        "Alice", "", "13800001111",
        Role.User
    )
    userRepo.save(alice)

    let bob = User(
        0, "bob", "pass123",
        "Bob", "", "13800002222",
        Role.User
    )
    userRepo.save(bob)

    // 二手商品
    let shItems = [
        ("高数教材全套", "九成新，几乎没划线", 1,
         Some(25.0), "学院路校区"),
        ("蓝牙耳机", "AirPods Pro 二代", 2,
         Some(800.0), "沙河校区"),
        ("羽毛球拍", "双拍套装，送羽毛球", 4,
         Some(120.0), "学院路校区"),
        ("台灯", "护眼LED台灯，三档调光", 3,
         Some(45.0), "沙河校区")
    ]
    for ((title, desc, catId, price, loc) in shItems) {
        let post = Post(
            0, alice.id, Int64(catId),
            BusinessType.SecondHand,
            title, desc, price, loc,
            "[]", "微信: alice_sell"
        )
        post.auditStatus = AuditStatus.APPROVED
        post.bizStatus = BizStatus.ON_SALE
        postRepo.save(post)
    }

    // 失物
    let lostItems = [
        ("黑色钱包", "图书馆3楼捡到", 5, "学院路校区"),
        ("学生证", "姓名：张三，学号2024xxxx", 5, "沙河校区")
    ]
    for ((title, desc, catId, loc) in lostItems) {
        let post = Post(
            0, bob.id, Int64(catId),
            BusinessType.LOST,
            title, desc, None, loc,
            "[]", "联系: bob_lost"
        )
        post.auditStatus = AuditStatus.APPROVED
        post.bizStatus = BizStatus.OPEN
        postRepo.save(post)
    }

    // 招领
    let foundItems = [
        ("充电宝", "小米20000mAh，食堂门口捡到", 6, "沙河校区")
    ]
    for ((title, desc, catId, loc) in foundItems) {
        let post = Post(
            0, alice.id, Int64(catId),
            BusinessType.FOUND,
            title, desc, None, loc,
            "[]", "联系: alice_found"
        )
        post.auditStatus = AuditStatus.APPROVED
        post.bizStatus = BizStatus.OPEN
        postRepo.save(post)
    }
}
