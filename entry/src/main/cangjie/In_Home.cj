package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

func getAllLostCategories(): Array<CategoryVO> {
    var names = ["证件", "书包", "电子产品", "书籍", "眼镜", "钥匙", "水杯", "其他"]
    var result = Array<CategoryVO>()
    for (i in 0..names.size) {
        var vo = CategoryVO(); vo.id = 100 + i; vo.name = names[i]; vo.scene_type = SCENE_LOST; vo.sort_order = i; vo.is_enabled = true
        result = result.concat([vo])
    }
    return result
}

@Component
public class Homeview {
    @State var refreshKey: Int64 = 0; @State var schoolName: String = "北京航空航天大学"; @State var searchText: String = ""
    @State var categories: Array<CategoryVO> = getCategories(SCENE_SECONDHAND)
    @State var RecommendList: Array<PostSummaryVO> = Array(0, {i => PostSummaryVO()})
    @State var lostItemList: Array<PostSummaryVO> = getApprovedLostFound()
    @State var lostCategories: Array<CategoryVO> = Array<CategoryVO>()
    var onSearch: (String) -> Unit = {query => ()}
    var onShowDetail: (Int64) -> Unit = {id => ()}; var onShowLostDetail: (Int64) -> Unit = {id => ()}
    var onCategoryClick: (Int64, String) -> Unit = {id, name => ()}; var onLostCategoryClick: (Int64, String) -> Unit = {id, name => ()}; var onShowHistory: () -> Unit = { => () }

    public func aboutToAppear() { refreshRecommendList(); lostCategories = getAllLostCategories() }
    func refreshRecommendList() { RecommendList = getPostList(BIZ_TYPE_SECONDHAND, 0, "", "", AUDIT_APPROVED, BIZ_ON_SALE, SORT_LATEST, 1, 6).list }

    @Builder func renderSchoolBar() {
        Row() { Image(@r(app.media.locallg)).size(width: 15, height: 15); Text(schoolName).fontSize(10).margin(4.vp).fontWeight(FontWeight.Bold); Image(@r(app.media.jiantou)).size(width: 15, height: 15) }.position(x: 15.vp, y: 18.vp)
    }

    @Builder func renderSearchRow() {
        Row() {
            TextInput(text: searchText, placeholder: "搜索商品、失物、用户").fontSize(12.fp).placeholderFont(size: 12).onChange { val => searchText = val }
            Button() { Row() { Text("搜索").fontSize(14.fp).fontColor(Color.WHITE).fontWeight(FontWeight.Bold).margin(left: 4.vp) } }.backgroundColor(0x00AA88).borderRadius(topLeft: 0.vp, bottomLeft: 0.vp, topRight: 16.vp, bottomRight: 16.vp).width(60.vp).height(30.vp).onClick { evt => onSearch(searchText) }
        }.layoutWeight(1).backgroundColor(Color.WHITE).borderRadius(16.vp).padding(top: 6.vp, bottom: 6.vp).margin(right: 5.vp).position(x: 15.vp, y: 40.vp).width(290)
    }

    @Builder func renderCategoryGrid() {
        Grid() { ForEach(categories, itemGeneratorFunc: { item: CategoryVO, index: Int64 => GridItem { Column() { Image(getCategoryIcon(item.name)).width(48.vp).height(48.vp).margin(bottom: 8.vp); Text(item.name).fontSize(12.fp).fontColor(Color.BLACK) }.width(100.percent).height(80.vp).justifyContent(FlexAlign.Center).onClick { evt => onCategoryClick(item.id, item.name) } } }, keyGeneratorFunc: { item: CategoryVO, index: Int64 => index.toString() }) }.columnsTemplate("1fr 1fr 1fr 1fr").rowsTemplate("1fr 1fr").width(100.percent).height(180.vp).padding(top: 4.vp, bottom: 4.vp)
    }

    @Builder func renderRecommendHeader() {
        Row() { Text("✦ 为你推荐").fontSize(15).fontWeight(FontWeight.Bold).fontColor(0x222222); Blank(); Row() { Text("↻").fontSize(14).fontColor(Color(0xFF4CAF50)).margin(right: 4); Text("换一批").fontSize(12).fontColor(Color(0xFF4CAF50)) }.padding(left: 10, right: 10, top: 4, bottom: 4).backgroundColor(0xFFE8F5E9).borderRadius(12).onClick { evt => refreshRecommendList() } }.margin(bottom: 8, top: 4).width(100.percent).padding(left: 16, right: 16)
    }

    @Builder func renderProductList() {
        Column { ForEach(RecommendList, itemGeneratorFunc: { item: PostSummaryVO, index: Int64 => ProductCard(item: item, onShowDetail: { id => onShowDetail(id) }) }, keyGeneratorFunc: { item: PostSummaryVO, index: Int64 => index.toString() }) }.width(100.percent).padding(left: 16, right: 16)
    }

    @Builder func renderProductContent() {
        Stack() { renderSchoolBar(); renderSearchRow(); Scroll { Column() { renderCategoryGrid(); renderRecommendHeader(); renderProductList() } }.width(100.percent).height(100.percent).backgroundColor(0xFFF8F8F8).margin(top: 80) }.width(100.percent)
    }

