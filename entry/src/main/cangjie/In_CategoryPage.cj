package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class CategoryPage {
    @State var sceneType: String = SCENE_SECONDHAND
    @State var selectedCategoryId: Int64 = 0
    @State var selectedCategoryName: String = ""
    @State var categories: Array<CategoryVO>
        = getCategories(SCENE_SECONDHAND)
    @State var filteredPosts: Array<PostSummaryVO>
        = Array(0, {i => PostSummaryVO()})
    @State var selectedIndex: Int64 = 0
    var onBack: () -> Unit = { => () }
    var onShowDetail: (Int64) -> Unit = { id => () }

    func getCategoryTitle(): String {
        if (sceneType == SCENE_LOST)
        { return "失物分类" }
        return "商品分类" }
    func getBizTypeFilter(): String {
        if (sceneType == SCENE_SECONDHAND)
        { return BIZ_TYPE_SECONDHAND }
        if (sceneType == SCENE_LOST)
        { return BIZ_TYPE_LOST }
        return "" }

    func selectCategory(
        index: Int64, catId: Int64,
        catName: String) {
        selectedIndex = index
        selectedCategoryId = catId
        selectedCategoryName = catName
        filteredPosts = getPostList(
            getBizTypeFilter(), catId, "",
            "", AUDIT_APPROVED, "",
            SORT_LATEST, 1, 100).list }

    public func aboutToAppear() {
        categories = getCategories(sceneType)
        if (selectedCategoryId > 0) {
            for (i in 0..categories.size) {
                if (categories[i].id
                    == selectedCategoryId) {
                    selectCategory(i,
                        selectedCategoryId,
                        selectedCategoryName)
                    break } } }
        else if (categories.size > 0) {
            selectCategory(0, categories[0].id,
                categories[0].name) } }

    @Builder func renderCard(item: PostSummaryVO) {
        Column() { Row() {
            Image(getImageResource(
                item.cover_image_url))
                .width(72).height(72)
                .borderRadius(10)
                .objectFit(ImageFit.Cover)
            Column() {
                Text(item.title).fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0x222222).maxLines(2)
                    .textOverflow(
                        TextOverflow.Ellipsis)
                    .lineHeight(21)
                    .margin(left: 10, bottom: 6)
                    .width(100.percent)
                if (item.price != "") {
                    Text("￥${item.price}")
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0xFFFF4444)
                        .margin(left: 10, bottom: 4)
                        .width(100.percent) }
                else { Text(getBizTypeLabel(
                    item.business_type))
                    .fontSize(12)
                    .fontColor(Color(0xFF4CAF50))
                    .margin(left: 10, bottom: 4)
                    .width(100.percent) }
                Row() { Text(
                    "${item.view_count}次浏览")
                    .fontSize(11)
                    .fontColor(0xBBBBBB)
                    .margin(left: 10)
                    Blank().layoutWeight(1)
                    Button() { Text("查看详情")
                        .fontSize(10)
                        .fontColor(
                            Color(0xFF4CAF50))
                    }.backgroundColor(Color.WHITE)
                    .borderWidth(1)
                    .borderColor(Color(0xFF4CAF50))
                    .borderRadius(12).width(64)
                    .height(26).margin(right: 4)
                    .onClick { evt =>
                        onShowDetail(item.id) }
                }.width(100.percent)
            }.layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignSelf(ItemAlign.Start)
        }.padding(10)
    }.width(100.percent)
    .backgroundColor(Color.WHITE)
    .margin(bottom: 8).borderRadius(10) }

    func build() { Column { Row() {
        Button() { Text("<").fontSize(20)
            .fontColor(0x333333)
            .fontWeight(FontWeight.Bold)
        }.backgroundColor(Color.TRANSPARENT)
        .margin(left: 4).width(40).height(40)
        .onClick { evt => onBack() }
        Text(getCategoryTitle()).fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin(left: 8)
    }.width(100.percent).height(48)
    .backgroundColor(Color.WHITE)
    Row { Scroll { Column {
        ForEach(categories,
            itemGeneratorFunc: {
                item: CategoryVO,
                index: Int64 =>
                if (index == selectedIndex) {
                    Column {
                        Text(item.name)
                            .fontSize(14)
                            .fontColor(Color(
                                0xFF4CAF50))
                            .fontWeight(
                                FontWeight.Bold)
                            .padding(top: 14,
                                bottom: 14,
                                left: 12, right: 12)
                            .width(100.percent)
                        Divider().height(0.5)
                            .color(0xFFF0F0F0)
                    }.width(100.percent)
                    .backgroundColor(
                        Color(0xFFF0FFF0))
                    .onClick { evt =>
                        selectCategory(index,
                            item.id, item.name) } }
                else { Column {
                    Text(item.name)
                        .fontSize(14)
                        .fontColor(Color(0x333333))
                        .fontWeight(FontWeight.Normal)
                        .padding(top: 14, bottom: 14,
                            left: 12, right: 12)
                        .width(100.percent)
                    Divider().height(0.5)
                        .color(0xFFF0F0F0)
                }.width(100.percent)
                .backgroundColor(Color.WHITE)
                .onClick { evt =>
                    selectCategory(index,
                        item.id, item.name) } }
            },
            keyGeneratorFunc: {
                item: CategoryVO,
                index: Int64 =>
                index.toString() })
    }.width(100.percent) }.width(90.vp)
    .backgroundColor(Color.WHITE)
    Divider().width(1).height(100.percent)
    .color(0xFFE0E0E0)
    Column {
        if (filteredPosts.size > 0) {
            Text("${selectedCategoryName} "
                + "(${filteredPosts.size})")
                .fontSize(13)
                .fontColor(0x999999)
                .width(100.percent)
                .padding(left: 12, top: 8,
                    bottom: 8)
            Scroll { Column {
                ForEach(filteredPosts,
                    itemGeneratorFunc: {
                        item: PostSummaryVO,
                        index: Int64 =>
                        renderCard(item) },
                    keyGeneratorFunc: {
                        item: PostSummaryVO,
                        index: Int64 =>
                        index.toString() })
            }.width(100.percent)
            }.layoutWeight(1) }
        else { Column { Text("暂无商品")
            .fontSize(14).fontColor(0x999999)
        }.width(100.percent).height(100.percent)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center) }
    }.layoutWeight(1).backgroundColor(0xFFF8F8F8)
    }.layoutWeight(1)
    }.width(100.percent).height(100.percent)
    .backgroundColor(0xFFF8F8F8) } }
