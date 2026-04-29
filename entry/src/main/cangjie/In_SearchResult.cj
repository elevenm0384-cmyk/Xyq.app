package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*

@Component
public class SearchResultView {
    @State
    var searchQuery: String = ""
    @State
    var results: Array<ProductItem> = Array([])
    var onBack: () -> Unit = { => () }
    var onSearch: (String) -> Unit = { query => () }
    var onShowDetail: (ProductItem) -> Unit = { item => () }

    func build() {
        Column() {
            Row() {
                Button() {
                    Text("<").fontSize(20)
                        .fontColor(0x333333)
                        .fontWeight(FontWeight.Bold)
                }
                .backgroundColor(Color.TRANSPARENT)
                .margin(left: 4)
                .onClick { evt => onBack() }

                TextInput(text: searchQuery,
                    placeholder: "搜索商品")
                    .fontSize(14.fp)
                    .placeholderFont(size: 14)
                    .layoutWeight(1)
                    .margin(left: 6, right: 6)
                    .onChange { val => searchQuery = val }

                Button() {
                    Text("搜索").fontSize(14.fp)
                        .fontColor(Color.WHITE)
                        .fontWeight(FontWeight.Bold)
                }
                .backgroundColor(0x00AA88)
                .borderRadius(topLeft: 0.vp,
                    bottomLeft: 0.vp,
                    topRight: 16.vp,
                    bottomRight: 16.vp)
                .width(60.vp).height(30.vp)
                .onClick { evt => onSearch(searchQuery) }
            }
            .backgroundColor(Color.WHITE)
            .borderRadius(16.vp)
            .padding(top: 6.vp, bottom: 6.vp)
            .margin(left: 10, right: 10, top: 10)
            .width(95.percent)

            Text("搜索 ${searchQuery} 共" +
                " ${results.size} 件商品")
                .fontSize(12).fontColor(0x999999)
                .margin(left: 16, top: 8, bottom: 8)
                .width(100.percent)

            Scroll() {
                Column() {
                    ForEach(
                        this.results,
                        itemGeneratorFunc: {
                            item: ProductItem,
                            index: Int64 =>
                            ProductCard(
                                item: item,
                                onShowDetail: {
                                    product =>
                                    onShowDetail(product)
                                }
                            )
                        },
                        keyGeneratorFunc: {
                            item: ProductItem,
                            index: Int64 =>
                            index.toString()
                        }
                    )
                }
                .width(100.percent)
            }
            .layoutWeight(1)
            .backgroundColor(0xFFF8F8F8)
        }
        .width(100.percent).height(100.percent)
        .backgroundColor(0xFFF8F8F8)
    }
}
