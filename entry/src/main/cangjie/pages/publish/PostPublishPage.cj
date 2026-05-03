/**
 * Created on 2026/5/3
 */
package pages.publish
import ohos.router.*
import ohos.promptAction.*

@Entry
@Component
public class PostPublishPage {
    @State var businessType: String = "SECONDHAND"
    @State var title: String = ""
    @State var description: String = ""
    @State var priceStr: String = ""
    @State var location: String = ""
    @State var imageCount: Int64 = 0

    func handleSubmit() {
        if (title.isEmpty() || description.isEmpty()) {
            promptAction.showToast({ message: "标题和描述不能为空！" })
            return
        }
        if (businessType == "SECONDHAND" && priceStr.isEmpty()) {
            promptAction.showToast({ message: "发布闲置必须填写价格！" })
            return
        }
        // 模拟提交
        promptAction.showToast({ message: "发布成功，已提交管理员审核！" })
        router.back()
    }

    public func build() {
        Column() {
            Text("发布信息").fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })

            // 业务类型切换
            Row() {
                Radio({ value: "SECONDHAND", group: "biz" }).checked(true)
                    .onChange({ isChecked => if(isChecked){ businessType = "SECONDHAND" }})
                Text("二手闲置").margin({ right: 20 })

                Radio({ value: "LOST", group: "biz" })
                    .onChange({ isChecked => if(isChecked){ businessType = "LOST" }})
                Text("找失物").margin({ right: 20 })

                Radio({ value: "FOUND", group: "biz" })
                    .onChange({ isChecked => if(isChecked){ businessType = "FOUND" }})
                Text("招领")
            }.width("100%").justifyContent(FlexAlign.Start).margin({ bottom: 20 })

            TextInput({ placeholder: "输入标题 (例如: 出售九成新自行车)" })
                .onChange({ value => title = value }).margin({ bottom: 15 })

            TextArea({ placeholder: "详细描述物品特征、新旧程度等..." })
                .height(120).onChange({ value => description = value }).margin({ bottom: 15 })

            // 动态显示价格
            if (businessType == "SECONDHAND") {
                TextInput({ placeholder: "请输入价格 (元)" })
                    .type(InputType.Number)
                    .onChange({ value => priceStr = value }).margin({ bottom: 15 })
            }

            TextInput({ placeholder: "交易/丢失地点 (如: 沙河校区食堂)" })
                .onChange({ value => location = value }).margin({ bottom: 15 })

            // 模拟图片上传
            Row() {
                Button("📸 上传图片")
                    .backgroundColor("#F0F2F5").fontColor("#333")
                    .onClick({ _ => imageCount += 1 })
                Text("已选择 ${imageCount} 张图片").margin({ left: 15 }).fontColor(Color.Gray)
            }.width("100%").margin({ bottom: 30 })

            Button("立即发布").width("100%").height(45)
                .backgroundColor("#409EFF")
                .onClick({ _ => handleSubmit() })

        }.padding(20).width("100%").height("100%").alignItems(HorizontalAlign.Start)
    }
}