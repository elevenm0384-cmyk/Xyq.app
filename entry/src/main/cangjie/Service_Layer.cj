package ohos_app_cangjie_entry

// 鍚庣娴嬭瘯鐢?- 涓氬姟閫昏緫灞?
var g_currentUserId: Int64 = 0
var g_currentToken: String = ""
var g_currentUserVO: UserVO = UserVO()

public func isLoggedIn(): Bool {
    return g_currentUserId > 0
}

public func getSessionUserId(): Int64 {
    return g_currentUserId
}

public func getSessionToken(): String {
    return g_currentToken
}

public func getSessionUser(): UserVO {
    return g_currentUserVO
}

public func login(username: String, password: String): Option<UserVO> {
    let account = username.trimAscii()
    match (DB.findUserByUsername(account)) {
        case Some(u) =>
            if (u.password_hash != hashPassword(password)) { return None }
            if (u.status != STATUS_ACTIVE) { return None }
            g_currentUserId = u.id
            g_currentToken = "token_${u.id}_${getCurrentTimestamp()}"
            g_currentUserVO = userRowToVO(u)
            return g_currentUserVO
        case None => return None
    }
}

public func register(username: String, password: String, nickname: String, phone: String): Option<UserVO> {
    let account = username.trimAscii()
    let name = nickname.trimAscii()
    let phoneNo = phone.trimAscii()
    match (DB.findUserByUsername(account)) {
        case Some(_) =>  return None
        case None => ()
    }
    var row = UserRow()
    row.id = DB.nextUserId; DB.nextUserId++
    row.username = account
    row.password_hash = hashPassword(password)
    row.nickname = name
    row.phone = phoneNo
    row.role = ROLE_USER
    row.status = STATUS_ACTIVE
    row.created_at = getCurrentTimestamp()
    row.updated_at = getCurrentTimestamp()
    DB.users = appendToArray(DB.users, row)
    g_currentUserId = row.id
    g_currentToken = "token_${row.id}_${getCurrentTimestamp()}"
    g_currentUserVO = userRowToVO(row)
    return g_currentUserVO
}

public func logout() {
    g_currentUserId = 0
    g_currentToken = ""
    g_currentUserVO = UserVO()
}

public func getCategories(sceneType: String): Array<CategoryVO> {
    var count = 0
    for (c in DB.categories) {
        if (!c.is_enabled) { continue }
        if (sceneType != SCENE_ALL && c.scene_type != sceneType && c.scene_type != SCENE_ALL) { continue }
        count++
    }
    var result = Array<CategoryVO>(count, {i => CategoryVO()})
    var idx = 0
    for (c in DB.categories) {
        if (!c.is_enabled) { continue }
        if (sceneType != SCENE_ALL && c.scene_type != sceneType && c.scene_type != SCENE_ALL) { continue }
        var vo = CategoryVO()
        vo.id = c.id; vo.name = c.name; vo.scene_type = c.scene_type
        vo.sort_order = c.sort_order; vo.is_enabled = c.is_enabled
        result[idx] = vo; idx++
    }
    return result
}

public func getPostList(
    business_type: String, category_id: Int64,
    keyword: String, location: String,
    audit_status: String, biz_status: String,
    sort_by: String, page: Int64, pageSize: Int64
): PageData<PostSummaryVO> {
    var list: Array<PostSummaryVO> = Array(0, {i => PostSummaryVO()})
    for (p in DB.posts) {
        if (p.is_deleted) { continue }
        if (business_type != "" && p.business_type != business_type) { continue }
        if (category_id > 0 && p.category_id != category_id) { continue }
        if (audit_status != "" && p.audit_status != audit_status) { continue }
        if (biz_status != "" && p.biz_status != biz_status) { continue }
        if (location != "" && !p.location.contains(location)) { continue }
        if (keyword != "" && !p.title.contains(keyword) && !p.description.contains(keyword)) { continue }
        var vo = postRowToSummary(p)
        list = appendPostSummary(list, vo)
    }
    list = sortPosts(list, sort_by)
    var total = list.size
    var start = (page - 1) * pageSize
    var end = start + pageSize
    if (start >= total) { start = 0; end = 0 }
    if (end > total) { end = total }
    var pageSize2 = end - start
    let sList = list
    let sStart = start
    var pageList = Array<PostSummaryVO>(pageSize2, {i => sList[sStart + i]})
    var pd = PageData<PostSummaryVO>()
    pd.list = pageList; pd.page = page; pd.pageSize = pageSize; pd.total = total
    return pd
}

