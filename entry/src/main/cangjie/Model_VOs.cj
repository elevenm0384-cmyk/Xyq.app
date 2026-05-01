package ohos_app_cangjie_entry

public class ApiResponse<T> {
    public var code: Int64 = 0
    public var message: String = "ok"
    public var data: T
    public init(data: T) {
        this.data = data
    }
}

public class PageData<T> {
    public var list: Array<T> = Array<T>()
    public var page: Int64 = 1
    public var pageSize: Int64 = 10
    public var total: Int64 = 0
    public init() {}
}

public class UserVO {
    public var id: Int64 = 0
    public var username: String = ""
    public var nickname: String = ""
    public var avatar_url: String = ""
    public var phone: String = ""
    public var role: String = ROLE_USER
    public var status: String = STATUS_ACTIVE
    public var created_at: String = ""
    public init() {}
}

public class LoginResult {
    public var user: UserVO = UserVO()
    public var token: String = ""
    public init() {}
}

public class CategoryVO {
    public var id: Int64 = 0
    public var name: String = ""
    public var scene_type: String = SCENE_ALL
    public var sort_order: Int64 = 0
    public var is_enabled: Bool = true
    public init() {}
}

public class PostSummaryVO {
    public var id: Int64 = 0
    public var author_id: Int64 = 0
    public var author_nickname: String = ""
    public var author_avatar_url: String = ""
    public var category_id: Int64 = 0
    public var category_name: String = ""
    public var business_type: String = BIZ_TYPE_SECONDHAND
    public var title: String = ""
    public var description: String = ""
    public var price: String = ""
    public var location: String = ""
    public var cover_image_url: String = ""
    public var audit_status: String = AUDIT_PENDING
    public var biz_status: String = BIZ_ON_SALE
    public var view_count: Int64 = 0
    public var favorite_count: Int64 = 0
    public var created_at: String = ""
    public init() {}
}

public class AuthorInfo {
    public var id: Int64 = 0
    public var nickname: String = ""
    public var avatar_url: String = ""
    public var phone: String = ""
    public init() {}
}

public class CategoryInfo {
    public var id: Int64 = 0
    public var name: String = ""
    public init() {}
}

public class PostDetailVO {
    public var id: Int64 = 0
    public var author: AuthorInfo = AuthorInfo()
    public var category: CategoryInfo = CategoryInfo()
    public var business_type: String = BIZ_TYPE_SECONDHAND
    public var title: String = ""
    public var description: String = ""
    public var price: String = ""
    public var location: String = ""
    public var image_urls: Array<String> = Array(0, {i => ""})
    public var audit_status: String = AUDIT_PENDING
    public var biz_status: String = BIZ_ON_SALE
    public var view_count: Int64 = 0
    public var favorite_count: Int64 = 0
    public var is_favorited: Bool = false
    public var created_at: String = ""
    public var updated_at: String = ""
    public init() {}
}

public class FromToUser {
    public var id: Int64 = 0
    public var nickname: String = ""
    public var avatar_url: String = ""
    public init() {}
}

public class MessageVO {
    public var id: Int64 = 0
    public var post_id: Int64 = 0
    public var from_user: FromToUser = FromToUser()
    public var to_user: FromToUser = FromToUser()
    public var message_type: String = MSG_PUBLIC_COMMENT
    public var content: String = ""
    public var parent_id: Int64 = 0
    public var is_read: Bool = false
    public var created_at: String = ""
    public init() {}
}

public class RequesterInfo {
    public var id: Int64 = 0
    public var nickname: String = ""
    public init() {}
}

public class RequestVO {
    public var id: Int64 = 0
    public var post_id: Int64 = 0
    public var requester: RequesterInfo = RequesterInfo()
    public var request_type: String = REQ_TYPE_BUY
    public var status: String = REQ_STATUS_PENDING
    public var note: String = ""
    public var created_at: String = ""
    public var updated_at: String = ""
    public init() {}
}

public class AuditVO {
    public var id: Int64 = 0
    public var post_id: Int64 = 0
    public var auditor_id: Int64 = 0
    public var audit_result: String = AUDIT_APPROVED
    public var reason: String = ""
    public var created_at: String = ""
    public init() {}
}

public class FavoriteResult {
    public var favorited: Bool = false
    public init() {}
}

public class CreatePostResult {
    public var id: Int64 = 0
    public var audit_status: String = AUDIT_PENDING
    public var biz_status: String = BIZ_ON_SALE
    public init() {}
}

public class CategoryCount {
    public var category_id: Int64 = 0
    public var category_name: String = ""
    public var count: Int64 = 0
    public init() {}
}

public class StatsOverview {
    public var total_users: Int64 = 0
    public var total_posts: Int64 = 0
    public var pending_audit_count: Int64 = 0
    public var secondhand_count: Int64 = 0
    public var lost_count: Int64 = 0
    public var found_count: Int64 = 0
    public var hot_categories: Array<CategoryCount> = Array(0, {i => CategoryCount()})
    public init() {}
}
