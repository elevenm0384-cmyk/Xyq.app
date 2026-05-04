/**
 * Created on 2026/5/3
 */
package pages.personal
import models.*
import services.*

@Entry
@Component
public class MyPostsPage {
    @State var myPosts: Array<PostSummaryVO> = []

    protected override func onPageShow() {
        myPosts = MockApi.getMyPosts()
    }

    public func build() {
        Column() {
            Text("我的发布").fontSize(22).fontWeight(FontWeight.Bold).margin(16)

            List({ space: 10 }) {
                ForEach(myPosts, { item: PostSummaryVO =>
                    ListItem() {
                        Column() {
                            Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).width("100%")
                            Row() {
                                Text("审核状态: ${item.audit_status}").fontSize(14).fontColor(Color.Gray)
                                Blank()
                                Text("业务状态: ${item.biz_status}").fontSize(14).fontColor("#409EFF")
                            }.width("100%").margin({ top: 10 })
                        }.padding(16).backgroundColor(Color.White).borderRadius(8)
                    }
                })
            }.padding(16).backgroundColor("#F5F7FA").layoutWeight(1)
        }.width("100%").height("100%")
    }
}