public func getPostDetail(postId: Int64): PostDetailVO {
    match (DB.findPostById(postId)) {
        case Some(p) =>
            var vo = PostDetailVO()
            vo.id = p.id
            match (DB.findUserById(p.author_id)) {
                case Some(author) =>
                    vo.author.id = author.id
                    vo.author.nickname = author.nickname
                    vo.author.avatar_url = author.avatar_url
                    vo.author.phone = author.phone

                case None => ()
            }
            match (DB.findCategoryById(p.category_id)) {
                case Some(cat) =>
                    vo.category.id = cat.id
                    vo.category.name = cat.name
                case None => ()
            }
            vo.business_type = p.business_type
            vo.title = p.title
            vo.description = p.description
            vo.price = p.price
            vo.location = p.location
            vo.image_urls = parseImageUrls(p.image_urls)
            vo.audit_status = p.audit_status
            vo.biz_status = p.biz_status
            vo.view_count = p.view_count
            vo.created_at = p.created_at
            vo.updated_at = p.updated_at
            return vo
        case None => return PostDetailVO()
    }
}

public func incrementViewCount(postId: Int64) {
    for (i in 0..DB.posts.size) {
        if (DB.posts[i].id == postId) {
            DB.posts[i].view_count++
            break
        }
    }
}

public func recordBrowseHistory(userId: Int64, postId: Int64) {
    if (userId == 0) { return }
    for (i in 0..DB.histories.size) {
        if (DB.histories[i].user_id == userId && DB.histories[i].post_id == postId) {
            DB.histories[i].viewed_at = getCurrentTimestamp()
            return
        }
    }
    var h = HistoryRow()
    h.id = DB.nextHistoryId; DB.nextHistoryId++
    h.user_id = userId
    h.post_id = postId
    h.viewed_at = getCurrentTimestamp()
    DB.histories = appendToArray(DB.histories, h)
}

public func getHistory(userId: Int64): PageData<PostSummaryVO> {
    if (userId == 0) { return PageData<PostSummaryVO>() }
    var total: Int64 = 0
    for (h in DB.histories) {
        if (h.user_id == userId) { total++ }
    }
    var list = Array<PostSummaryVO>(total, {i => PostSummaryVO()})
    var idx: Int64 = 0
    for (i in (DB.histories.size - 1)..=0 : -1) {
        if (DB.histories[i].user_id == userId) {
            match (DB.findPostById(DB.histories[i].post_id)) {
                case Some(p) => list[idx] = postRowToSummary(p)
                    idx++
                case None => ()
            }
        }
        if (idx >= total) { break }
    }
    var pd = PageData<PostSummaryVO>()
    pd.list = list; pd.page = 1; pd.pageSize = total; pd.total = total
    return pd
}

public func getMyPublishedPosts(userId: Int64): PageData<PostSummaryVO> {
    if (userId == 0) { return PageData<PostSummaryVO>() }
    var total: Int64 = 0
    for (p in DB.posts) {
        if (!p.is_deleted && p.author_id == userId) { total++ }
    }
    var list = Array<PostSummaryVO>(total, {i => PostSummaryVO()})
    var idx: Int64 = 0
    for (i in (DB.posts.size - 1)..=0 : -1) {
        if (!DB.posts[i].is_deleted && DB.posts[i].author_id == userId) {
            list[idx] = postRowToSummary(DB.posts[i])
            idx++
        }
        if (idx >= total) { break }
    }
    var pd = PageData<PostSummaryVO>()
    pd.list = list; pd.page = 1; pd.pageSize = total; pd.total = total
    return pd
}

