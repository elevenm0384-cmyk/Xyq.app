package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class MyPostsPanel {
    @State var posts: Array<PostSummaryVO>
        = Array(0, { i => PostSummaryVO() })
    @State var refreshSeed: Int64 = 0
    var onBack: () -> Unit = { => () }
    var onShowDetail: (Int64) -> Unit = { id => () }
    var onShowLostDetail: (Int64) -> Unit = { id => () }

    public func aboutToAppear() { reloadPosts() }

    func reloadPosts() {
        posts = getMyPublishedPosts(getSessionUserId()).list
        refreshSeed++
    }

    func visibleStatus(item: PostSummaryVO): String {
        if (item.audit_status != AUDIT_APPROVED) {
            return getAuditLabel(item.audit_status)
        }
        return getBizLabel(item.business_type, item.biz_status)
    }

    func doneLabel(item: PostSummaryVO): String {
        if (item.business_type == BIZ_TYPE_SECONDHAND) {
            return "已售"
        }
        return "已认领"
    }

    func canFinish(item: PostSummaryVO): Bool {
        if (item.audit_status != AUDIT_APPROVED) { return false }
        if (item.business_type == BIZ_TYPE_SECONDHAND) {
            return item.biz_status != BIZ_SOLD
        }
        return item.biz_status != BIZ_CLAIMED
    }

    func deletePost(id: Int64) {
        if (deleteMyPost(id, getSessionUserId())) {
            reloadPosts()
        }
    }

    func finishPost(id: Int64) {
        if (finishMyPost(id, getSessionUserId())) {
            reloadPosts()
        }
    }

    func openPost(item: PostSummaryVO) {
        if (item.business_type == BIZ_TYPE_SECONDHAND) {
            onShowDetail(item.id)
        } else {
            onShowLostDetail(item.id)
        }
    }

    @Builder func renderPost(item: PostSummaryVO) {
        Column() {
            Text(item.title).fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF222222)
                .width(100.percent)
                .margin(bottom: 8)
            Row() {
                Text(getBizTypeLabel(item.business_type))
                    .fontSize(12)
                    .fontColor(0xFF4CAF50)
                    .backgroundColor(0xFFE8F5E9)
                    .borderRadius(4)
                    .padding(left: 6, right: 6,
                        top: 2, bottom: 2)
                Text("审核: " + getAuditLabel(item.audit_status))
                    .fontSize(12)
                    .fontColor(0xFF666666)
                    .margin(left: 8)
                Blank()
                Text("状态: " + visibleStatus(item))
                    .fontSize(12)
                    .fontColor(0xFF4CAF50)
            }.width(100.percent).margin(bottom: 8)
            Text("地点: " + item.location + "  " + item.created_at)
                .fontSize(12)
                .fontColor(0xFF999999)
                .width(100.percent)
            Row() {
                Button("查看").height(32).fontSize(12)
                    .fontColor(Color.WHITE)
                    .backgroundColor(0xFF4CAF50)
                    .borderRadius(16)
                    .onClick { evt => openPost(item) }
                Blank()
                if (canFinish(item)) {
                    Button(doneLabel(item)).height(32).fontSize(12)
                        .fontColor(Color.WHITE)
                        .backgroundColor(0xFF409EFF)
                        .borderRadius(16)
                        .margin(right: 8)
                        .onClick { evt => finishPost(item.id) }
                }
                Button("删除").height(32).fontSize(12)
                    .fontColor(0xFFF56C6C)
                    .backgroundColor(Color.WHITE)
                    .borderWidth(1)
                    .borderColor(0xFFF56C6C)
                    .borderRadius(16)
                    .onClick { evt => deletePost(item.id) }
            }.width(100.percent).margin(top: 12)
        }.padding(14)
        .backgroundColor(Color.WHITE)
        .borderRadius(8)
        .margin(left: 16, right: 16, bottom: 10)
        .width(100.percent)
    }

    public func build() {
        Column() {
            Row() {
                Button() { Text("<").fontSize(20)
                    .fontColor(0xFF333333)
                    .fontWeight(FontWeight.Bold)
                }.backgroundColor(Color.TRANSPARENT)
                .width(42).height(42)
                .onClick { evt => onBack() }
                Text("我的发布").fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .margin(left: 4)
            }.width(100.percent)
            .height(54)
            .backgroundColor(Color.WHITE)
            if (posts.size == 0) {
                Column() {
                    Text("暂无发布记录").fontSize(16)
                        .fontColor(0xFF999999)
                }.width(100.percent)
                .height(100.percent)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            } else {
                Scroll() {
                    Column() {
                        ForEach(posts,
                            itemGeneratorFunc: {
                                item: PostSummaryVO,
                                index: Int64 => renderPost(item)
                            },
                            keyGeneratorFunc: {
                                item: PostSummaryVO,
                                index: Int64 =>
                                    item.id.toString()
                                    + item.biz_status
                                    + refreshSeed.toString()
                            })
                    }.width(100.percent)
                    .padding(top: 12, bottom: 16)
                }.layoutWeight(1)
            }
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xFFF5F7FA)
    }
}
