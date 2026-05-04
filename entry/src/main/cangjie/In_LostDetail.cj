package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class LostDetail {
    @State var postId: Int64 = 0
    @State var detail: PostDetailVO = PostDetailVO()
    @State var isLiked: Bool = false
    @State var favoriteCount: Int64 = 0
    @State var comments: Array<MessageVO>
        = Array(0, {i => MessageVO()})
    @State var commentText: String = ""
    @State var requestSent: Bool = false
    @State var requestMsg: String = ""
    var onBack: () -> Unit = { => () }
    func loadDetail() {
        incrementViewCount(postId)
        recordBrowseHistory(
            getSessionUserId(), postId)
        detail = getPostDetail(postId)
        isLiked = detail.is_favorited
        favoriteCount = detail.favorite_count
        comments = getMessages(postId) }
    func toggleLike() {
        var r = toggleFavorite(
            postId, getSessionUserId(), !isLiked)
        isLiked = r; if (r) { favoriteCount++ }
        else if (favoriteCount > 0) { favoriteCount-- } }
    func sendComment() {
        if (commentText == "") { return }
        match (addMessage(
            postId, getSessionUserId(),
            commentText)) {
            case Some(_) =>
                commentText = ""
                comments = getMessages(postId)
            case None => () } }
    func sendClaimRequest() {
        if (createRequest(postId,
            getSessionUserId(), REQ_TYPE_CLAIM,
            "")) {
            requestSent = true
            requestMsg = "已发送认领意向，等待发布者回复" } }
    public func aboutToAppear() { loadDetail() }

    @Builder func renderCommentItem(
        item: MessageVO) { Column() { Row() {
        Text(item.from_user.nickname)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(0x333333)
        Blank()
        Text(item.created_at)
            .fontSize(11).fontColor(0x999999)
    }.width(100.percent)
    Text(item.content).fontSize(14)
        .fontColor(0x666666)
        .margin(top: 4).lineHeight(20)
    Divider().height(0.5).color(0xFFF0F0F0)
        .margin(top: 8)
    }.width(100.percent)
    .padding(left: 16, right: 16, top: 8) }

    @Builder func renderCommentSection() {
        Text("留言 (${comments.size})")
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(0x333333)
            .margin(left: 16, top: 16)
        if (comments.size > 0) {
            ForEach(comments,
                itemGeneratorFunc: {
                    item: MessageVO,
                    index: Int64 =>
                    renderCommentItem(item) },
                keyGeneratorFunc: {
                    item: MessageVO,
                    index: Int64 =>
                    index.toString() }) }
        else { Text("暂无留言").fontSize(14)
            .fontColor(0x999999)
            .margin(left: 16, top: 8) }
        Row() { TextInput(
            text: commentText,
            placeholder: "输入留言...")
            .fontSize(14.fp).layoutWeight(1)
            .height(40).onChange { val =>
                commentText = val }
            Button("发送").fontSize(14)
                .fontColor(Color.WHITE)
                .backgroundColor(0xFF4CAF50)
                .borderRadius(16).height(36)
                .margin(left: 8).width(56)
                .onClick { evt => sendComment() }
        }.width(100.percent).padding(
            left: 16, right: 16,
            top: 8, bottom: 16) }

    @Builder func renderBottomBar() {
        if (requestMsg != "") {
            Text(requestMsg).fontSize(13)
                .fontColor(Color.WHITE)
                .width(100.percent)
                .backgroundColor(0xFF4CAF50)
                .textAlign(TextAlign.Center)
                .padding(8) }
        Row() { Blank()
            Button("私聊").fontSize(14)
                .fontColor(Color(0xFF4CAF50))
                .backgroundColor(Color.WHITE)
                .borderWidth(1)
                .borderColor(Color(0xFF4CAF50))
                .borderRadius(20).width(90)
                .height(40).margin(right: 12)
                .onClick {}
            if (requestSent) {
                Button("已申请").fontSize(14)
                    .fontColor(0x999999)
                    .backgroundColor(0xFFF0F0F0)
                    .borderRadius(20).width(110)
                    .height(40).margin(right: 16) }
            else { if (detail.business_type
                == BIZ_TYPE_LOST) {
                Button("联系失主").fontSize(14)
                    .fontColor(Color.WHITE)
                    .backgroundColor(
                        Color(0xFF4CAF50))
                    .borderRadius(20).width(110)
                    .height(40).margin(right: 16)
                    .onClick { evt =>
                        sendClaimRequest() } }
            else { Button("联系招领人")
                .fontSize(14)
                .fontColor(Color.WHITE)
                .backgroundColor(
                    Color(0xFF4CAF50))
                .borderRadius(20).width(110)
                .height(40).margin(right: 16)
                .onClick { evt =>
                    sendClaimRequest() } } }
        }.width(100.percent)
        .margin(top: 12, bottom: 24)
        .alignItems(VerticalAlign.Center) }

    func build() { Column() { Scroll() {
        Column() { Stack() {
            if (detail.image_urls.size > 0) {
                Image(getImageResource(
                    detail.image_urls[0]))
                    .width(100.percent)
                    .aspectRatio(1)
                    .objectFit(ImageFit.Cover) }
            else { Image(@r(app.media.start))
                .width(100.percent)
                .aspectRatio(1) }
            Button() { Text("<").fontSize(22)
                .fontColor(Color.WHITE)
                .fontWeight(FontWeight.Bold)
            }.backgroundColor(0x66000000)
            .borderRadius(16).width(34).height(34)
            .position(x: 16, y: 44)
            .onClick { evt => onBack() }
        }.width(100.percent)
        Text(detail.title).fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(0x333333)
            .margin(left: 16, top: 16)
            .width(100.percent)
        Row() {
            if (detail.category.id > 0) {
                Text(detail.category.name)
                    .fontSize(12)
                    .fontColor(0xFF4CAF50)
                    .backgroundColor(0xFFE8F5E9)
                    .borderRadius(4)
                    .padding(left: 8, right: 8,
                        top: 3, bottom: 3)
                    .margin(right: 8) }
            Text(getBizTypeLabel(
                detail.business_type))
                .fontSize(12).fontColor(0xFF9800)
                .backgroundColor(0xFFFFF3E0)
                .borderRadius(4)
                .padding(left: 8, right: 8,
                    top: 3, bottom: 3)
                .margin(right: 8)
            Text(getBizLabel(
                detail.business_type,
                detail.biz_status))
                .fontSize(12)
                .fontColor(0x666666)
                .backgroundColor(0xFFF0F0F0)
                .borderRadius(4)
                .padding(left: 8, right: 8,
                    top: 3, bottom: 3)
        }.margin(left: 16, top: 12)
        .width(100.percent)
        Divider().margin(
            top: 16, left: 16, right: 16)
        Column() { Row() {
            Text("地点").fontSize(14)
                .fontColor(0x999999)
            Blank()
            Text(detail.location).fontSize(15)
                .fontColor(0x333333)
                .fontWeight(FontWeight.Medium)
        }.width(100.percent).margin(bottom: 12)
        Row() { Text("发布时间").fontSize(14)
            .fontColor(0x999999); Blank()
            Text(detail.created_at).fontSize(15)
                .fontColor(0x333333)
                .fontWeight(FontWeight.Medium)
        }.width(100.percent).margin(bottom: 12)
        Row() { Text("发布者").fontSize(14)
            .fontColor(0x999999); Blank()
            Text(detail.author.nickname)
                .fontSize(15).fontColor(0x333333)
                .fontWeight(FontWeight.Medium)
        }.width(100.percent).margin(bottom: 12)
        Row() { Text("联系方式").fontSize(14)
            .fontColor(0x999999); Blank()
            Text(detail.author.phone)
                .fontSize(15).fontColor(0x333333)
                .fontWeight(FontWeight.Medium)
        }.width(100.percent).margin(bottom: 12)
        Row() { Text("审核状态").fontSize(14)
            .fontColor(0x999999); Blank()
            Text(getAuditLabel(
                detail.audit_status))
                .fontSize(15).fontColor(0x333333)
                .fontWeight(FontWeight.Medium)
        }.width(100.percent).margin(bottom: 12)
        Row() { Text("更新时间").fontSize(14)
            .fontColor(0x999999); Blank()
            Text(detail.updated_at).fontSize(15)
                .fontColor(0x333333)
                .fontWeight(FontWeight.Medium)
        }.width(100.percent)
        }.margin(left: 16, right: 16, top: 16)
        Divider().margin(
            top: 16, left: 16, right: 16)
        Row() { Text("物品描述").fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(0x333333); Blank()
            Button() {
                if (isLiked) {
                    Text("❤ ${favoriteCount}")
                        .fontSize(14)
                        .fontColor(0xFFFF4444) }
                else { Text("♡ ${favoriteCount}")
                    .fontSize(14)
                    .fontColor(0x999999) }
            }.backgroundColor(Color.TRANSPARENT)
            .onClick { evt => toggleLike() }
        }.margin(left: 16, right: 16, top: 16)
        .width(100.percent)
        Text(detail.description).fontSize(14)
            .fontColor(0x666666)
            .margin(left: 16, right: 16, top: 8)
            .lineHeight(22)
        Divider().margin(
            top: 20, left: 16, right: 16)
        renderCommentSection()
        }.width(100.percent).padding(bottom: 16)
    }.layoutWeight(1); renderBottomBar()
    }.width(100.percent).height(100.percent)
    .backgroundColor(0xFFF8F8F8) } }
