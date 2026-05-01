package cangjie

main(): Int64 {
    // 初始化 Mock 数据
    mockDataInit()

    let auth =
        AuthService.getInstance()
    let itemSvc =
        ItemBaseService.getInstance()
    let catSvc =
        CategoryService.getInstance()
    let tradeSvc =
        TradeService.getInstance()
    let claimSvc =
        ClaimService.getInstance()
    let enhAdminSvc =
        EnhancedAdminService.getInstance()
    let msgSvc =
        MessageService.getInstance()
    let searchSvc =
        SearchService.getInstance()
    let statsSvc =
        StatisticsService.getInstance()

    // ======== 基础模块（3号）========
    sep("=== 分类列表 ===")
    println(catSvc.listAll().toString())

    sep("=== 注册新用户 ===")
    println(auth.register(
        "charlie", "pass123",
        "charlie@campus.edu"
    ).toString())

    sep("=== 重复注册（应报错）===")
    println(auth.register(
        "charlie", "pass123",
        "charlie@campus.edu"
    ).toString())

    sep("=== 登录 charlie ===")
    let loginRes = auth.login(
        "charlie", "pass123"
    )
    println(loginRes.toString())
    let token = match (loginRes.data) {
        case Some(t) => t
        case None    => ""
    }

    sep("=== 查看当前用户 ===")
    println(auth.whoami(token).toString())

    sep("=== 发布二手物品 ===")
    let req = PublishItemReq(
        "二手笔记本电脑",
        "ThinkPad X1，8成新",
        2,
        ItemType.SecondHand,
        "",
        "微信: charlie_sell"
    )
    let pubRes = itemSvc.publish(token, req)
    println(pubRes.toString())
    let newItemId = match (pubRes.data) {
        case Some(item) => item.id
        case None       => -1
    }

    sep("=== 管理员登录 ===")
    let adminLogin = auth.login(
        "admin", "admin123"
    )
    println(adminLogin.toString())
    let adminToken = match (adminLogin.data) {
        case Some(t) => t
        case None    => ""
    }

    sep("=== [增强审核] 管理员审核通过 ===")
    println(
        enhAdminSvc.approveWithRecord(
            adminToken, newItemId
        ).toString()
    )

    sep("=== [增强审核] 查看审核历史 ===")
    println(
        enhAdminSvc.getReviewHistory(
            adminToken, newItemId
        ).toString()
    )

    // ======== 交易状态机（4号）========
    sep("=== [交易] 买家 bob 登录 ===")
    let bobLogin = auth.login(
        "bob", "pass123"
    )
    println(bobLogin.toString())
    let bobToken = match (bobLogin.data) {
        case Some(t) => t
        case None    => ""
    }

    sep("=== [交易] bob 购买 charlie 的商品 ===")
    println(
        tradeSvc.reserve(
            bobToken, newItemId
        ).toString()
    )

    sep("=== [交易] 重复购买（应报错）===")
    println(
        tradeSvc.reserve(
            bobToken, newItemId
        ).toString()
    )

    sep("=== [交易] 取消交易 ===")
    println(
        tradeSvc.cancelTrade(
            bobToken, newItemId
        ).toString()
    )

    sep("=== [交易] 自己买自己（应报错）===")
    println(
        tradeSvc.reserve(
            token, newItemId
        ).toString()
    )

    sep("=== [交易] 再次购买 ===")
    println(
        tradeSvc.reserve(
            bobToken, newItemId
        ).toString()
    )

    sep("=== [交易] charlie 确认交易完成 ===")
    println(
        tradeSvc.completeTrade(
            token, newItemId
        ).toString()
    )

    // ======== 失物认领状态机（4号）========
    sep("=== [认领] 发布失物招领 ===")
    let lostReq = PublishItemReq(
        "黑色钱包",
        "图书馆3楼捡到，请失主认领",
        5,
        ItemType.LostFound,
        "",
        "联系: charlie_found"
    )
    let lostPubRes =
        itemSvc.publish(token, lostReq)
    println(lostPubRes.toString())
    let lostId = match (lostPubRes.data) {
        case Some(item) => item.id
        case None       => -1
    }

    sep("=== [增强审核] 审核通过失物 ===")
    println(
        enhAdminSvc.approveWithRecord(
            adminToken, lostId
        ).toString()
    )

    sep("=== [认领] bob 认领失物 ===")
    println(
        claimSvc.claim(
            bobToken, lostId
        ).toString()
    )

    sep("=== [认领] 重复认领（应报错）===")
    println(
        claimSvc.claim(
            bobToken, lostId
        ).toString()
    )

    sep("=== [认领] 不能认领自己的失物 ===")
    println(
        claimSvc.claim(token, lostId)
            .toString()
    )

    sep("=== [认领] charlie 确认已归还 ===")
    println(
        claimSvc.confirmReturn(
            token, lostId
        ).toString()
    )

    // ======== 留言/私信（4号）========
    sep("=== [留言] bob 给商品留言 ===")
    println(
        msgSvc.postComment(
            bobToken, "item", 1,
            "这个电脑还在吗？"
        ).toString()
    )

    sep("=== [留言] charlie 回复 ===")
    println(
        msgSvc.postComment(
            token, "item", 1,
            "还在的，可以私聊"
        ).toString()
    )

    sep("=== [留言] 查看留言列表 ===")
    println(
        msgSvc.getComments(
            "item", 1, 1, 10
        ).toString()
    )

    sep("=== [私信] bob 给 charlie 发私信 ===")
    println(
        msgSvc.sendPrivateMsg(
            bobToken, 4, "item", 1,
            "你好，我想买你的电脑"
        ).toString()
    )

    sep("=== [私信] charlie 查看未读私信数 ===")
    println(
        msgSvc.getUnreadCount(token)
            .toString()
    )

    // ======== 搜索（4号）========
    sep("=== [搜索] 关键词'电脑' ===")
    let sp1 = SearchParams()
    sp1.keyword = "电脑"
    sp1.page = 1
    sp1.pageSize = 10
    println(searchSvc.search(sp1).toString())

    sep("=== [搜索] 筛选二手+教材分类 ===")
    let sp2 = SearchParams()
    sp2.itemType = Some(ItemType.SecondHand)
    sp2.categoryId = Some(1)
    sp2.page = 1
    sp2.pageSize = 10
    println(searchSvc.search(sp2).toString())

    sep("=== [搜索] 筛选失物招领 ===")
    let sp3 = SearchParams()
    sp3.itemType = Some(ItemType.LostFound)
    sp3.page = 1
    sp3.pageSize = 10
    println(searchSvc.search(sp3).toString())

    // ======== 统计（4号）========
    sep("=== [统计] 平台总览 ===")
    println(statsSvc.getOverview().toString())

    sep("=== [统计] 热门分类 ===")
    println(statsSvc.getHotCategories().toString())

    sep("=== [统计] 状态分布 ===")
    println(
        statsSvc.getStatusDistribution()
            .toString()
    )

    // ======== 边界情况 ========
    sep("=== [边界] 下架商品 ===")
    // 先发一个新商品并审核通过
    let req2 = PublishItemReq(
        "台灯", "护眼LED台灯",
        3, ItemType.SecondHand, "",
        "微信: charlie_sell"
    )
    match (itemSvc.publish(token, req2).data) {
        case Some(item) =>
            enhAdminSvc.approveWithRecord(
                adminToken, item.id
            )
            sep("=== [边界] charlie 下架 ===")
            println(
                tradeSvc.delist(
                    token, item.id
                ).toString()
            )
            sep("=== [边界] 下架后不可购买 ===")
            println(
                tradeSvc.reserve(
                    bobToken, item.id
                ).toString()
            )
            sep("=== [边界] 重新上架 ===")
            println(
                tradeSvc.relist(
                    token, item.id
                ).toString()
            )
        case None => ()
    }

    sep("=== [边界] 驳回审核（需填原因）===")
    let req3 = PublishItemReq(
        "违规商品", "测试驳回",
        1, ItemType.SecondHand, "", ""
    )
    match (itemSvc.publish(token, req3).data) {
        case Some(item) =>
            println(
                enhAdminSvc.rejectWithRecord(
                    adminToken, item.id,
                    "商品信息不实，请修改后重新提交"
                ).toString()
            )
            sep("=== [边界] 审核历史（含驳回）===")
            println(
                enhAdminSvc.getReviewHistory(
                    adminToken, item.id
                ).toString()
            )
        case None => ()
    }

    sep("=== [边界] 登出后操作（应401）===")
    println(auth.logout(token).toString())
    println(
        tradeSvc.reserve(token, 1)
            .toString()
    )

    return 0
}

func sep(title: String): Unit {
    println("\n" + title)
}