public func getPendingAuditPosts(): Array<PostSummaryVO> {
    var total: Int64 = 0
    for (p in DB.posts) {
        if (!p.is_deleted && p.audit_status == AUDIT_PENDING) { total++ }
    }
    var list = Array<PostSummaryVO>(total, {i => PostSummaryVO()})
    var idx: Int64 = 0
    for (i in (DB.posts.size - 1)..=0 : -1) {
        if (!DB.posts[i].is_deleted && DB.posts[i].audit_status == AUDIT_PENDING) {
            list[idx] = postRowToSummary(DB.posts[i])
            idx++
        }
        if (idx >= total) { break }
    }
    return list
}

public func auditPost(postId: Int64, approved: Bool): Bool {
    if (getSessionUser().role != ROLE_ADMIN) { return false }
    for (i in 0..DB.posts.size) {
        if (DB.posts[i].id == postId && !DB.posts[i].is_deleted) {
            if (approved) {
                DB.posts[i].audit_status = AUDIT_APPROVED
            } else {
                DB.posts[i].audit_status = AUDIT_REJECTED
            }
            DB.posts[i].updated_at = getCurrentTimestamp()
            var audit = AuditRow()
            audit.id = DB.nextAuditId
            DB.nextAuditId++
            audit.post_id = postId
            audit.auditor_id = getSessionUserId()
            audit.audit_result = DB.posts[i].audit_status
            audit.created_at = getCurrentTimestamp()
            DB.audits = appendToArray(DB.audits, audit)
            return true
        }
    }
    return false
}

public func getMessageCenter(userId: Int64): Array<MessageVO> {
    if (userId == 0) { return Array(0, {i => MessageVO()}) }
    var total: Int64 = 0
    for (m in DB.messages) {
        match (DB.findPostById(m.post_id)) {
            case Some(p) =>
                if (p.author_id == userId || m.from_user_id == userId || m.to_user_id == userId) { total++ }
            case None => ()
        }
    }
    var result = Array<MessageVO>(total, {i => MessageVO()})
    var idx: Int64 = 0
    for (m in DB.messages) {
        match (DB.findPostById(m.post_id)) {
            case Some(p) =>
                if (p.author_id == userId || m.from_user_id == userId || m.to_user_id == userId) {
                    var vo = MessageVO()
                    vo.id = m.id; vo.post_id = m.post_id
                    vo.message_type = m.message_type
                    vo.content = m.content
                    vo.created_at = m.created_at
                    match (DB.findUserById(m.from_user_id)) {
                        case Some(u) =>
                            vo.from_user.id = u.id
                            vo.from_user.nickname = u.nickname
                        case None => ()
                    }
                    result[idx] = vo; idx++
                }
            case None => ()
        }
    }
    return result
}

public func getMessages(postId: Int64): Array<MessageVO> {
    var rows = DB.findMessagesByPostId(postId)
    var total: Int64 = 0
    for (r in rows) {
        if (r.message_type == MSG_PUBLIC_COMMENT) {
            total++
        }
    }
    var result = Array<MessageVO>(total, {i => MessageVO()})
    var idx: Int64 = 0
    for (i in 0..rows.size) {
        if (rows[i].message_type != MSG_PUBLIC_COMMENT) {
            continue
        }
        var vo = MessageVO()
        vo.id = rows[i].id; vo.post_id = rows[i].post_id
        vo.message_type = rows[i].message_type; vo.content = rows[i].content
        vo.parent_id = rows[i].parent_id; vo.is_read = rows[i].is_read
        vo.created_at = rows[i].created_at
        var fromUser = DB.findUserById(rows[i].from_user_id)
        match (fromUser) {
            case Some(u) =>
                vo.from_user.id = u.id; vo.from_user.nickname = u.nickname
                vo.from_user.avatar_url = u.avatar_url
            case None => ()
        }
        var toUser = DB.findUserById(rows[i].to_user_id)
        match (toUser) {
            case Some(u) =>
                vo.to_user.id = u.id; vo.to_user.nickname = u.nickname
                vo.to_user.avatar_url = u.avatar_url
            case None => ()
        }
        result[idx] = vo
        idx++
    }
    return result
}

