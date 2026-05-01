package cangjie

import std.collection.*

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

    // ═══════════════════════════════════════════
    //  一、用户系统
    // ═══════════════════════════════════════════
    sep("一、用户系统")

    // 1.1 分类
    let cats = catSvc.listAll().data
    println("【1.1 分类列表】")
    printCats(cats)

    // 1.2 注册
    let regRes = auth.register(
        "charlie", "pass123", "Charlie", "13800003333"
    )
    println("【1.2 注册 charlie】→ code=" + regRes.code.toString())
    printUser(regRes)

    // 1.3 重复注册
    let dupReg = auth.register(
        "charlie", "pass123", "Charlie", "13800003333"
    )
    println("【1.3 重复注册（应报错）】→ code=" +
        dupReg.code.toString() +
        " message=" + dupReg.message)

    // 1.4 登录
    let loginRes = auth.login("charlie", "pass123")
    let token = match (loginRes.data) {
        case Some(t) => t
        case None    => ""
    }
    println("【1.4 登录 charlie】→ token=" + token)

    // 1.5 当前用户
    let me = auth.whoami(token)
    println("【1.5 查看当前用户】")
    printUserDetail(me)

    // ═══════════════════════════════════════════
    //  二、商品发布 + 审核
    // ═══════════════════════════════════════════
    sep("二、商品发布 + 审核")

    // 2.1 发布
    let req = PublishPostReq(
        1, BusinessType.SecondHand,
        "二手笔记本电脑",
        "ThinkPad X1 Carbon，8成新，i7处理器",
        Some(2500.0),
        "学院路校区",
        "[\"laptop1.png\",\"laptop2.png\"]",
        "微信: charlie_sell"
    )
    let pub = postSvc.publish(token, req)
    let post = match (pub.data) {
        case Some(p) => p
        case None    => Post(
            0, 0, 0, BusinessType.SecondHand,
            "", "", None, "", "", ""
        )
    }
    println("【2.1 发布商品】")
    printPost(post)

    // 2.2 管理员审核
    let admLogin = auth.login("admin", "admin123")
    let admToken = match (admLogin.data) {
        case Some(t) => t
        case None    => ""
    }
    let approved = enhAdmin.approveWithRecord(
        admToken, post.id
    )
    println("【2.2 管理员审核通过】→ code=" +
        approved.code.toString())
    match (approved.data) {
        case Some(p) => printPost(p)
        case None    => println("  (无数据)")
    }

    // 2.3 审核历史
    let hist = enhAdmin.getAuditHistory(admToken, post.id)
    println("【2.3 审核历史】")
    printAuditHistory(hist)

    // ═══════════════════════════════════════════
    //  三、二手交易 Request 流程
    // ═══════════════════════════════════════════
    sep("三、二手交易 Request 流程")

    let bobLogin = auth.login("bob", "pass123")
    let bobToken = match (bobLogin.data) {
        case Some(t) => t
        case None    => ""
    }

    // 3.1 bob 发起购买
    let buy = tradeSvc.requestBuy(
        bobToken, post.id, "我今晚可以自提，现金交易"
    )
    println("【3.1 bob 发起 BUY 申请】→ code=" +
        buy.code.toString())
    printRequest(buy)

    // 3.2 自己买自己
    let selfBuy = tradeSvc.requestBuy(
        token, post.id, "test"
    )
    println("【3.2 自己买自己（应报错）】→ code=" +
        selfBuy.code.toString() +
        " " + selfBuy.message)

    // 3.3 卖家接受 → RESERVED
    let buyReq = match (buy.data) {
        case Some(r) => r
        case None    => Request(
            0, 0, 0, RequestType.BUY, "", ""
        )
    }
    let accept = tradeSvc.acceptRequest(token, buyReq.id)
    println("【3.3 charlie 接受申请 → post 变为 RESERVED】")
    printRequest(accept)
    match (postSvc.getById(post.id).data) {
        case Some(p) => println("  post.bizStatus = " +
            p.bizStatus.toString())
        case None => ()
    }

    // 3.4 完成交易 → SOLD
    let done = tradeSvc.doneRequest(token, buyReq.id)
    println("【3.4 完成交易 → post 变为 SOLD】")
    printRequest(done)
    match (postSvc.getById(post.id).data) {
        case Some(p) => println("  post.bizStatus = " +
            p.bizStatus.toString())
        case None => ()
    }

    // ═══════════════════════════════════════════
    //  四、失物认领 Request 流程
    // ═══════════════════════════════════════════
    sep("四、失物认领 Request 流程")

    // 4.1 发布失物
    let lostReq = PublishPostReq(
        5, BusinessType.LOST,
        "黑色钱包",
        "图书馆3楼捡到，内有身份证和校园卡",
        None, "沙河校区",
        "[\"wallet.jpg\"]",
        "联系: charlie"
    )
    let lostPub = postSvc.publish(token, lostReq)
    let lostPost = match (lostPub.data) {
        case Some(p) => p
        case None    => Post(
            0, 0, 0, BusinessType.LOST,
            "", "", None, "", "", ""
        )
    }
    println("【4.1 发布失物（LOST）】")
    printPost(lostPost)

    // 4.2 审核通过
    enhAdmin.approveWithRecord(admToken, lostPost.id)
    println("【4.2 审核通过 → bizStatus=OPEN】→ OK")

    // 4.3 bob 认领
    let claim = claimSvc.requestClaim(
        bobToken, lostPost.id, "这是我的钱包，里面有我的身份证"
    )
    println("【4.3 bob 发起 CLAIM 申请】→ code=" +
        claim.code.toString())
    printRequest(claim)

    // 4.4 不能认领自己的
    let selfClaim = claimSvc.requestClaim(
        token, lostPost.id, "test"
    )
    println("【4.4 不能认领自己的（应报错）】→ code=" +
        selfClaim.code.toString() +
        " " + selfClaim.message)

    // 4.5 接受认领 → MATCHING
    let claimReq = match (claim.data) {
        case Some(r) => r
        case None    => Request(
            0, 0, 0, RequestType.CLAIM, "", ""
        )
    }
    let acceptCl = claimSvc.acceptClaim(token, claimReq.id)
    println("【4.5 charlie 接受认领 → MATCHING】")
    printRequest(acceptCl)
    match (postSvc.getById(lostPost.id).data) {
        case Some(p) => println("  post.bizStatus = " +
            p.bizStatus.toString())
        case None => ()
    }

    // 4.6 完成认领 → CLAIMED
    let doneCl = claimSvc.doneClaim(token, claimReq.id)
    println("【4.6 完成认领 → CLAIMED】")
    printRequest(doneCl)
    match (postSvc.getById(lostPost.id).data) {
        case Some(p) => println("  post.bizStatus = " +
            p.bizStatus.toString())
        case None => ()
    }

    // ═══════════════════════════════════════════
    //  五、留言 + 私信
    // ═══════════════════════════════════════════
    sep("五、留言 + 私信")

    // 5.1 公开留言
    msgSvc.postComment(bobToken, 1, "这个还在吗？", None)
    msgSvc.postComment(token, 1, "还在的！可以私聊", None)
    let comments = msgSvc.getComments(1, 1, 10)
    println("【5.1 商品留言列表（共2条）】")
    printMessages(comments)

    // 5.2 私信
    let pm = msgSvc.sendPrivateMsg(
        bobToken, 4, Some(post.id),
        "你好，我想买你的电脑，今晚方便吗？"
    )
    println("【5.2 bob→charlie 私信】→ code=" +
        pm.code.toString())
    printMessageData(pm)

    // 5.3 未读数
    let unread = msgSvc.getUnreadCount(token)
    match (unread.data) {
        case Some(c) => println("【5.3 charlie 未读私信数】= " +
            c.toString())
        case None => ()
    }

    // ═══════════════════════════════════════════
    //  六、搜索
    // ═══════════════════════════════════════════
    sep("六、搜索")

    let sp1 = SearchParams()
    sp1.keyword = "电脑"
    sp1.pageSize = 10
    let sr1 = searchSvc.search(sp1)
    println("【6.1 关键词 '电脑'】→ 找到 " +
        printSearchCount(sr1) + " 条")

    let sp2 = SearchParams()
    sp2.businessType = Some(BusinessType.SecondHand)
    sp2.pageSize = 10
    let sr2 = searchSvc.search(sp2)
    println("【6.2 筛选 二手商品】→ 找到 " +
        printSearchCount(sr2) + " 条")

    let sp3 = SearchParams()
    sp3.businessType = Some(BusinessType.LOST)
    sp3.pageSize = 10
    let sr3 = searchSvc.search(sp3)
    println("【6.3 筛选 失物】→ 找到 " +
        printSearchCount(sr3) + " 条")

    // ═══════════════════════════════════════════
    //  七、数据统计
    // ═══════════════════════════════════════════
    sep("七、数据统计")

    let overview = statsSvc.getOverview()
    println("【7.1 平台总览】")
    printOverview(overview)

    let dist = statsSvc.getStatusDistribution()
    println("【7.2 业务状态分布】")
    printStatusDist(dist)

    // ═══════════════════════════════════════════
    //  八、边界情况
    // ═══════════════════════════════════════════
    sep("八、边界情况")

    // 8.1 驳回
    let badReq = PublishPostReq(
        1, BusinessType.SecondHand,
        "违规商品", "测试内容",
        Some(1.0), "", "[]", ""
    )
    match (postSvc.publish(token, badReq).data) {
        case Some(p) =>
            let rej = enhAdmin.rejectWithRecord(
                admToken, p.id, "商品信息不实，请修改后重试"
            )
            println("【8.1 驳回审核（需填原因）】→ code=" +
                rej.code.toString())
            // 显示审核记录
            let rejHist = enhAdmin.getAuditHistory(
                admToken, p.id
            )
            printAuditHistory(rejHist)
        case None => ()
    }

    // 8.2 登出
    auth.logout(bobToken)
    let afterLogout = tradeSvc.requestBuy(
        bobToken, post.id, "test"
    )
    println("【8.2 登出后操作（应401）】→ code=" +
        afterLogout.code.toString() +
        " " + afterLogout.message)

    // 8.3 驳回不带原因
    let noReason = enhAdmin.rejectWithRecord(
        admToken, post.id, ""
    )
    println("【8.3 驳回不带原因（应400）】→ code=" +
        noReason.code.toString() +
        " " + noReason.message)

    // ═══════════════════════════════════════════
    sep("===== 全部测试完成 =====")
    return 0
}

