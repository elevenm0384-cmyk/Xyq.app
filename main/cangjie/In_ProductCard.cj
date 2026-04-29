package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class ProductCard {
    var item: ProductItem = ProductItem(
        @r(app.media.pdt_camera), "", 0, 0, "")
    var onShowDetail: (ProductItem) -> Unit = {
        item => () }

    func build() {
        Column {
            Row {
                Image(item.image).width(100).height(100)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                Column {
                    Text(item.title).fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0x333333)
                        .maxLines(2)
                        .textOverflow(TextOverflow.Ellipsis)
                        .margin(bottom: 8)
                    Row {
                        Text("￥${item.price}").fontSize(18)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0xFFFF4444)
                        Blank().width(12)
                        Text("喜欢${item.loves}").fontSize(12)
                            .fontColor(0x999999)
                    }.margin(bottom: 8)

                    Button() {
                        Text("查看详情").fontSize(9)
                            .fontColor(0xFF4CAF50)
                    }
                    .backgroundColor(Color.WHITE)
                    .borderWidth(1).borderColor(0xFF4CAF50)
                    .borderRadius(15).width(70).height(25)
                    .position(x: 155, y: 20)
                    .onClick { evt => onShowDetail(item) }
                }
                .padding(left: 12)
                .justifyContent(FlexAlign.Center)
            }
            .width(100.percent).padding(12)
        }
        .width(100.percent)
        .backgroundColor(Color.WHITE)
    }
}
