package cangjie
import std.collection.*
import std.fs.*
import std.time.*

// ===== simple in-memory favorites =====
var favStore:
    HashMap<String, Bool> =
    HashMap<String, Bool>()
var favList:
    HashMap<Int64, ArrayList<Int64>> =
    HashMap<Int64, ArrayList<Int64>>()

func favKey(userId: Int64,
    itemId: Int64): String {
    return "${userId}_${itemId}"
}

func addFavorite(userId: Int64,
    itemId: Int64): Bool {
    let k = favKey(userId, itemId)
    if (favStore.contains(k)) {
        return false
    }
    favStore.add(k, true)
    match (favList.get(userId)) {
        case Some(list) => list.add(itemId)
        case None =>
            let list = ArrayList<Int64>()
            list.add(itemId)
            favList.add(userId, list)
    }
    return true
}

func removeFavorite(userId: Int64,
    itemId: Int64): Bool {
    let k = favKey(userId, itemId)
    if (!favStore.contains(k)) {
        return false
    }
    favStore.remove(k)
    match (favList.get(userId)) {
        case Some(list) =>
            var idx: Int64 = -1
            for (i in 0..list.size) {
                if (list[i] == itemId) {
                    idx = i
                    break
                }
            }
            if (idx >= 0) {
                list.remove(idx..idx + 1)
            }
        case None => ()
    }
    return true
}

func isFavorited(userId: Int64,
    itemId: Int64): Bool {
    return favStore.contains(
        favKey(userId, itemId))
}

func getFavIds(userId: Int64):
    ArrayList<Int64> {
    match (favList.get(userId)) {
        case Some(list) => return list
        case None =>
            return ArrayList<Int64>()
    }
}

// ===== response helpers =====
func okResp(data: JsonVal): HttpResponse {
    let body = respToJson(
        0, "ok", data)
    return HttpResponse()
        .setStatus(200)
        .setBody(body)
}

func failResp(code: Int64,
    msg: String): HttpResponse {
    let body = respToJson(
        code, msg, jsonNull())
    return HttpResponse()
        .setStatus(toStatus(code))
        .setBody(body)
}

func toStatus(code: Int64): Int64 {
    if (code == 1003) { return 401 }
    if (code == 1004) { return 403 }
    if (code == 1005) { return 400 }
    if (code == 1006) { return 404 }
    if (code == 1007) { return 400 }
    if (code == 1008) { return 400 }
    return 200
}

// convert User to JSON
func userToJson(u: User): JsonVal {
    let obj = jsonObj()
    jsonPut(obj, "id", jsonInt(u.id))
    jsonPut(obj, "username",
        jsonStr(u.username))
    jsonPut(obj, "email", jsonStr(u.email))
    jsonPut(obj, "role",
        jsonStr(match (u.role) {
            case Role.Student => "USER"
            case Role.Admin   => "ADMIN"
        }))
    return obj
}

// convert BaseItem to summary JSON
func itemToJson(item: BaseItem): JsonVal {
    let obj = jsonObj()
    jsonPut(obj, "id", jsonInt(item.id))
    jsonPut(obj, "title", jsonStr(item.title))
    jsonPut(obj, "description",
        jsonStr(item.description))
    jsonPut(obj, "categoryId",
        jsonInt(item.categoryId))
    jsonPut(obj, "publisherId",
        jsonInt(item.publisherId))
    jsonPut(obj, "itemType",
        jsonStr(match (item.itemType) {
            case ItemType.SecondHand =>
                "SECONDHAND"
            case ItemType.LostFound =>
                "LOSTFOUND"
        }))
    jsonPut(obj, "status",
        jsonStr(match (item.status) {
            case ItemStatus.Pending  => "PENDING"
            case ItemStatus.Approved => "APPROVED"
            case ItemStatus.Rejected => "REJECTED"
            case ItemStatus.Closed   => "CLOSED"
        }))
    jsonPut(obj, "imageUrl",
        jsonStr(item.imageUrl))
    jsonPut(obj, "contactInfo",
        jsonStr(item.contactInfo))
    jsonPut(obj, "tradeStatus",
        jsonStr(match (item.tradeStatus) {
            case TradeStatus.Idle     => "IDLE"
            case TradeStatus.Reserved => "RESERVED"
            case TradeStatus.Sold     => "SOLD"
        }))
    return obj
}

// convert Category to JSON
func catToJson(c: Category): JsonVal {
    let obj = jsonObj()
    jsonPut(obj, "id", jsonInt(c.id))
    jsonPut(obj, "name", jsonStr(c.name))
    match (c.parentId) {
        case Some(pid) =>
            jsonPut(obj, "parentId",
                jsonInt(pid))
        case None => ()
    }
    return obj
}