// ═══════════════════════════════════════
//  可视化辅助函数
// ═══════════════════════════════════════

func sep(title: String): Unit {
    println("")
    println(title)
    println("──────────────────────────────")
}

func printCats(
    cats: Option<ArrayList<Category>>
): Unit {
    match (cats) {
        case Some(list) =>
            for (c in list) {
                println("  [${c.id}] ${c.name}" +
                    "  scene=${c.sceneType}" +
                    "  order=${c.sortOrder}")
            }
        case None => println("  (无)")
    }
}

func printUser(
    res: ApiResponse<String>
): Unit {
    match (res.data) {
        case Some(t) =>
            println("  token=" + t)
        case None => ()
    }
}

func printUserDetail(
    res: ApiResponse<User>
): Unit {
    match (res.data) {
        case Some(u) =>
            println("  id=${u.id}" +
                "  username=${u.username}" +
                "  nickname=${u.nickname}" +
                "  phone=${u.phone}" +
                "  role=${u.role}" +
                "  status=${u.status}")
        case None => println("  (未登录)")
    }
}

func printPost(post: Post): Unit {
    println("  id=${post.id}" +
        "  title=\"${post.title}\"" +
        "  type=${post.businessType}")
    println("  audit=${post.auditStatus}" +
        "  biz=${post.bizStatus}" +
        "  price=" + printPrice(post.price) +
        "  location=${post.location}")
    println("  authorId=${post.authorId}" +
        "  viewCount=${post.viewCount}" +
        "  isDeleted=${post.isDeleted}")
}

