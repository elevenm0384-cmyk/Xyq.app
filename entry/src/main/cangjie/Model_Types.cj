package ohos_app_cangjie_entry

// 鍚庣娴嬭瘯鐢?- 绫诲瀷甯搁噺鍜屽伐鍏峰嚱鏁?
internal import ohos.base.*
internal import cj_res_entry.app
import ohos.state_macro_manage.r

public let ROLE_USER: String = "USER"
public let ROLE_ADMIN: String = "ADMIN"

public let STATUS_ACTIVE: String = "ACTIVE"

public let BIZ_TYPE_SECONDHAND: String = "SECONDHAND"
public let BIZ_TYPE_LOST: String = "LOST"
public let BIZ_TYPE_FOUND: String = "FOUND"

public let AUDIT_PENDING: String = "PENDING"
public let AUDIT_APPROVED: String = "APPROVED"
public let AUDIT_REJECTED: String = "REJECTED"

public let BIZ_ON_SALE: String = "ON_SALE"
public let BIZ_SOLD: String = "SOLD"

public let BIZ_OPEN: String = "OPEN"
public let BIZ_CLAIMED: String = "CLAIMED"

public let MSG_PUBLIC_COMMENT: String = "PUBLIC_COMMENT"
public let MSG_PRIVATE_MESSAGE: String = "PRIVATE_MESSAGE"

public let SCENE_SECONDHAND: String = "SECONDHAND"
public let SCENE_LOST: String = "LOST"
public let SCENE_ALL: String = "ALL"

public let SORT_LATEST: String = "latest"

public func getCurrentTimestamp(): String {
    return "2026-04-30 18:00:00"
}

public func getBizTypeLabel(t: String): String {
    if (t == BIZ_TYPE_SECONDHAND) { return "二手商品" }
    if (t == BIZ_TYPE_LOST) { return "失物" }
    if (t == BIZ_TYPE_FOUND) { return "招领" }
    return t
}

public func getAuditLabel(s: String): String {
    if (s == AUDIT_PENDING) { return "待审核" }
    if (s == AUDIT_APPROVED) { return "已通过" }
    if (s == AUDIT_REJECTED) { return "已驳回" }
    return s
}

public func getBizLabel(bt: String, bs: String): String {
    if (bt == BIZ_TYPE_SECONDHAND) {
        if (bs == BIZ_ON_SALE) { return "在售" }
        if (bs == BIZ_SOLD) { return "已售出" }
    } else {
        if (bs == BIZ_OPEN) { return "待认领" }
        if (bs == BIZ_CLAIMED) { return "已认领" }
    }
    return bs
}

public func getDefaultBizStatus(bt: String): String {
    if (bt == BIZ_TYPE_SECONDHAND) { return BIZ_ON_SALE }
    return BIZ_OPEN
}

public func getImageResource(name: String): CJResource {
    if (name == "pdt_camera") { return @r(app.media.pdt_camera) }
    if (name == "pdt_lamp") { return @r(app.media.pdt_lamp) }
    if (name == "pdt_bike") { return @r(app.media.pdt_bike) }
    if (name == "lost_bag") { return @r(app.media.lost_bag) }
    if (name == "lost_card") { return @r(app.media.lost_card) }
    if (name == "lost_airpods") { return @r(app.media.lost_airpods) }
    if (name == "lost_book") { return @r(app.media.lost_book) }
    if (name == "lost_classes") { return @r(app.media.lost_classes) }
    if (name == "icon_digital") { return @r(app.media.icon_digital) }
    if (name == "icon_book") { return @r(app.media.icon_book) }
    if (name == "icon_life") { return @r(app.media.icon_life) }
    if (name == "icon_clothes") { return @r(app.media.icon_clothes) }
    if (name == "icon_sport") { return @r(app.media.icon_sport) }
    if (name == "icon_beauty") { return @r(app.media.icon_beauty) }
    if (name == "icon_pet") { return @r(app.media.icon_pet) }
    if (name == "icon_campus") { return @r(app.media.icon_campus) }
    if (name == "locallg") { return @r(app.media.locallg) }
    if (name == "jiantou") { return @r(app.media.jiantou) }
    if (name == "changelg") { return @r(app.media.changelg) }
    if (name == "homebg") { return @r(app.media.homebg) }
    if (name == "startIcon") { return @r(app.media.startIcon) }
    if (name == "background") { return @r(app.media.background) }
    if (name == "foreground") { return @r(app.media.foreground) }
    if (name == "logo") { return @r(app.media.logo) }
    return @r(app.media.start)
}

public func getCategoryIcon(name: String): CJResource {
    if (name == "鐢靛瓙鏁扮爜") { return @r(app.media.icon_digital) }
    if (name == "鍥句功鏁欐潗") { return @r(app.media.icon_book) }
    if (name == "鐢熸椿鐢ㄥ搧") { return @r(app.media.icon_life) }
    if (name == "鏈嶉グ绠卞寘") { return @r(app.media.icon_clothes) }
    if (name == "杩愬姩鎴峰") { return @r(app.media.icon_sport) }
    if (name == "缇庡楗板搧") { return @r(app.media.icon_beauty) }
    if (name == "瀹犵墿鐢ㄥ搧") { return @r(app.media.icon_pet) }
    if (name == "鏍″洯鐢熸椿") { return @r(app.media.icon_campus) }
    if (name == "璇佷欢") { return @r(app.media.icon_book) }
    if (name == "涔﹀寘") { return @r(app.media.lost_bag) }
    if (name == "鐢靛瓙浜у搧") { return @r(app.media.icon_digital) }
    if (name == "涔︾睄") { return @r(app.media.icon_book) }
    if (name == "鐪奸暅") { return @r(app.media.lost_classes) }
    if (name == "閽ュ寵") { return @r(app.media.lost_bag) }
    if (name == "姘存澂") { return @r(app.media.icon_life) }
    if (name == "鍏朵粬") { return @r(app.media.startIcon) }
    return @r(app.media.icon_campus)
}