    @Builder func renderLostItemCard(item: PostSummaryVO) {
        Column { Row { Image(getImageResource(item.cover_image_url)).width(100).height(100).borderRadius(8).objectFit(ImageFit.Cover)
        Stack() { Column { Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor(0x333333).maxLines(1).textOverflow(TextOverflow.Ellipsis).margin(bottom: 8).width(100.percent)
        Row() { Text(item.category_name).fontSize(11).fontColor(0x666666).backgroundColor(0xFFF0F0F0).borderRadius(4).margin(right: 6); Text(getBizTypeLabel(item.business_type)).fontSize(11).fontColor(0x666666).backgroundColor(0xFFF0F0F0).borderRadius(4).margin(right: 6); Text(getBizLabel(item.business_type, item.biz_status)).fontSize(11).fontColor(0x666666).backgroundColor(0xFFF0F0F0).borderRadius(4) }.margin(bottom: 8).width(100.percent)
        Text(item.location).fontSize(13).fontColor(0x999999).maxLines(1).textOverflow(TextOverflow.Ellipsis).margin(bottom: 8).width(100.percent); Text(item.created_at).fontSize(12).fontColor(0x999999).width(100.percent) }.padding(left: 12).justifyContent(FlexAlign.Center)
        Button("查看详情").fontSize(9).fontColor(0xFF4CAF50).backgroundColor(Color.WHITE).borderWidth(1).borderColor(0xFF4CAF50).borderRadius(15).width(70).height(25).position(x: 175, y: 55).onClick { evt => onShowLostDetail(item.id) } } }.width(100.percent).padding(12).alignItems(VerticalAlign.Top) }.width(100.percent).backgroundColor(Color.WHITE)
    }

    @Builder func renderLostCategoryGrid() {
        Grid() { ForEach(lostCategories, itemGeneratorFunc: { item: CategoryVO, index: Int64 => GridItem { Column() { Image(getCategoryIcon(item.name)).width(48.vp).height(48.vp).margin(bottom: 8.vp); Text(item.name).fontSize(12.fp).fontColor(Color.BLACK) }.width(100.percent).height(80.vp).justifyContent(FlexAlign.Center).onClick { evt => onLostCategoryClick(item.id, item.name) } } }, keyGeneratorFunc: { item: CategoryVO, index: Int64 => index.toString() }) }.columnsTemplate("1fr 1fr 1fr 1fr").width(100.percent).padding(top: 4.vp, bottom: 4.vp)
    }

    @Builder func renderLostContent() {
        Stack() { renderSchoolBar(); renderSearchRow(); Scroll { Column() { renderLostCategoryGrid(); Text("失物招领").fontSize(13).fontWeight(FontWeight.Bold).width(100.percent).padding(left: 16, top: 8, bottom: 4); ForEach(lostItemList, itemGeneratorFunc: { item: PostSummaryVO, index: Int64 => renderLostItemCard(item) }, keyGeneratorFunc: { item: PostSummaryVO, index: Int64 => index.toString() }) } }.width(100.percent).height(100.percent).backgroundColor(0xFFF8F8F8).margin(top: 80) }.width(100.percent)
    }

    @Builder func renderMyContent() {
        Stack() { Column() { Scroll { Column() { Row() { Text(getSessionUser().nickname).fontSize(20).fontWeight(FontWeight.Bold).margin(right: 8); if (getSessionUser().role == ROLE_ADMIN) { Text("管理员").fontSize(12).fontColor(Color.WHITE).backgroundColor(0xFF4CAF50).borderRadius(4).padding(left: 6, right: 6, top: 2, bottom: 2) } }.margin(top: 20, left: 16).width(100.percent)
        Row() { Text("账号: ${getSessionUser().username}").fontSize(14).fontColor(0x999999); Blank(); Text("手机: ${getSessionUser().phone}").fontSize(14).fontColor(0x999999).margin(right: 16) }.margin(top: 8, left: 16).width(100.percent)
        Divider().margin(16)
        Row() { Text("最近浏览").fontSize(16).fontColor(0x333333); Blank(); Text("〉").fontSize(18).fontColor(0x999999).margin(right: 16) }.width(100.percent).padding(left: 16, right: 8, top: 12, bottom: 12).onClick { evt => onShowHistory() } } }.width(100.percent).height(100.percent).margin(top: 20) } }.width(100.percent)
    }

    func build() {
        Stack() {
            Tabs(BarPosition.End) {
                TabContent() { renderProductContent() }.tabBar("商品")
                TabContent() { renderLostContent() }.tabBar("失物")
                TabContent() { Column() {}.width(100.percent).height(100.percent) }.tabBar("")
                TabContent() { Column() { Text("消息中心").fontSize(14.fp).fontColor(Color.GRAY) }.width(100.percent).height(100.percent).justifyContent(FlexAlign.Center) }.tabBar("消息")
                TabContent() { renderMyContent() }.tabBar("我的")
            }.width(100.percent).backgroundColor(Color.WHITE).barHeight(60)
            Button() { Column() { Text("+").fontSize(30.fp).fontColor(Color.WHITE).fontWeight(FontWeight.Bold).margin(top: 2).lineHeight(34); Text("发布").fontSize(12.fp).fontColor(Color.WHITE).margin(bottom: 2) }.width(100.percent).height(100.percent).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center) }.width(68.vp).height(68.vp).backgroundColor(0xFF4CAF50).borderRadius(34.vp).onClick {}.shadow(radius: 8, color: Color(0x664CAF50), offsetX: 0, offsetY: 4).position(x: 158, y: 700)
        }
    }
}
