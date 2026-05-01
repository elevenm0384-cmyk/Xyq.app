package ohos_app_cangjie_entry

// 后端测试用 - 内存数据库模拟
class UserRow {
    var id: Int64 = 0
    var username: String = ""
    var password_hash: String = ""
    var nickname: String = ""
    var avatar_url: String = ""
    var phone: String = ""
    var role: String = ROLE_USER
    var status: String = STATUS_ACTIVE
    var created_at: String = ""
    var updated_at: String = ""
}

class CategoryRow {
    var id: Int64 = 0
    var name: String = ""
    var scene_type: String = SCENE_ALL
    var sort_order: Int64 = 0
    var is_enabled: Bool = true
    var created_at: String = ""
}

class PostRow {
    var id: Int64 = 0
    var author_id: Int64 = 0
    var category_id: Int64 = 0
    var business_type: String = BIZ_TYPE_SECONDHAND
    var title: String = ""
    var description: String = ""
    var price: String = ""
    var location: String = ""
    var image_urls: String = "[]"
    var audit_status: String = AUDIT_PENDING
    var biz_status: String = BIZ_ON_SALE
    var view_count: Int64 = 0
    var favorite_count: Int64 = 0
    var created_at: String = ""
    var updated_at: String = ""
    var closed_at: String = ""
    var is_deleted: Bool = false
}

class FavoriteRow {
    var id: Int64 = 0
    var user_id: Int64 = 0
    var post_id: Int64 = 0
    var created_at: String = ""
}

class MessageRow {
    var id: Int64 = 0
    var post_id: Int64 = 0
    var from_user_id: Int64 = 0
    var to_user_id: Int64 = 0
    var message_type: String = MSG_PUBLIC_COMMENT
    var content: String = ""
    var parent_id: Int64 = 0
    var is_read: Bool = false
    var created_at: String = ""
}

class AuditRow {
    var id: Int64 = 0
    var post_id: Int64 = 0
    var auditor_id: Int64 = 0
    var audit_result: String = AUDIT_APPROVED
    var reason: String = ""
    var created_at: String = ""
}

class HistoryRow {
    var id: Int64 = 0
    var user_id: Int64 = 0
    var post_id: Int64 = 0
    var viewed_at: String = ""
}

class RequestRow {
    var id: Int64 = 0
    var post_id: Int64 = 0
    var requester_id: Int64 = 0
    var request_type: String = REQ_TYPE_BUY
    var status: String = REQ_STATUS_PENDING
    var note: String = ""
    var created_at: String = ""
    var updated_at: String = ""
}

class CategorySeed {
    var id: Int64
    var name: String
    var scene_type: String
    var sort_order: Int64
    var is_enabled: Bool
    public init(id: Int64, name: String, scene_type: String, sort_order: Int64, is_enabled: Bool) {
        this.id = id; this.name = name; this.scene_type = scene_type
        this.sort_order = sort_order; this.is_enabled = is_enabled
    }
}

class PostSeed {
    var author_id: Int64
    var business_type: String
    var category_id: Int64
    var title: String
    var description: String
    var price: String
    var location: String
    var image_urls: String
    var audit_status: String
    var biz_status: String
    var view_count: Int64
    var favorite_count: Int64
    public init(author_id: Int64, business_type: String, category_id: Int64, title: String, description: String, price: String, location: String, image_urls: String, audit_status: String, biz_status: String, view_count: Int64, favorite_count: Int64) {
        this.author_id = author_id; this.business_type = business_type; this.category_id = category_id
        this.title = title; this.description = description; this.price = price; this.location = location
        this.image_urls = image_urls; this.audit_status = audit_status; this.biz_status = biz_status
        this.view_count = view_count; this.favorite_count = favorite_count
    }
}

