package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*

@Component
public class CategoryPage {
    @State
    var selectedCategory: String = ""
    @State
    var allProducts: Array<ProductItem> = Array([])
    var onBack: () -> Unit = { => () }
    var onShowDetail: (ProductItem) -> Unit = { item => () }

    func getFilteredProducts(): Array<ProductItem> {
        var count = 0
        for (product in allProducts) {
            if (product.category == selectedCategory) {
                count++
            }
        }
        var result = Array<ProductItem>(
            count, {i => allProducts[0]})
        var idx = 0
        for (product in allProducts) {
            if (product.category == selectedCategory) {
                result[idx] = product
                idx++
            }
        }
        return result
    }

    func build() {
        Column {
            Row {
                Button() {
                    Text("<")
                        .fontSize(20).fontColor(0x333333)
                        .fontWeight(FontWeight.Bold)
                }
                .backgroundColor(Color.TRANSPARENT)
                .margin(left: 4).width(40).height(40)
                .onClick { evt => onBack() }

                Text("商品分类 - ${selectedCategory}")
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .margin(left: 8)
            }
            .width(100.percent).height(48)
            .backgroundColor(Color.WHITE)

            Scroll {
                Column {
                    if (getFilteredProducts().size > 0) {
                        ForEach(
                            getFilteredProducts(),
                            itemGeneratorFunc: {
                                item: ProductItem,
                                index: Int64 =>
                                ProductCard(
                                    item: item,
                                    onShowDetail: {
                                        p =>
                                        onShowDetail(p) }
                                )
                            },
                            keyGeneratorFunc: {
                                item: ProductItem,
                                index: Int64 =>
                                index.toString()
                            }
                        )
                    } else {
                        Column {
                            Text("暂无商品")
                                .fontSize(14)
                                .fontColor(0x999999)
                        }
                        .width(100.percent).height(200)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                    }
                }
                .width(100.percent)
                .padding(left: 8, right: 8, top: 8)
            }
            .layoutWeight(1)
            .backgroundColor(0xFFF8F8F8)
        }
        .width(100.percent).height(100.percent)
    }
}
