package cangjie

main(): Int64 {
    mockDataInit()

    let auth = AuthService.getInstance()
    let postSvc = PostBaseService.getInstance()
    let catSvc = CategoryService.getInstance()
    let tradeSvc = TradeService.getInstance()
    let claimSvc = ClaimService.getInstance()
    let enhAdmin = EnhancedAdminService.getInstance()
    let msgSvc = MessageService.getInstance()
    let searchSvc = SearchService.getInstance()
    let statsSvc = StatisticsService.getInstance()

    // ======== 基础模块 ========
    sep("=== 分类列表 ===")
    println(catSvc.listAll().toString())

    sep("=== 注册 charlie ===")
    println(auth.register(
        "charlie", "pass123",
        "Charlie", "13800003333"
    ).toString())

    sep("=== 重复注册（应报错）===")
    println(auth.register(
        "charlie", "pass123",
        "Charlie", "13800003333"
    ).toString())

    sep("=== 登录 charlie ===")
    let loginRes = auth.login("charlie", "pass123")
    println(loginRes.toString())
    let token = match (loginRes.data) {
        case Some(t) => t
        case None    => ""
    }

    sep("=== 查看当前用户 ===")
    println(auth.whoami(token).toString())

    sep("=== 发布二手商品 ===")
    let req = PublishPostReq(
        1, BusinessType.SecondHand,
        "二手笔记本电脑",
        "ThinkPad X1，8成新",
        Some(2500.0),
        "学院路校区",
        "[]",
        "微信: charlie_sell"
    )
    let pubRes = postSvc.publish(token, req)
    println(pubRes.toString())
    let newId = match (pubRes.data) {
        case Some(p) => p.id
        case None    => -1
    }

    // ======== 管理员审核 ========
    sep("=== 管理员登录 ===")
    let admLogin = auth.login("admin", "admin123")
    println(admLogin.toString())
    let admToken = match (admLogin.data) {
        case Some(t) => t
        case None    => ""
    }

    sep("=== [增强审核] 审核通过 ===")
    println(enhAdmin.approveWithRecord(
        admToken, newId
    ).toString())

    sep("=== [增强审核] 查看审核历史 ===")
    println(enhAdmin.getAuditHistory(
        admToken, newId
    ).toString())

    // ======== Request 交易流程 ========
    sep("=== bob 登录 ===")
    let bobLogin = auth.login("bob", "pass123")
    println(bobLogin.toString())
    let bobToken = match (bobLogin.data) {
        case Some(t) => t
        case None    => ""
    }

    sep("=== [Request] bob 发起购买申请 ===")
    let buyRes = tradeSvc.requestBuy(
        bobToken, newId, "我今晚可以自提"
    )
    println(buyRes.toString())
    let reqId = match (buyRes.data) {
        case Some(r) => r.id
        case None    => -1
    }

    sep("=== [Request] 自己买自己（应报错）===")
    println(tradeSvc.requestBuy(
        token, newId, "test"
    ).toString())

    sep("=== [Request] charlie 接受申请 → RESERVED ===")
    println(tradeSvc.acceptRequest(
        token, reqId
    ).toString())

    sep("=== [Request] 已完成交易 → SOLD ===")
    println(tradeSvc.doneRequest(
        token, reqId
    ).toString())

    // ======== 失物认领流程 ========
    sep("=== 发布失物信息 ===")
    let lostReq = PublishPostReq(
        5, BusinessType.LOST,
        "黑色钱包",
        "图书馆3楼捡到，内有身份证",
        None, "沙河校区", "[]",
        "联系: charlie"
    )
    let lostPub = postSvc.publish(token, lostReq)
    println(lostPub.toString())
    let lostId = match (lostPub.data) {
        case Some(p) => p.id
        case None    => -1
    }

    sep("=== 审核通过失物 ===")
    println(enhAdmin.approveWithRecord(
        admToken, lostId
    ).toString())

    sep("=== [Request] bob 发起认领申请 ===")
    let claimRes = claimSvc.requestClaim(
        bobToken, lostId, "这是我的钱包"
    )
    println(claimRes.toString())
    let claimReqId = match (claimRes.data) {
        case Some(r) => r.id
        case None    => -1
    }

    sep("=== [Request] 不能认领自己的失物 ===")
    println(claimSvc.requestClaim(
        token, lostId, "test"
    ).toString())

    sep("=== [Request] charlie 接受认领 → MATCHING ===")
    println(claimSvc.acceptClaim(
        token, claimReqId
    ).toString())

    sep("=== [Request] 完成认领 → CLAIMED ===")
    println(claimSvc.doneClaim(
        token, claimReqId
    ).toString())

    // ======== 留言 / 私信 ========
    sep("=== [留言] bob 留言 ===")
    println(msgSvc.postComment(
        bobToken, 1, "这个还在吗？", None
    ).toString())

    sep("=== [留言] charlie 回复 ===")
    println(msgSvc.postComment(
        token, 1, "还在的！", None
    ).toString())

    sep("=== [留言] 查看留言列表 ===")
    println(msgSvc.getComments(1, 1, 10).toString())

    sep("=== [私信] bob→charlie ===")
    println(msgSvc.sendPrivateMsg(
        bobToken, 4, Some(1),
        "你好，我想买你的电脑"
    ).toString())

    sep("=== [私信] charlie 未读私信数 ===")
    println(msgSvc.getUnreadCount(token).toString())

    // ======== 搜索 ========
    sep("=== [搜索] 关键词'电脑' ===")
    let sp1 = SearchParams()
    sp1.keyword = "电脑"
    println(searchSvc.search(sp1).toString())

    sep("=== [搜索] 筛选二手 ===")
    let sp2 = SearchParams()
    sp2.businessType = Some(BusinessType.SecondHand)
    println(searchSvc.search(sp2).toString())

    sep("=== [搜索] 筛选失物 ===")
    let sp3 = SearchParams()
    sp3.businessType = Some(BusinessType.LOST)
    println(searchSvc.search(sp3).toString())

    // ======== 统计 ========
    sep("=== [统计] 平台总览 ===")
    println(statsSvc.getOverview().toString())

    sep("=== [统计] 状态分布 ===")
    println(statsSvc.getStatusDistribution().toString())

    // ======== 边界情况 ========
    sep("=== [边界] 驳回审核（需原因）===")
    let badReq = PublishPostReq(
        1, BusinessType.SecondHand,
        "违规商品", "测试",
        Some(1.0), "", "[]", ""
    )
    match (postSvc.publish(token, badReq).data) {
        case Some(p) =>
            println(enhAdmin.rejectWithRecord(
                admToken, p.id, "信息不实"
            ).toString())
        case None => ()
    }

    sep("=== [边界] 登出后操作（应401）===")
    println(auth.logout(bobToken).toString())
    println(tradeSvc.requestBuy(
        bobToken, 1, "test"
    ).toString())

    return 0
}

func sep(title: String): Unit {
    println("\n" + title)
}
