package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class ProductDetail {
    var item: ProductItem = ProductItem(
        @r(app.media.pdt_camera), "", 0, 0, "")
    @State
    var description: String = ""
    @State
    var isLiked: Bool = false
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

            Text("￥${item.price}").fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFFFF4444)
                .margin(left: 16, top: 16)
                .width(100.percent)

            Text(item.title).fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor(0x333333)
                .margin(left: 16, top: 6)
                .width(100.percent)

            Row() {
                Blank()
                Button() {
                    if (isLiked) {
                        Text("❤ ${item.loves}").fontSize(14)
                            .fontColor(0xFFFF4444)
                    } else {
                        Text("♡ ${item.loves}").fontSize(14)
                            .fontColor(0x999999)
                    }
                }
                .backgroundColor(Color.TRANSPARENT)
                .margin(right: 16)
                .onClick { evt =>
                    if (isLiked) {
                        isLiked = false; item.loves -= 1
                    } else {
                        isLiked = true; item.loves += 1
                    }
                }
            }
            .width(100.percent).margin(top: 6)

            Divider().margin(top: 20, left: 16, right: 16)

            Text("商品描述").fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(0x333333)
                .margin(left: 16, top: 16)

            Text(description).fontSize(14)
                .fontColor(0x666666)
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

                Button("立即购买").fontSize(14)
                    .fontColor(Color.WHITE)
                    .backgroundColor(Color(0xFF4CAF50))
                    .borderRadius(20).width(100).height(40)
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
