package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class LostDetail {
    @State var postId: Int64 = 0
    @State var detail: PostDetailVO = PostDetailVO()
    @State var comments: Array<MessageVO>
        = Array(0, {i => MessageVO()})
    @State var commentText: String = ""
    @State var contactText: String = ""
    @State var contactSent: Bool = false
    @State var requestMsg: String = ""
    var onBack: () -> Unit = { => () }
    func loadDetail() {
        detail = getPostDetail(postId)
        comments = getMessages(postId) }
    func sendComment() {
        if (commentText == "") { return }
        match (addMessage(
            postId, getSessionUserId(),
            commentText)) {
            case Some(_) =>
                commentText = ""
                comments = getMessages(postId)
            case None => () } }
    func contactLabel(): String {
        if (detail.business_type == BIZ_TYPE_LOST) {
            return "联系失主"
        }
        return "联系招领人"
    }
    func contactPlaceholder(): String {
        if (detail.business_type == BIZ_TYPE_LOST) {
            return "给失主发送联系方式或线索"
        }
        return "给招领人发送联系方式或认领说明"
    }
    func sendContactMessage() {
        if (contactText == "") {
            requestMsg = "请先填写联系方式或想说的话"
            return
        }
        if (sendPrivateMessage(postId, getSessionUserId(),
            contactText)) {
            contactText = ""
            contactSent = true
            requestMsg = "已发送给发布者，可在消息中心查看" }
    }
    public func aboutToAppear() { loadDetail() }

    func visibleStatus(): String {
        if (detail.audit_status != AUDIT_APPROVED) {
            return getAuditLabel(detail.audit_status)
        }
        return getBizLabel(
            detail.business_type,
            detail.biz_status)
    }

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
        Row() {
            TextInput(text: contactText,
                placeholder: contactPlaceholder())
                .fontSize(13.fp)
                .height(40)
                .layoutWeight(1)
                .margin(left: 16, right: 8)
                .onChange { val => contactText = val }
            if (contactSent) {
                Button("已发送").fontSize(14)
                    .fontColor(0x999999)
                    .backgroundColor(0xFFF0F0F0)
                    .borderRadius(20).width(110)
                    .height(40).margin(right: 16) }
            else {
                Button(contactLabel())
                .fontSize(14)
                .fontColor(Color.WHITE)
                .backgroundColor(
                    Color(0xFF4CAF50))
                .borderRadius(20).width(110)
                .height(40).margin(right: 16)
                .onClick { evt =>
                    sendContactMessage() } }
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
            Text(visibleStatus())
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
        Text("物品描述").fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(0x333333)
            .margin(left: 16, top: 16)
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
