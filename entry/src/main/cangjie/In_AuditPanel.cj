package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class AuditPanel {
    @State var pendingPosts: Array<PostSummaryVO> = Array(0, { i => PostSummaryVO() })
    var onBack: () -> Unit = { => () }
    var onChanged: () -> Unit = { => () }

    public func aboutToAppear() {
        pendingPosts = getPendingAuditPosts()
    }

    func submitAudit(id: Int64, approved: Bool) {
        if (auditPost(id, approved)) {
            pendingPosts = getPendingAuditPosts()
            onChanged()
        }
    }

    @Builder func renderPost(item: PostSummaryVO) {
        Column() {
            Row() {
                Text(item.title).fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF222222)
                    .layoutWeight(1)
                Text(getBizTypeLabel(item.business_type))
                    .fontSize(12)
                    .fontColor(0xFF4CAF50)
            }.width(100.percent).margin(bottom: 8)
            Text("发布人: " + item.author_nickname + "  地点: " + item.location)
                .fontSize(12)
                .fontColor(0xFF666666)
                .width(100.percent)
                .margin(bottom: 10)
            Text(item.description)
                .fontSize(13)
                .fontColor(0xFF333333)
                .width(100.percent)
                .margin(bottom: 12)
            Row() {
                Button("通过").height(34)
                    .fontSize(13)
                    .fontColor(Color.WHITE)
                    .backgroundColor(0xFF4CAF50)
                    .onClick { evt => submitAudit(item.id, true) }
                Blank()
                Button("驳回").height(34)
                    .fontSize(13)
                    .fontColor(Color.WHITE)
                    .backgroundColor(0xFFF56C6C)
                    .onClick { evt => submitAudit(item.id, false) }
            }.width(100.percent)
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
                Text("审核中心").fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .margin(left: 4)
            }.width(100.percent)
            .height(54)
            .backgroundColor(Color.WHITE)
            if (pendingPosts.size == 0) {
                Column() {
                    Text("暂无待审核内容").fontSize(16)
                        .fontColor(0xFF999999)
                }.width(100.percent)
                .height(100.percent)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            } else {
                Scroll() {
                    Column() {
                        ForEach(pendingPosts,
                            itemGeneratorFunc: {
                                item: PostSummaryVO,
                                index: Int64 => renderPost(item)
                            },
                            keyGeneratorFunc: {
                                item: PostSummaryVO,
                                index: Int64 => item.id.toString()
                            })
                    }.width(100.percent)
                    .padding(top: 12, bottom: 16)
                }.layoutWeight(1)
            }
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xFFF5F7FA)
    }
}