public func addMessage(postId: Int64, fromUserId: Int64, content: String): Option<MessageVO> {
    if (fromUserId == 0 || content == "") { return None }
    var row = MessageRow()
    row.id = DB.nextMessageId; DB.nextMessageId++
    row.post_id = postId; row.from_user_id = fromUserId
    row.message_type = MSG_PUBLIC_COMMENT; row.content = content
    row.created_at = getCurrentTimestamp()
    DB.messages = appendToArray(DB.messages, row)
    var vo = MessageVO()
    vo.id = row.id; vo.post_id = row.post_id; vo.content = row.content
    vo.message_type = row.message_type; vo.created_at = row.created_at
    vo.from_user.id = fromUserId
    match (DB.findUserById(fromUserId)) {
        case Some(u) =>
            vo.from_user.nickname = u.nickname
            vo.from_user.avatar_url = u.avatar_url
        case None => ()
    }
    return vo
}

public func sendPrivateMessage(postId: Int64, fromUserId: Int64, content: String): Bool {
    if (fromUserId == 0 || content == "") { return false }
    match (DB.findPostById(postId)) {
        case Some(p) =>
            if (p.author_id == fromUserId) { return false }
            var row = MessageRow()
            row.id = DB.nextMessageId; DB.nextMessageId++
            row.post_id = postId
            row.from_user_id = fromUserId
            row.to_user_id = p.author_id
            row.message_type = MSG_PRIVATE_MESSAGE
            row.content = content
            row.created_at = getCurrentTimestamp()
            DB.messages = appendToArray(DB.messages, row)
            return true
        case None => return false
    }
}

public func deleteMyPost(postId: Int64, userId: Int64): Bool {
    if (userId == 0) { return false }
    for (i in 0..DB.posts.size) {
        if (DB.posts[i].id == postId
            && DB.posts[i].author_id == userId
            && !DB.posts[i].is_deleted) {
            DB.posts[i].is_deleted = true
            DB.posts[i].updated_at = getCurrentTimestamp()
            return true
        }
    }
    return false
}

public func finishMyPost(postId: Int64, userId: Int64): Bool {
    if (userId == 0) { return false }
    for (i in 0..DB.posts.size) {
        if (DB.posts[i].id == postId
            && DB.posts[i].author_id == userId
            && !DB.posts[i].is_deleted) {
            if (DB.posts[i].business_type == BIZ_TYPE_SECONDHAND) {
                DB.posts[i].biz_status = BIZ_SOLD
            } else {
                DB.posts[i].biz_status = BIZ_CLAIMED
            }
            DB.posts[i].closed_at = getCurrentTimestamp()
            DB.posts[i].updated_at = getCurrentTimestamp()
            return true
        }
    }
    return false
}