func printPrice(p: Option<Float64>): String {
    match (p) {
        case Some(v) => v.toString()
        case None    => "无"
    }
}

func printRequest(
    res: ApiResponse<Request>
): Unit {
    match (res.data) {
        case Some(r) =>
            println("  Request#" + r.id.toString() +
                "  type=${r.requestType}" +
                "  status=${r.status}" +
                "  requester=${r.requesterId}" +
                "  postId=${r.postId}")
            if (!r.note.isEmpty()) {
                println("  note=\"${r.note}\"")
            }
        case None => ()
    }
}

func printAuditHistory(
    res: ApiResponse<ArrayList<AuditRecord>>
): Unit {
    match (res.data) {
        case Some(list) =>
            for (r in list) {
                println("  Audit#" + r.id.toString() +
                    "  result=${r.auditResult}" +
                    "  auditor=${r.auditorId}")
                if (!r.reason.isEmpty()) {
                    println("  reason=\"${r.reason}\"")
                }
            }
        case None => println("  (无)")
    }
}

func printMessages(
    res: ApiResponse<PageResult<Message>>
): Unit {
    match (res.data) {
        case Some(pr) =>
            println("  total=" + pr.total.toString() +
                "  page=${pr.page}")
            for (m in pr.list) {
                let pid = match (m.postId) {
                    case Some(v) => v.toString()
                    case None    => "-"
                }
                println("  Msg#" + m.id.toString() +
                    "  type=${m.messageType}" +
                    "  from=${m.fromUserId}" +
                    "  post=${pid}" +
                    "  content=\"${m.content}\"")
            }
        case None => println("  (无)")
    }
}