// ===== Auth handlers =====
public func handleRegister(
    req: HttpRequest
): HttpResponse {
    let body = jsonParse(req.body)
    let username =
        jsonGet(body, "username").strVal
    let password =
        jsonGet(body, "password").strVal
    let email =
        jsonGet(body, "email").strVal
    if (username.size < 3 ||
        username.size > 20) {
        return failResp(1005,
            "用户名长度3-20位")
    }
    if (password.size < 6) {
        return failResp(1005,
            "密码至少6位")
    }
    let auth = AuthService.getInstance()
    let regRes = auth.register(
        username, password, email)
    if (regRes.code != 200) {
        return failResp(
            1001, regRes.msg)
    }
    let loginRes = auth.login(
        username, password)
    match (loginRes.data) {
        case Some(token) =>
            match (auth.whoami(token).data) {
                case Some(u) =>
                    let vo = userToJson(u)
                    jsonPut(vo, "token",
                        jsonStr(token))
                    return okResp(vo)
                case None =>
                    return failResp(1006,
                        "注册失败")
            }
        case None =>
            return failResp(1006,
                "注册失败")
    }
}

public func handleLogin(
    req: HttpRequest
): HttpResponse {
    let body = jsonParse(req.body)
    let username =
        jsonGet(body, "username").strVal
    let password =
        jsonGet(body, "password").strVal
    if (username.size == 0 ||
        password.size == 0) {
        return failResp(1005,
            "用户名和密码不能为空")
    }
    let auth = AuthService.getInstance()
    let loginRes = auth.login(
        username, password)
    match (loginRes.data) {
        case Some(token) =>
            match (auth.whoami(token).data) {
                case Some(u) =>
                    let vo = userToJson(u)
                    jsonPut(vo, "token",
                        jsonStr(token))
                    return okResp(vo)
                case None =>
                    return failResp(1002,
                        "登录失败")
            }
        case None =>
            return failResp(1002,
                loginRes.msg)
    }
}

// ===== User handlers =====
public func handleGetMe(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    match (auth.whoami(token).data) {
        case Some(u) =>
            return okResp(userToJson(u))
        case None =>
            return failResp(1003, "未登录")
    }
}

public func handleUpdateMe(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    match (auth.whoami(token).data) {
        case Some(u) =>
            let body = jsonParse(req.body)
            let email =
                jsonGet(body, "email").strVal
            if (email.size > 0) {
                u.email = email
            }
            // 保存更新
            let repo =
                UserRepository.getInstance()
            repo.save(u)
            return okResp(userToJson(u))
        case None =>
            return failResp(1003, "未登录")
    }
}

// ===== Category handlers =====
public func handleListCategories(
    _: HttpRequest
): HttpResponse {
    let catSvc =
        CategoryService.getInstance()
    match (catSvc.listAll().data) {
        case Some(cats) =>
            let arr = jsonArr()
            for (i in 0..cats.size) {
                jsonPush(arr,
                    catToJson(cats[i]))
            }
            return okResp(arr)
        case None =>
            return okResp(jsonArr())
    }
}

// ===== Item/Post handlers =====
public func handleCreatePost(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let body = jsonParse(req.body)
    let title =
        jsonGet(body, "title").strVal
    let description =
        jsonGet(body, "description").strVal
    let catId =
        jsonGet(body, "categoryId").intVal
    let typeStr =
        jsonGet(body, "itemType").strVal
    let imageUrl =
        jsonGet(body, "imageUrl").strVal
    let contactInfo =
        jsonGet(body, "contactInfo").strVal
    if (title.size == 0) {
        return failResp(1005,
            "标题不能为空")
    }
    let itemType = match (typeStr) {
        case "LOSTFOUND" => ItemType.LostFound
        case _ => ItemType.SecondHand
    }
    let reqDto = PublishItemReq(
        title, description, catId,
        itemType, imageUrl, contactInfo)
    let itemSvc =
        ItemBaseService.getInstance()
    let pubRes = itemSvc.publish(
        token, reqDto)
    match (pubRes.data) {
        case Some(item) =>
            let data = jsonObj()
            jsonPut(data, "id",
                jsonInt(item.id))
            return HttpResponse()
                .setStatus(201)
                .setBody(respToJson(
                    0, "ok", data))
        case None =>
            return failResp(1005, pubRes.msg)
    }
}