public func publishPost(
    businessType: String,
    title: String,
    description: String,
    price: String,
    location: String,
    categoryId!: Int64 = 0,
    imageName!: String = ""
): Option<CreatePostResult> {
    if (title == "" || description == "") { return None }
    if (businessType == BIZ_TYPE_SECONDHAND && price == "") { return None }

    var row = PostRow()
    row.id = DB.nextPostId
    DB.nextPostId++
    row.author_id = getSessionUserId()
    if (row.author_id == 0) { row.author_id = 1 }
    if (businessType == BIZ_TYPE_LOST) {
        if (categoryId > 0) { row.category_id = categoryId }
        else { row.category_id = 9 }
        if (imageName != "") {
            row.image_urls = "[\"" + imageName + "\"]"
        } else {
            row.image_urls = "[\"lost_card\"]"
        }
    } else if (businessType == BIZ_TYPE_FOUND) {
        if (categoryId > 0) { row.category_id = categoryId }
        else { row.category_id = 9 }
        if (imageName != "") {
            row.image_urls = "[\"" + imageName + "\"]"
        } else {
            row.image_urls = "[\"lost_bag\"]"
        }
    } else {
        row.category_id = 1
        if (imageName != "") {
            row.image_urls = "[\"" + imageName + "\"]"
        } else {
            row.image_urls = "[\"pdt_camera\"]"
        }
    }
    row.business_type = businessType
    row.title = title
    row.description = description
    row.price = price
    row.location = location
    row.audit_status = AUDIT_PENDING
    row.biz_status = getDefaultBizStatus(businessType)
    row.view_count = 0
    row.created_at = getCurrentTimestamp()
    row.updated_at = getCurrentTimestamp()
    DB.posts = appendToArray(DB.posts, row)

    var result = CreatePostResult()
    result.id = row.id
    result.audit_status = row.audit_status
    result.biz_status = row.biz_status
    return result
}

func userRowToVO(row: UserRow): UserVO {
    var vo = UserVO()
    vo.id = row.id; vo.username = row.username
    vo.nickname = row.nickname; vo.avatar_url = row.avatar_url
    vo.phone = row.phone; vo.role = row.role
    vo.status = row.status; vo.created_at = row.created_at
    return vo
}

func postRowToSummary(row: PostRow): PostSummaryVO {
    var vo = PostSummaryVO()
    vo.id = row.id; vo.author_id = row.author_id
    match (DB.findUserById(row.author_id)) {
        case Some(author) =>
            vo.author_nickname = author.nickname
            vo.author_avatar_url = author.avatar_url
        case None => ()
    }
    vo.category_id = row.category_id
    vo.category_name = getCategoryName(row.category_id)
    vo.business_type = row.business_type
    vo.title = row.title; vo.description = row.description
    vo.price = row.price; vo.location = row.location
    var images = parseImageUrls(row.image_urls)
    if (images.size > 0) { vo.cover_image_url = images[0] }
    vo.audit_status = row.audit_status; vo.biz_status = row.biz_status
    vo.view_count = row.view_count
    vo.created_at = row.created_at
    return vo
}

func sortPosts(arr: Array<PostSummaryVO>, sort_by: String): Array<PostSummaryVO> {
    if (arr.size <= 1) { return arr }
    if (sort_by != SORT_LATEST) {
        return arr
    }
    var result = Array<PostSummaryVO>(arr.size, {i => PostSummaryVO()})
    var idx: Int64 = 0
    for (i in (arr.size - 1)..=0 : -1) {
        result[idx] = arr[i]
        idx++
    }
    return result
}

public func getApprovedSecondhand(): Array<PostSummaryVO> {
    return getPostList(BIZ_TYPE_SECONDHAND, 0, "", "", AUDIT_APPROVED, BIZ_ON_SALE, SORT_LATEST, 1, 20).list
}

public func getApprovedLostFound(): Array<PostSummaryVO> {
    var lost = getPostList(BIZ_TYPE_LOST, 0, "", "", AUDIT_APPROVED, BIZ_OPEN, SORT_LATEST, 1, 10).list
    var found = getPostList(BIZ_TYPE_FOUND, 0, "", "", AUDIT_APPROVED, BIZ_OPEN, SORT_LATEST, 1, 10).list
    return lost.concat(found)
}

func appendPostSummary(arr: Array<PostSummaryVO>, item: PostSummaryVO): Array<PostSummaryVO> {
    return arr.concat([item])
}

