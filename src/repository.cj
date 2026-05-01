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
}

// ===== ItemRepository =====
public class ItemRepository {
    private var store:
        HashMap<Int64, BaseItem> =
        HashMap<Int64, BaseItem>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<ItemRepository> = None

    private init() {}

    public static func getInstance()
        : ItemRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = ItemRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(
        item: BaseItem
    ): BaseItem {
        if (item.id == 0) {
            item.id = nextId
            nextId++
        }
        store.add(item.id, item)
        return item
    }

    public func findById(
        id: Int64
    ): Option<BaseItem> {
        return store.get(id)
    }

    public func findAll()
        : ArrayList<BaseItem>
    {
        let list = ArrayList<BaseItem>()
        for ((_, item) in store) {
            list.add(item)
        }
        return list
    }

    public func findByType(
        t: ItemType
    ): ArrayList<BaseItem> {
        let list = ArrayList<BaseItem>()
        for ((_, item) in store) {
            if (item.itemType == t) {
                list.add(item)
            }
        }
        return list
    }

    public func findByStatus(
        s: ItemStatus
    ): ArrayList<BaseItem> {
        let list = ArrayList<BaseItem>()
        for ((_, item) in store) {
            if (item.status == s) {
                list.add(item)
            }
        }
        return list
    }

    public func count(): Int64 {
        return Int64(store.size)
    }

    public func findPage(
        page: Int64,
        size: Int64
    ): ArrayList<BaseItem> {
        let all = findAll()
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
        let names = [
            "教材书籍",
            "数码电器",
            "生活用品",
            "运动户外",
            "失物招领"
        ]
        for (name in names) {
            let c = Category(
                nextId, name, None
            )
            store.add(nextId, c)
            nextId++
        }
    }

    public func save(
        c: Category
    ): Category {
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
            list.add(c)
        }
        return list
    }

    public func findRoots()
        : ArrayList<Category>
    {
        let list = ArrayList<Category>()
        for ((_, c) in store) {
            match (c.parentId) {
                case None => list.add(c)
                case _    => ()
            }
        }
        return list
    }
}

// ===== MockDataInit =====
public func mockDataInit(): Unit {
    let userRepo =
        UserRepository.getInstance()
    let itemRepo =
        ItemRepository.getInstance()

    // 初始化管理员账号
    let admin = User(
        0, "admin", "admin123",
        "admin@campus.edu", Role.Admin
    )
    userRepo.save(admin)

    // 初始化普通用户
    let alice = User(
        0, "alice", "pass123",
        "alice@campus.edu", Role.Student
    )
    userRepo.save(alice)

    let bob = User(
        0, "bob", "pass123",
        "bob@campus.edu", Role.Student
    )
    userRepo.save(bob)

    // 初始化二手物品
    let items = [
        ("高数教材全套", "九成新", 1,
         ItemType.SecondHand),
        ("蓝牙耳机", "AirPods Pro", 2,
         ItemType.SecondHand),
        ("羽毛球拍", "双拍套装", 4,
         ItemType.SecondHand),
        ("英语四级词汇书", "有笔记", 1,
         ItemType.SecondHand),
        ("台灯", "护眼LED", 3,
         ItemType.SecondHand)
    ]
    for ((title, desc, catId, t) in items) {
        let item = BaseItem(
            0, title, desc,
            Int64(catId), alice.id,
            t, ItemStatus.Approved,
            "", "微信: alice_sell"
        )
        itemRepo.save(item)
    }

    // 初始化失物招领
    let losts = [
        ("黑色钱包", "图书馆3楼捡到"),
        ("学生证", "姓名：张三"),
        ("充电宝", "小米20000mAh")
    ]
    for ((title, desc) in losts) {
        let item = BaseItem(
            0, title, desc,
            5, bob.id,
            ItemType.LostFound,
            ItemStatus.Approved,
            "", "联系: bob_lost"
        )
        itemRepo.save(item)
    }
}
