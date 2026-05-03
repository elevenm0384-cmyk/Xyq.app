/**
 * Created on 2026/5/3
 */
package pages.personal
import models.*
import services.*
import ohos.promptAction.*
import ohos.router.*

@Entry
@Component
public class MyFavoritesPage {
    @State var favoriteList: Array<PostSummaryVO> = []

    protected override func onPageShow() {
        // 请求 GET /api/users/me/favorites
        favoriteList = MockApi.getMyFavorites()
    }

    // 取消收藏交互
    func handleUnfavorite(postId: Int64) {
        // 实际开发：调用 ApiService 发送 DELETE /api/posts/{id}/favorite 请求

        // 前端本地移除该项，触发 UI 刷新
        var newList = Array<PostSummaryVO>()
        for (item in favoriteList) {
            if (item.id != postId) {
                newList.append(item)
            }
        }
        favoriteList = newList
        promptAction.showToast({ message: "已取消收藏" })
    }

    // 跳转到 1号(前端A) 写的详情页
    func goToDetail(postId: Int64) {
        // 这里的路由地址需要和 1号 协商好
        // router.pushUrl({ url: "pages/detail/PostDetailPage", params: { "id": postId } })
        promptAction.showToast({ message: "准备跳转到详情页 ID: ${postId}" })
    }

    public func build() {
        Column() {
            Text("我的收藏").fontSize(22).fontWeight(FontWeight.Bold).margin(16)

            // 状态判断：如果有数据就渲染列表，没数据就显示空状态
            if (favoriteList.size == 0) {
                Column() {
                    Text("暂无收藏记录").fontSize(16).fontColor(Color.Gray).margin({ top: 100 })
                    Text("去首页逛逛吧~").fontSize(14).fontColor("#C0C4CC").margin({ top: 10 })
                }.width("100%").alignItems(HorizontalAlign.Center)
            } else {
                List({ space: 15 }) {
                    ForEach(favoriteList, { item: PostSummaryVO =>
                        ListItem() {
                            Row() {
                                // 左侧信息区 (点击前往详情页)
                                Column() {
                                    Text(item.title).fontSize(16).fontWeight(FontWeight.Bold)

                                    // 动态显示：二手展示价格，失物/招领展示对应标签
                                    if (item.business_type == "SECONDHAND") {
                                        Text("二手闲置 | ¥${item.price}").fontSize(14).fontColor("#E6A23C").margin({ top: 6, bottom: 6 })
                                    } else {
                                        Text(item.business_type == "LOST" ? "寻物启事" : "失物招领").fontSize(14).fontColor("#409EFF").margin({ top: 6, bottom: 6 })
                                    }

                                    Text("发布人: ${item.author_nickname}  |  ${item.created_at}")
                                        .fontSize(12).fontColor(Color.Gray)
                                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                                .onClick({ _ => goToDetail(item.id) })

                                // 右侧操作区 (取消收藏按钮)
                                Button("取消收藏")
                                    .backgroundColor("#F56C6C")
                                    .height(32)
                                    .fontSize(12)
                                    .onClick({ _ => handleUnfavorite(item.id) })
                            }.padding(16).backgroundColor(Color.White).borderRadius(8).width("100%")
                        }
                    })
                }.padding(16).backgroundColor("#F5F7FA").layoutWeight(1)
            }
        }.width("100%").height("100%").backgroundColor("#F5F7FA")
    }
}