func printMessageData(
    res: ApiResponse<Message>
): Unit {
    match (res.data) {
        case Some(m) =>
            let pid = match (m.postId) {
                case Some(v) => v.toString()
                case None    => "-"
            }
            let to = match (m.toUserId) {
                case Some(v) => v.toString()
                case None    => "-"
            }
            println("  Msg#" + m.id.toString() +
                "  type=${m.messageType}" +
                "  from=${m.fromUserId}" +
                "  to=${to}" +
                "  post=${pid}")
        case None => ()
    }
}

func printOverview(
    res: ApiResponse<OverviewStats>
): Unit {
    match (res.data) {
        case Some(s) =>
            println("  totalUsers      = " +
                s.totalUsers.toString())
            println("  totalPosts      = " +
                s.totalPosts.toString())
            println("  secondhandCount = " +
                s.secondhandCount.toString())
            println("  lostCount       = " +
                s.lostCount.toString())
            println("  foundCount      = " +
                s.foundCount.toString())
            println("  pendingAudit    = " +
                s.pendingAuditCount.toString())
            println("  热门分类:")
            for (hc in s.hotCategories) {
                println("    ${hc.categoryName}" +
                    " (id=${hc.categoryId})" +
                    " → ${hc.count}条")
            }
        case None => println("  (无)")
    }
}

func printStatusDist(
    res: ApiResponse<ArrayList<StatusDist>>
): Unit {
    match (res.data) {
        case Some(list) =>
            for (sd in list) {
                println("  ${sd.statusName}" +
                    " → ${sd.count}条")
            }
        case None => println("  (无)")
    }
}

func printSearchCount(
    res: ApiResponse<PageResult<Post>>
): String {
    match (res.data) {
        case Some(pr) =>
            return pr.total.toString()
        case None => return "0"
    }
}