class Database {
    var users: Array<UserRow> = Array<UserRow>()
    var categories: Array<CategoryRow> = Array<CategoryRow>()
    var posts: Array<PostRow> = Array<PostRow>()
    var favorites: Array<FavoriteRow> = Array<FavoriteRow>()
    var messages: Array<MessageRow> = Array<MessageRow>()
    var audits: Array<AuditRow> = Array<AuditRow>()
    var histories: Array<HistoryRow> = Array<HistoryRow>()
    var requests: Array<RequestRow> = Array<RequestRow>()

    var nextUserId: Int64 = 1
    var nextCategoryId: Int64 = 1
    var nextPostId: Int64 = 1
    var nextFavoriteId: Int64 = 1
    var nextMessageId: Int64 = 1
    var nextAuditId: Int64 = 1
    var nextHistoryId: Int64 = 1
    var nextRequestId: Int64 = 1

    public init() {
        seedData()
    }

    func seedData() {
        seedUsers()
        seedCategories()
        seedPosts()
        seedFavorites()
    }

    func seedUsers() {
        var admin = UserRow()
        admin.id = nextUserId; nextUserId++
        admin.username = "admin"
        admin.password_hash = hashPassword("123456")
        admin.nickname = "管理员"
        admin.avatar_url = ""
        admin.phone = "13900000000"
        admin.role = ROLE_ADMIN
        admin.status = STATUS_ACTIVE
        admin.created_at = "2026-04-01 08:00:00"
        admin.updated_at = "2026-04-01 08:00:00"
        users = appendToArray(users, admin)

        var user1 = UserRow()
        user1.id = nextUserId; nextUserId++
        user1.username = "zhangsan"
        user1.password_hash = hashPassword("123456")
        user1.nickname = "张三"
        user1.avatar_url = ""
        user1.phone = "13800138000"
        user1.role = ROLE_USER
        user1.status = STATUS_ACTIVE
        user1.created_at = "2026-04-10 10:00:00"
        user1.updated_at = "2026-04-10 10:00:00"
        users = appendToArray(users, user1)
    }

    func seedCategories() {
        var catSeeds = [
            CategorySeed(1, "电子数码", SCENE_SECONDHAND, 1, true),
            CategorySeed(2, "图书教材", SCENE_SECONDHAND, 2, true),
            CategorySeed(3, "生活用品", SCENE_SECONDHAND, 3, true),
            CategorySeed(4, "服饰箱包", SCENE_SECONDHAND, 4, true),
            CategorySeed(5, "运动户外", SCENE_SECONDHAND, 5, true),
            CategorySeed(6, "美妆饰品", SCENE_SECONDHAND, 6, true),
            CategorySeed(7, "宠物用品", SCENE_SECONDHAND, 7, true),
            CategorySeed(8, "校园生活", SCENE_SECONDHAND, 8, true),
            CategorySeed(9, "证件", SCENE_LOST, 1, true),
            CategorySeed(10, "书包", SCENE_LOST, 2, true),
            CategorySeed(11, "电子产品", SCENE_LOST, 3, true),
            CategorySeed(12, "书籍", SCENE_LOST, 4, true),
            CategorySeed(13, "眼镜", SCENE_LOST, 5, true),
            CategorySeed(14, "其他", SCENE_LOST, 6, true),
            CategorySeed(15, "证件", SCENE_FOUND, 1, true),
            CategorySeed(16, "电子产品", SCENE_FOUND, 2, true),
            CategorySeed(17, "其他", SCENE_FOUND, 3, true)
        ]
        nextCategoryId = 18
        for (c in catSeeds) {
            var row = CategoryRow()
            row.id = c.id; row.name = c.name; row.scene_type = c.scene_type
            row.sort_order = c.sort_order; row.is_enabled = c.is_enabled
            row.created_at = "2026-04-01 08:00:00"
            categories = appendToArray(categories, row)
        }
    }

