package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class LostDetail {
    var item: LostItem = LostItem(
        @r(app.media.lost_bag), "", "", "", "", "")
    var onBack: () -> Unit = { => () }

    func build() {
        Column() {
            Stack() {
                Image(item.image).width(100.percent)
                    .aspectRatio(1)
                    .objectFit(ImageFit.Cover)
                Button() {
                    Text("<").fontSize(22)
                        .fontColor(Color.WHITE)
                        .fontWeight(FontWeight.Bold)
                }
                .backgroundColor(0x66000000)
                .borderRadius(16).width(34).height(34)
                .position(x: 16, y: 44)
                .onClick { evt => onBack() }
            }
            .width(100.percent)

            Text(item.title).fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(0x333333)
                .margin(left: 16, top: 16)
                .width(100.percent)

            Row() {
                Text(item.category).fontSize(12)
                    .fontColor(0xFF4CAF50)
                    .backgroundColor(0xFFE8F5E9)
                    .borderRadius(4)
                    .padding(left: 8, right: 8,
                        top: 3, bottom: 3)
                    .margin(right: 8)
                Text(item.color).fontSize(12)
                    .fontColor(0xFF9800)
                    .backgroundColor(0xFFFFF3E0)
                    .borderRadius(4)
                    .padding(left: 8, right: 8,
                        top: 3, bottom: 3)
            }
            .margin(left: 16, top: 12)
            .width(100.percent)

            Divider().margin(top: 16, left: 16, right: 16)

            Column() {
                Row() {
                    Text("丢失地点").fontSize(14)
                        .fontColor(0x999999)
                    Blank()
                    Text(item.location).fontSize(15)
                        .fontColor(0x333333)
                        .fontWeight(FontWeight.Medium)
                }
                .width(100.percent).margin(bottom: 12)

                Row() {
                    Text("发布时间").fontSize(14)
                        .fontColor(0x999999)
                    Blank()
                    Text("${item.time}前").fontSize(15)
                        .fontColor(0x333333)
                        .fontWeight(FontWeight.Medium)
                }
                .width(100.percent)
            }
            .margin(left: 16, right: 16, top: 16)

            Divider().margin(top: 16, left: 16, right: 16)

            Text("物品描述").fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(0x333333)
                .margin(left: 16, top: 16)

            Text("请联系失主确认物品特征," +
                "约定归还方式。")
                .fontSize(14).fontColor(0x666666)
                .margin(left: 16, right: 16, top: 8)
                .lineHeight(22)

            Blank().layoutWeight(1)

            Row() {
                Blank()
                Button("私聊").fontSize(14)
                    .fontColor(Color(0xFF4CAF50))
                    .backgroundColor(Color.WHITE)
                    .borderWidth(1)
                    .borderColor(Color(0xFF4CAF50))
                    .borderRadius(20).width(90).height(40)
                    .margin(right: 12).onClick {}

                Button("联系失主").fontSize(14)
                    .fontColor(Color.WHITE)
                    .backgroundColor(Color(0xFF4CAF50))
                    .borderRadius(20).width(110).height(40)
                    .margin(right: 16).onClick {}
            }
            .width(100.percent)
            .margin(top: 16, bottom: 36)
            .alignItems(VerticalAlign.Center)
        }
        .width(100.percent).height(100.percent)
        .backgroundColor(0xFFF8F8F8)
    }
}
