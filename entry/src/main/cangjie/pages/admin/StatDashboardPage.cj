/**
 * Created on 2026/5/3
 */
package pages.admin
import services.*

@Entry
@Component
public class StatDashboardPage {
    @State var statsData: Map<String, String> = HashMap<String, String>()

    protected override func onPageShow() {
        statsData = MockApi.getStatsOverview()
    }

    public func build() {
        Column() {
            Text("平台数据看板").fontSize(22).fontWeight(FontWeight.Bold).margin(16)

            Grid() {
                GridItem() { StatCard("总用户数", statsData.get("total_users") ?? "0", "#409EFF") }
                GridItem() { StatCard("总发布量", statsData.get("total_posts") ?? "0", "#67C23A") }
                GridItem() { StatCard("待审核任务", statsData.get("pending_audit") ?? "0", "#F56C6C") }
                GridItem() { StatCard("在售二手商品", statsData.get("secondhand_count") ?? "0", "#E6A23C") }
                GridItem() { StatCard("失物招领进行中", statsData.get("lost_found_count") ?? "0", "#909399") }
            }
            .columnsTemplate("1fr 1fr")
            .rowsGap(15).columnsGap(15).padding(16)

        }.width("100%").height("100%").backgroundColor("#F5F7FA")
    }

    // 内部帮助组件：数据卡片
    @Builder func StatCard(title: String, value: String, colorStr: String) {
        Column() {
            Text(title).fontSize(14).fontColor(Color.Gray).margin({ bottom: 8 })
            Text(value).fontSize(26).fontWeight(FontWeight.Bold).fontColor(colorStr)
        }.padding(20).backgroundColor(Color.White).borderRadius(12).width("100%").alignItems(HorizontalAlign.Center)
    }
}