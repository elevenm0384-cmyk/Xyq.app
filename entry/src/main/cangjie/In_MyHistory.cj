package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class MyHistory {
    @State var historyList: Array<PostSummaryVO> = Array(0, {i => PostSummaryVO()})
    var onBack: () -> Unit = { => () }
    var onShowDetail: (Int64) -> Unit = { id => () }
    var onShowLostDetail: (Int64) -> Unit = { id => () }
    public func aboutToAppear() { historyList = getHistory(getSessionUserId()).list }
    func build() { Column() { Row() { Button() { Text("<").fontSize(20).fontColor(0x333333).fontWeight(FontWeight.Bold) }.backgroundColor(Color.TRANSPARENT).margin(left: 4).width(40).height(40).onClick { evt => onBack() }; Text("最近浏览").fontSize(18).fontWeight(FontWeight.Bold).margin(left: 8) }.width(100.percent).height(48).backgroundColor(Color.WHITE)
    if (historyList.size > 0) { Scroll() { Column() { ForEach(historyList, itemGeneratorFunc: { item: PostSummaryVO, index: Int64 => ProductCard(item: item, onShowDetail: { id => if (item.business_type == BIZ_TYPE_SECONDHAND) { onShowDetail(id) } else { onShowLostDetail(id) } }) }, keyGeneratorFunc: { item: PostSummaryVO, index: Int64 => index.toString() }) }.width(100.percent).padding(top: 8) }.layoutWeight(1).backgroundColor(0xFFF8F8F8) } else { Column() { Text("暂无浏览记录").fontSize(14).fontColor(0x999999) }.width(100.percent).height(100.percent).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).backgroundColor(0xFFF8F8F8) } }.width(100.percent).height(100.percent) } }