public func handleListPosts(
    req: HttpRequest
): HttpResponse {
    let itemSvc =
        ItemBaseService.getInstance()
    let typeStr =
        getQueryParam(req.query, "itemType")
    let (page, pageSize) =
        parseQueryPage(req.query)
    var items: ArrayList<BaseItem>
    if (typeStr.size > 0) {
        let t = match (typeStr) {
            case "LOSTFOUND" =>
                ItemType.LostFound
            case _ => ItemType.SecondHand
        }
        match (itemSvc.listByType(t).data) {
            case Some(list) => items = list
            case None =>
                items = ArrayList<BaseItem>()
        }
    } else {
        match (itemSvc.listPage(
            page, pageSize).data) {
            case Some(pr) =>
                items = ArrayList(pr.list)
            case None =>
                items = ArrayList<BaseItem>()
        }
    }
    let arr = jsonArr()
    for (i in 0..items.size) {
        let item = items[i]
        if (item.status !=
            ItemStatus.Approved) {
            continue
        }
        jsonPush(arr, itemToJson(item))
    }
    let total = Int64(items.size)
    let wrap = jsonObj()
    jsonPut(wrap, "list", arr)
    jsonPut(wrap, "page",
        jsonInt(page))
    jsonPut(wrap, "pageSize",
        jsonInt(pageSize))
    jsonPut(wrap, "total",
        jsonInt(total))
    return okResp(wrap)
}

public func handleMyPosts(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    match (auth.whoami(token).data) {
        case Some(u) =>
            let itemSvc =
                ItemBaseService.getInstance()
            let (page, pageSize) =
                parseQueryPage(req.query)
            match (itemSvc.listPage(
                1, 1000).data) {
                case Some(pr) =>
                    let arr = jsonArr()
                    for (i in 0..pr.list.size) {
                        if (pr.list[i]
                            .publisherId == u.id) {
                            jsonPush(arr,
                                itemToJson(
                                    pr.list[i]))
                        }
                    }
                    let total =
                        Int64(arr.arrVal.size)
                    let wrap = jsonObj()
                    jsonPut(wrap, "list", arr)
                    jsonPut(wrap, "page",
                        jsonInt(page))
                    jsonPut(wrap, "pageSize",
                        jsonInt(pageSize))
                    jsonPut(wrap, "total",
                        jsonInt(total))
                    return okResp(wrap)
                case None =>
                    return okResp(jsonObj())
            }
        case None =>
            return failResp(1003, "未登录")
    }
}

public func handleGetPost(
    req: HttpRequest
): HttpResponse {
    let idStr = req.params.get("id")
    var itemId: Int64 = 0
    if (let Some(s) <- idStr) {
        itemId = strToInt64(s)
    }
    if (itemId <= 0) {
        return failResp(1005,
            "无效的物品ID")
    }
    let itemSvc =
        ItemBaseService.getInstance()
    match (itemSvc.getById(itemId).data) {
        case Some(item) =>
            let detail = itemToJson(item)
            let token = extractToken(req)
            var fav = false
            if (token.size > 0) {
                let auth =
                    AuthService.getInstance()
                match (auth.whoami(token)
                    .data) {
                    case Some(u) =>
                        fav = isFavorited(
                            u.id, itemId)
                    case None => ()
                }
            }
            jsonPut(detail, "isFavorited",
                jsonBool(fav))
            return okResp(detail)
        case None =>
            return failResp(1006,
                "物品不存在")
    }
}

public func handleUpdatePost(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    let idStr = req.params.get("id")
    var itemId: Int64 = 0
    if (let Some(s) <- idStr) {
        itemId = strToInt64(s)
    }
    if (itemId <= 0) {
        return failResp(1005,
            "无效的物品ID")
    }
    let itemSvc =
        ItemBaseService.getInstance()
    match (itemSvc.getById(itemId).data) {
        case Some(item) =>
            match (auth.whoami(token).data) {
                case Some(u) =>
                    if (item.publisherId !=
                        u.id) {
                        return failResp(1004,
                            "无权限")
                    }
                case None =>
                    return failResp(1003,
                        "未登录")
            }
            let body = jsonParse(req.body)
            let title =
                jsonGet(body, "title").strVal
            let description =
                jsonGet(body, "description")
                .strVal
            let imageUrl =
                jsonGet(body, "imageUrl")
                .strVal
            let contactInfo =
                jsonGet(body, "contactInfo")
                .strVal
            if (title.size > 0) {
                item.title = title
            }
            if (description.size > 0) {
                item.description = description
            }
            if (imageUrl.size > 0) {
                item.imageUrl = imageUrl
            }
            if (contactInfo.size > 0) {
                item.contactInfo = contactInfo
            }
            item.status = ItemStatus.Pending
            let repo =
                ItemRepository.getInstance()
            repo.save(item)
            return okResp(itemToJson(item))
        case None =>
            return failResp(1006,
                "物品不存在")
    }
}