    func seedPosts() {
        var now = "2026-04-30 18:00:00"
        var postSeeds = [
            PostSeed(1, BIZ_TYPE_SECONDHAND, 1, "佳能EOSM50", "自用微单相机，九成新，配件齐全，含镜头", "1680", "学院路校区", "[\"pdt_camera\"]", AUDIT_APPROVED, BIZ_ON_SALE, 23, 56),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 2, "离散数学教材", "九成新，基本无划线", "20", "学院路校区", "[\"pdt_camera\"]", AUDIT_APPROVED, BIZ_ON_SALE, 12, 34),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 3, "护眼台灯", "使用三个月，光线柔和", "45", "沙河校区", "[\"pdt_lamp\"]", AUDIT_APPROVED, BIZ_ON_SALE, 8, 23),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 5, "捷安特山地车", "骑了半年，保养良好", "320", "学院路校区", "[\"pdt_bike\"]", AUDIT_APPROVED, BIZ_ON_SALE, 1, 15),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 4, "索尼A6000", "入门微单，带16-50套头", "2200", "沙河校区", "[\"pdt_camera\"]", AUDIT_APPROVED, BIZ_ON_SALE, 56, 78),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 5, "美利达公爵600", "山地车，性能良好", "800", "学院路校区", "[\"pdt_bike\"]", AUDIT_APPROVED, BIZ_ON_SALE, 15, 42),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 3, "小米台灯Pro", "智能台灯，支持色温调节", "189", "沙河校区", "[\"pdt_lamp\"]", AUDIT_APPROVED, BIZ_ON_SALE, 32, 9),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 1, "富士拍立得", "拍立得相机，送相纸", "499", "学院路校区", "[\"pdt_camera\"]", AUDIT_APPROVED, BIZ_ON_SALE, 78, 156),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 8, "折叠滑板车", "便携代步，可放入后备箱", "650", "沙河校区", "[\"pdt_bike\"]", AUDIT_APPROVED, BIZ_ON_SALE, 42, 88),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 7, "USB小夜灯", "创意小夜灯，多种光效", "25", "学院路校区", "[\"pdt_lamp\"]", AUDIT_APPROVED, BIZ_ON_SALE, 156, 203),
            PostSeed(1, BIZ_TYPE_SECONDHAND, 3, "瑜伽垫", "加厚防滑，TPE材质", "68", "沙河校区", "[\"pdt_camera\"]", AUDIT_PENDING, BIZ_ON_SALE, 0, 0),
            PostSeed(2, BIZ_TYPE_LOST, 9, "黑色双肩包", "北区图书馆丢失，内有笔记本电脑", "", "北区图书馆2楼", "[\"lost_bag\"]", AUDIT_APPROVED, BIZ_OPEN, 45, 12),
            PostSeed(2, BIZ_TYPE_LOST, 9, "学生证", "姓名张三，学号2024001", "", "南区食堂一楼", "[\"lost_card\"]", AUDIT_APPROVED, BIZ_OPEN, 30, 8),
            PostSeed(2, BIZ_TYPE_LOST, 11, "AirPodsPro", "右耳刻有'Z'字标记", "", "体育馆羽毛球场", "[\"lost_airpods\"]", AUDIT_APPROVED, BIZ_OPEN, 67, 23),
            PostSeed(2, BIZ_TYPE_LOST, 4, "《数据结构》", "课本，封面有姓名和学号", "", "东区教学楼305", "[\"lost_book\"]", AUDIT_APPROVED, BIZ_OPEN, 15, 5),
            PostSeed(2, BIZ_TYPE_LOST, 13, "黑框眼镜", "黑色金属框，度数300", "", "校园超市门口", "[\"lost_classes\"]", AUDIT_APPROVED, BIZ_OPEN, 22, 7),
            PostSeed(1, BIZ_TYPE_FOUND, 16, "捡到银色U盘", "在东区机房捡到，32G闪迪", "", "东区机房", "[\"lost_bag\"]", AUDIT_APPROVED, BIZ_OPEN, 18, 6),
            PostSeed(1, BIZ_TYPE_FOUND, 15, "捡到校园卡", "学号2024015，在食堂捡到", "", "南区食堂二楼", "[\"lost_card\"]", AUDIT_PENDING, BIZ_OPEN, 0, 0)
        ]
        nextPostId = 19
        for (p in postSeeds) {
            var row = PostRow()
            row.id = nextPostId
            row.author_id = p.author_id; row.category_id = p.category_id
            row.business_type = p.business_type; row.title = p.title
            row.description = p.description; row.price = p.price
            row.location = p.location; row.image_urls = p.image_urls
            row.audit_status = p.audit_status; row.biz_status = p.biz_status
            row.view_count = p.view_count; row.favorite_count = p.favorite_count
            row.created_at = now; row.updated_at = now
            posts = appendToArray(posts, row)
            nextPostId++
        }
    }

        func seedFavorites() {
        var row = FavoriteRow()
        row.id = 1; nextFavoriteId = 2
        row.user_id = 2
        row.post_id = 1
        row.created_at = "2026-04-30 17:00:00"
        favorites = appendToArray(favorites, row)
    }

    func findUserByUsername(username: String): Option<UserRow> {
        for (u in users) {
            if (u.username == username) { return u }
        }
        return None
    }

    func findUserById(id: Int64): Option<UserRow> {
        for (u in users) {
            if (u.id == id) { return u }
        }
        return None
    }

    func findCategoryById(id: Int64): Option<CategoryRow> {
        for (c in categories) {
            if (c.id == id) { return c }
        }
        return None
    }

    func findPostById(id: Int64): Option<PostRow> {
        for (p in posts) {
            if (p.id == id && !p.is_deleted) { return p }
        }
        return None
    }

    func findFavorite(userId: Int64, postId: Int64): Option<FavoriteRow> {
        for (f in favorites) {
            if (f.user_id == userId && f.post_id == postId) { return f }
        }
        return None
    }

    func findMessagesByPostId(postId: Int64): Array<MessageRow> {
        var count = 0
        for (m in messages) {
            if (m.post_id == postId) { count++ }
        }
        var result = Array<MessageRow>(count, {i => MessageRow()})
        var idx = 0
        for (m in messages) {
            if (m.post_id == postId) { result[idx] = m; idx++ }
        }
        return result
    }

    func isFavorited(userId: Int64, postId: Int64): Bool {
        for (f in favorites) {
            if (f.user_id == userId && f.post_id == postId) { return true }
        }
        return false
    }
}

