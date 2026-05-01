package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class SearchResultView {
    @State var searchQuery: String = ""
    @State var secondhandResults:
        Array<PostSummaryVO>
        = Array(0, {i => PostSummaryVO()})
    @State var lostFoundResults:
        Array<PostSummaryVO>
        = Array(0, {i => PostSummaryVO()})
    @State var totalCount: Int64 = 0
    @State var filterBizType: String = ""
    @State var filterPriceMin: String = ""
    @State var filterPriceMax: String = ""
    @State var filterTimeRange: String = TIME_ALL
    @State var filterSortBy: String = SORT_LATEST
    var onBack: () -> Unit = { => () }
    var onSearch: (String) -> Unit = { query => () }
    var onShowDetail: (Int64) -> Unit = { id => () }
    var onShowLostDetail: (Int64) -> Unit = { id => () }

    func doSearch() {
        var page = getPostList(filterBizType, 0,
            searchQuery, "", AUDIT_APPROVED, "",
            filterSortBy, 1, 200)
        var allResults = page.list
        if (filterPriceMin != ""
            || filterPriceMax != "") {
            var filtered: Array<PostSummaryVO>
                = Array(0, {i => PostSummaryVO()})
            for (item in allResults) {
                var pv = parsePrice(item.price)
                if (filterPriceMin != ""
                    && pv < parsePrice(
                        filterPriceMin)) { continue }
                if (filterPriceMax != ""
                    && pv > parsePrice(
                        filterPriceMax)) { continue }
                filtered = filtered.concat([item])
            }
            allResults = filtered
        }
        if (filterTimeRange != TIME_ALL) {
            var threshold = getTimeThreshold(
                filterTimeRange)
            var filtered: Array<PostSummaryVO>
                = Array(0, {i => PostSummaryVO()})
            for (item in allResults) {
                if (item.created_at
                    >= threshold) {
                    filtered = filtered.concat([item])
                }
            }
            allResults = filtered
        }
        secondhandResults
            = Array(0, {i => PostSummaryVO()})
        lostFoundResults
            = Array(0, {i => PostSummaryVO()})
        for (item in allResults) {
            if (item.business_type
                == BIZ_TYPE_SECONDHAND) {
                secondhandResults
                    = secondhandResults.concat([item])
            } else {
                lostFoundResults
                    = lostFoundResults.concat([item])
            }
        }
        totalCount = allResults.size
    }

    public func aboutToAppear() {
        if (searchQuery != "") { doSearch() }
    }

    @Builder
    func renderSectionHeader(
        title: String, count: Int64) {
        Text("${title} (${count})").fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(0x333333)
            .width(100.percent)
            .padding(left: 16, top: 6, bottom: 4)
    }

    func build() {
        Column() {
            Row() {
                Button() {
                    Text("<").fontSize(20)
                        .fontColor(0x333333)
                        .fontWeight(FontWeight.Bold)
                }.backgroundColor(Color.TRANSPARENT)
                .margin(left: 4)
                .onClick { evt => onBack() }

                TextInput(text: searchQuery,
                    placeholder: "搜索商品、失物")
                    .fontSize(14.fp)
                    .placeholderFont(size: 14)
                    .layoutWeight(1)
                    .margin(left: 6, right: 6)
                    .onChange { val =>
                        searchQuery = val }

                Button() {
                    Text("搜索").fontSize(14.fp)
                        .fontColor(Color.WHITE)
                        .fontWeight(FontWeight.Bold)
                }.backgroundColor(0x00AA88)
                .borderRadius(topLeft: 0.vp,
                    bottomLeft: 0.vp,
                    topRight: 16.vp,
                    bottomRight: 16.vp)
                .width(60.vp).height(30.vp)
                .onClick { evt => doSearch() }
            }.backgroundColor(Color.WHITE)
            .borderRadius(16.vp)
            .padding(top: 6.vp, bottom: 6.vp)
            .margin(left: 10, right: 10, top: 10)
            .width(95.percent)

            Scroll() {
                Column() {
                    Row() {
                        Text("综合排序").fontSize(13)
                            .fontColor(chipTextStyle(
                                filterSortBy
                                == SORT_LATEST))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 5, bottom: 5)
                            .onClick { evt =>
                                filterSortBy
                                = SORT_LATEST
                                doSearch() }
                        Text("最新").fontSize(13)
                            .fontColor(chipTextStyle(
                                filterSortBy
                                == SORT_HOTTEST))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 5, bottom: 5)
                            .onClick { evt =>
                                filterSortBy
                                = SORT_HOTTEST
                                doSearch() }
                        Text("价格↑").fontSize(13)
                            .fontColor(chipTextStyle(
                                filterSortBy
                                == SORT_PRICE_ASC))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 5, bottom: 5)
                            .onClick { evt =>
                                filterSortBy
                                = SORT_PRICE_ASC
                                doSearch() }
                        Text("价格↓").fontSize(13)
                            .fontColor(chipTextStyle(
                                filterSortBy
                                == SORT_PRICE_DESC))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 5, bottom: 5)
                            .onClick { evt =>
                                filterSortBy
                                = SORT_PRICE_DESC
                                doSearch() }
                        Text("收藏").fontSize(13)
                            .fontColor(chipTextStyle(
                                filterSortBy
                                == SORT_FAVORITE))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 5, bottom: 5)
                            .onClick { evt =>
                                filterSortBy
                                = SORT_FAVORITE
                                doSearch() }
                    }.width(100.percent).height(36)
                    .backgroundColor(Color.WHITE)
                    .margin(top: 4)

                    Divider().height(6)
                    .color(0xFFF5F5F5).width(100.percent)

                    Row() {
                        Text("分类").fontSize(12)
                            .fontColor(0x888888)
                            .margin(right: 6)
                        Text("全部").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterBizType == ""))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterBizType == ""))
                            .borderRadius(12)
                            .onClick { evt =>
                                filterBizType = ""
                                doSearch() }
                        Text("商品").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterBizType
                                == BIZ_TYPE_SECONDHAND))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterBizType
                                == BIZ_TYPE_SECONDHAND))
                            .borderRadius(12)
                            .margin(left: 4)
                            .onClick { evt =>
                                filterBizType
                                = BIZ_TYPE_SECONDHAND
                                doSearch() }
                        Text("失物").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterBizType
                                == BIZ_TYPE_LOST))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterBizType
                                == BIZ_TYPE_LOST))
                            .borderRadius(12)
                            .margin(left: 4)
                            .onClick { evt =>
                                filterBizType
                                = BIZ_TYPE_LOST
                                doSearch() }
                        Text("招领").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterBizType
                                == BIZ_TYPE_FOUND))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 10,
                                right: 10,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterBizType
                                == BIZ_TYPE_FOUND))
                            .borderRadius(12)
                            .margin(left: 4)
                            .onClick { evt =>
                                filterBizType
                                = BIZ_TYPE_FOUND
                                doSearch() }
                        Blank().layoutWeight(1)
                    }.width(100.percent)
                    .padding(left: 12, right: 12,
                        top: 10, bottom: 10)
                    .backgroundColor(Color.WHITE)

                    Divider().height(1)
                    .color(0xFFF0F0F0).width(100.percent)

                    Row() {
                        Text("价格").fontSize(12)
                            .fontColor(0x888888)
                            .margin(right: 6)
                        TextInput(
                            text: filterPriceMin,
                            placeholder: "最低")
                            .fontSize(12).width(64)
                            .height(28)
                            .backgroundColor(0xFFF5F5F5)
                            .borderRadius(6)
                            .padding(left: 6, right: 6)
                            .onChange { val =>
                                filterPriceMin = val
                                doSearch() }
                        Text("—").fontSize(12)
                            .fontColor(0xCCCCCC)
                            .margin(left: 4, right: 4)
                        TextInput(
                            text: filterPriceMax,
                            placeholder: "最高")
                            .fontSize(12).width(64)
                            .height(28)
                            .backgroundColor(0xFFF5F5F5)
                            .borderRadius(6)
                            .padding(left: 6, right: 6)
                            .onChange { val =>
                                filterPriceMax = val
                                doSearch() }
                        Blank().layoutWeight(1)

                        Text("全部时间").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterTimeRange
                                == TIME_ALL))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 8,
                                right: 8,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterTimeRange
                                == TIME_ALL))
                            .borderRadius(10)
                            .onClick { evt =>
                                filterTimeRange
                                = TIME_ALL
                                doSearch() }
                        Text("24h").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterTimeRange
                                == TIME_24H))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 8,
                                right: 8,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterTimeRange
                                == TIME_24H))
                            .borderRadius(10)
                            .margin(left: 4)
                            .onClick { evt =>
                                filterTimeRange
                                = TIME_24H
                                doSearch() }
                        Text("本周").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterTimeRange
                                == TIME_WEEK))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 8,
                                right: 8,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterTimeRange
                                == TIME_WEEK))
                            .borderRadius(10)
                            .margin(left: 4)
                            .onClick { evt =>
                                filterTimeRange
                                = TIME_WEEK
                                doSearch() }
                        Text("本月").fontSize(12)
                            .fontColor(chipTextStyle(
                                filterTimeRange
                                == TIME_MONTH))
                            .fontWeight(FontWeight.Bold)
                            .padding(left: 8,
                                right: 8,
                                top: 4, bottom: 4)
                            .backgroundColor(chipStyle(
                                filterTimeRange
                                == TIME_MONTH))
                            .borderRadius(10)
                            .margin(left: 4)
                            .onClick { evt =>
                                filterTimeRange
                                = TIME_MONTH
                                doSearch() }
                    }.width(100.percent)
                    .padding(left: 12, right: 12,
                        top: 10, bottom: 10)
                    .backgroundColor(Color.WHITE)

                    if (filterBizType == ""
                        || filterBizType
                        == BIZ_TYPE_SECONDHAND) {
                        if (secondhandResults.size > 0)
                        {
                            renderSectionHeader(
                                "商品",
                                secondhandResults.size)
                            ForEach(
                                secondhandResults,
                                itemGeneratorFunc: {
                                    item: PostSummaryVO,
                                    index: Int64 =>
                                    ProductCard(
                                        item: item,
                                        onShowDetail: {
                                            id =>
                                            onShowDetail(id)
                                        })
                                },
                                keyGeneratorFunc: {
                                    item: PostSummaryVO,
                                    index: Int64 =>
                                    index.toString()
                                })
                        }
                    }

                    if (filterBizType == ""
                        || filterBizType
                        == BIZ_TYPE_LOST
                        || filterBizType
                        == BIZ_TYPE_FOUND) {
                        if (lostFoundResults.size > 0)
                        {
                            renderSectionHeader(
                                "失物招领",
                                lostFoundResults.size)
                            ForEach(
                                lostFoundResults,
                                itemGeneratorFunc: {
                                    item: PostSummaryVO,
                                    index: Int64 =>
                                    ProductCard(
                                        item: item,
                                        onShowDetail: {
                                            id =>
                                            onShowLostDetail(
                                                id)
                                        })
                                },
                                keyGeneratorFunc: {
                                    item: PostSummaryVO,
                                    index: Int64 =>
                                    index.toString()
                                })
                        }
                    }

                    if (totalCount == 0) {
                        Text("未找到相关结果")
                            .fontSize(14)
                            .fontColor(0x999999)
                            .margin(top: 40)
                            .width(100.percent)
                            .textAlign(TextAlign.Center)
                    }
                }.width(100.percent)
                .padding(bottom: 20)
            }.layoutWeight(1)
            .backgroundColor(0xFFF8F8F8)
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xFFF8F8F8)
    }

    func chipStyle(isSel: Bool): Color {
        if (isSel) { return Color(0xFF4CAF50) }
        return Color(0xFFF0F0F0)
    }

    func chipTextStyle(isSel: Bool): Color {
        if (isSel) { return Color.WHITE }
        return Color(0x666666)
    }
}
