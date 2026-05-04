/**
 * Created on 2026/5/3
 */
package pages.admin
import models.*
import services.*
import ohos.promptAction.*

@Entry
@Component
public class AuditCenterPage {
    @State var pendingList: Array<PostSummaryVO> = []
    @State var showRejectDialog: Bool = false
    @State var currentAuditId: Int64 = 0
    @State var rejectReason: String = ""

    protected override func onPageShow() {
        pendingList = MockApi.getPendingPosts()
    }

    func submitAudit(id: Int64, status: String) {
        // 实际开发中调用 ApiService 发送网络请求
        promptAction.showToast({ message: status == "APPROVED" ? "已审核通过" : "已驳回" })
        showRejectDialog = false
        // 本地移除该条目
        var newList = Array<PostSummaryVO>()
        for (item in pendingList) {
            if (item.id != id) { newList.append(item) }
        }
        pendingList = newList
    }

    public func build() {
        Stack() {
            Column() {
                Text("审核中心").fontSize(22).fontWeight(FontWeight.Bold).margin(16)

                List({ space: 15 }) {
                    ForEach(pendingList, { item: PostSummaryVO =>
                        ListItem() {
                            Column() {
                                Row() {
                                    Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
                                    Text(item.business_type == "SECONDHAND" ? "二手" : "失物").fontColor(Color.Orange)
                                }.width("100%")

                                Text("发布人: ${item.author_nickname} | 地点: ${item.location}")
                                    .fontSize(14).fontColor(Color.Gray).margin({ top: 8, bottom: 12 })

                                Row() {
                                    Button("通过").backgroundColor("#67C23A").height(35)
                                        .onClick({ _ => submitAudit(item.id, "APPROVED") })
                                    Blank()
                                    Button("驳回").backgroundColor("#F56C6C").height(35)
                                        .onClick({ _ =>
                                            currentAuditId = item.id
                                            showRejectDialog = true
                                        })
                                }.width("100%")
                            }.padding(16).backgroundColor(Color.White).borderRadius(8)
                        }
                    })
                }.padding(16).backgroundColor("#F0F2F5").width("100%").layoutWeight(1)
            }.width("100%").height("100%")

            // 驳回弹窗
            if (showRejectDialog) {
                Column() {
                    Text("填写驳回理由").fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 15 })
                    TextArea({ placeholder: "例如：图片不清晰、包含违规内容等..." })
                        .height(100).onChange({ val => rejectReason = val }).margin({ bottom: 20 })
                    Row() {
                        Button("取消").backgroundColor(Color.Gray).onClick({ _ => showRejectDialog = false })
                        Blank()
                        Button("确认驳回").backgroundColor("#F56C6C").onClick({ _ => submitAudit(currentAuditId, "REJECTED") })
                    }.width("100%")
                }.padding(20).backgroundColor(Color.White).borderRadius(12).width("85%")
                // 简单的居中弹窗效果
                .position({ x: "7.5%", y: "30%" })
            }
        }
    }
}