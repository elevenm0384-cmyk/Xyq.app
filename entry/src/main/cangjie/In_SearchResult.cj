package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class SearchResultView {
    @State var searchQuery: String = ""
    @State var results: Array<PostSummaryVO>
        = Array(0, {i => PostSummaryVO()})
    var onBack: () -> Unit = { => () }
    var onSearch: (String) -> Unit = { query => () }
    var onShowDetail: (Int64) -> Unit = { id => () }
    var onShowLostDetail: (Int64) -> Unit = { id => () }

    func doSearch() {
        results = getPostList("", 0, searchQuery, "",
            AUDIT_APPROVED, "", SORT_LATEST, 1, 200).list
    }

    public func aboutToAppear() { doSearch() }

    @Builder func resultItem(item: PostSummaryVO) {
        ProductCard(item: item,
            onShowDetail: { id =>
                if (item.business_type == BIZ_TYPE_SECONDHAND) {
                    onShowDetail(id)
                } else {
                    onShowLostDetail(id)
                }
            })
    }

    func build() {
        Column() {
            Row() {
                Button() { Text("<").fontSize(20)
                    .fontColor(0x333333)
                    .fontWeight(FontWeight.Bold)
                }.backgroundColor(Color.TRANSPARENT)
                .width(40).height(40)
                .onClick { evt => onBack() }
                TextInput(text: searchQuery,
                    placeholder: "搜索商品、失物")
                    .fontSize(14.fp)
                    .layoutWeight(1)
                    .height(36)
                    .onChange { val => searchQuery = val }
                Button("搜索").fontSize(14)
                    .fontColor(Color.WHITE)
                    .backgroundColor(0xFF4CAF50)
                    .height(36).width(64)
                    .margin(left: 8)
                    .onClick { evt => doSearch() }
            }.width(100.percent)
            .padding(left: 8, right: 12, top: 8, bottom: 8)
            .backgroundColor(Color.WHITE)
            Text("共 ${results.size} 条结果").fontSize(12)
                .fontColor(0x999999)
                .width(100.percent)
                .padding(left: 16, top: 8, bottom: 8)
            if (results.size > 0) {
                Scroll() {
                    Column() {
                        ForEach(results,
                            itemGeneratorFunc: {
                                item: PostSummaryVO,
                                index: Int64 => resultItem(item)
                            },
                            keyGeneratorFunc: {
                                item: PostSummaryVO,
                                index: Int64 => item.id.toString()
                            })
                    }.width(100.percent)
                    .padding(left: 16, right: 16, bottom: 20)
                }.layoutWeight(1)
            } else {
                Column() {
                    Text("未找到相关结果").fontSize(14)
                        .fontColor(0x999999)
                }.width(100.percent)
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xFFF8F8F8)
    }
}