public func handleDeletePost(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let idStr = req.params.get("id")
    var itemId: Int64 = 0
    if (let Some(s) <- idStr) {
        itemId = strToInt64(s)
    }
    if (itemId <= 0) {
        return failResp(1005,
            "无效的物品ID")
    }
    let itemSvc =
        ItemBaseService.getInstance()
    let closeRes = itemSvc.close(
        token, itemId)
    match (closeRes.data) {
        case Some(_) =>
            return HttpResponse()
                .setStatus(200)
                .setBody(respToJson(
                    0, "ok",
                    jsonBool(true)))
        case None =>
            return failResp(1006,
                closeRes.msg)
    }
}

// ===== Favorite handlers =====
public func handleAddFav(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    match (auth.whoami(token).data) {
        case Some(u) =>
            let idStr =
                req.params.get("id")
            var itemId: Int64 = 0
            if (let Some(s) <- idStr) {
                itemId = strToInt64(s)
            }
            if (itemId <= 0) {
                return failResp(1005,
                    "无效的物品ID")
            }
            let itemSvc =
                ItemBaseService.getInstance()
            match (itemSvc.getById(itemId)
                .data) {
                case Some(_) =>
                    let added = addFavorite(
                        u.id, itemId)
                    if (!added) {
                        return failResp(1007,
                            "已收藏")
                    }
                    let data = jsonObj()
                    jsonPut(data, "favorited",
                        jsonBool(true))
                    return okResp(data)
                case None =>
                    return failResp(1006,
                        "物品不存在")
            }
        case None =>
            return failResp(1003, "未登录")
    }
}

public func handleRemoveFav(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    match (auth.whoami(token).data) {
        case Some(u) =>
            let idStr =
                req.params.get("id")
            var itemId: Int64 = 0
            if (let Some(s) <- idStr) {
                itemId = strToInt64(s)
            }
            if (itemId <= 0) {
                return failResp(1005,
                    "无效的物品ID")
            }
            let removed = removeFavorite(
                u.id, itemId)
            if (!removed) {
                return failResp(1008,
                    "未收藏")
            }
            let data = jsonObj()
            jsonPut(data, "favorited",
                jsonBool(false))
            return okResp(data)
        case None =>
            return failResp(1003, "未登录")
    }
}

public func handleListFavs(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let auth = AuthService.getInstance()
    match (auth.whoami(token).data) {
        case Some(u) =>
            let favIds = getFavIds(u.id)
            let itemSvc =
                ItemBaseService.getInstance()
            let arr = jsonArr()
            for (i in 0..favIds.size) {
                match (itemSvc.getById(
                    favIds[i]).data) {
                    case Some(item) =>
                        jsonPush(arr,
                            itemToJson(item))
                    case None => ()
                }
            }
            let total = favIds.size
            let (page, pageSize) =
                parseQueryPage(req.query)
            let wrap = jsonObj()
            jsonPut(wrap, "list", arr)
            jsonPut(wrap, "page",
                jsonInt(page))
            jsonPut(wrap, "pageSize",
                jsonInt(pageSize))
            jsonPut(wrap, "total",
                jsonInt(total))
            return okResp(wrap)
        case None =>
            return failResp(1003, "未登录")
    }
}

// ===== Image upload handler =====
public func handleUpload(
    req: HttpRequest
): HttpResponse {
    let token = extractToken(req)
    if (token.size == 0) {
        return failResp(1003, "未登录")
    }
    let ctOpt =
        req.headers.get("Content-Type")
    var ext = ".jpg"
    if (let Some(ct) <- ctOpt) {
        if (ct.contains("png")) {
            ext = ".png"
        }
        if (ct.contains("gif")) {
            ext = ".gif"
        }
        if (ct.contains("webp")) {
            ext = ".webp"
        }
    }
    let filename =
        "${DateTime.now().toString()}" +
        "_${req.rawBody.size}" + ext
    let dir = Path(UPLOAD_DIR)
    if (!exists(dir)) {
        Directory.create(dir,
            recursive: false)
    }
    File.writeTo(
        dir.join(filename),
        req.rawBody)
    let data = jsonObj()
    jsonPut(data, "url",
        jsonStr(
            "/uploads/" + filename))
    return HttpResponse()
        .setStatus(201)
        .setBody(respToJson(
            0, "ok", data))
}