let DB = Database()

func appendToArray(arr: Array<UserRow>, item: UserRow): Array<UserRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<CategoryRow>, item: CategoryRow): Array<CategoryRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<PostRow>, item: PostRow): Array<PostRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<FavoriteRow>, item: FavoriteRow): Array<FavoriteRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<MessageRow>, item: MessageRow): Array<MessageRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<AuditRow>, item: AuditRow): Array<AuditRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<HistoryRow>, item: HistoryRow): Array<HistoryRow> {
    return arr.concat([item])
}

func appendToArray(arr: Array<RequestRow>, item: RequestRow): Array<RequestRow> {
    return arr.concat([item])
}

func removeAt(arr: Array<FavoriteRow>, idx: Int64): Array<FavoriteRow> {
    if (arr.size == 0 || idx >= arr.size) { return arr }
    return arr[0..idx].concat(arr[idx+1..arr.size])
}

func removeAt(arr: Array<HistoryRow>, idx: Int64): Array<HistoryRow> {
    if (arr.size == 0 || idx >= arr.size) { return arr }
    return arr[0..idx].concat(arr[idx+1..arr.size])
}

func hashPassword(pwd: String): String {
    var h: Int64 = 0
    for (c in pwd) {
        h = h * 31 + Int64(c)
    }
    return h.toString()
}

func getCategoryName(id: Int64): String {
    match (DB.findCategoryById(id)) {
        case Some(c) => { => return c.name }
        case None => ()
    }
    return ""
    return ""
}

func parseImageUrls(json: String): Array<String> {
    var s = json
    if (s.size < 2) { return Array<String>() }
    s = s[1..(s.size - 1)]
    if (s == "") { return Array<String>() }
    let parts = s.split(",")
    var result = Array<String>(parts.size, {i => parts[i].replace("\"", "").trimAscii()})
    return result
}
