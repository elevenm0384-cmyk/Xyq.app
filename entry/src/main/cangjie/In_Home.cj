package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

public class GridItemData {
    public let image: CJResource
    public let text: String
    public init(image: CJResource, text: String) {
        this.image = image; this.text = text
    }
}

public class ProductItem {
    public let image: CJResource
    public let title: String
    public let price: Int64
    public var loves: Int64
    public let category : String
    public init(
        image: CJResource, title: String,
        price: Int64, loves: Int64,
        category: String
    ) {
        this.image = image; this.title = title
        this.price = price; this.loves = loves
        this.category = category
    }
}

public class LostItem {
    public let image: CJResource
    public let title: String
    public let category: String
    public let color: String
    public let location: String
    public let time: String

    public init(
        image: CJResource, title: String,
        category: String, color: String,
        location: String, time: String
    ) {
        this.image = image; this.title = title
        this.category = category; this.color = color
        this.location = location; this.time = time
    }
}

@Component
public class Homeview {
    @State
    var schoolName: String = "北京航空航天大学"
    @State
    var searchText: String = ""
    @State
    var dataList: Array<GridItemData> = Array([
        GridItemData(@r(app.media.icon_digital),
            "电子数码"),
        GridItemData(@r(app.media.icon_book),
            "图书教材"),
        GridItemData(@r(app.media.icon_life),
            "生活用品"),
        GridItemData(@r(app.media.icon_clothes),
            "服饰箱包"),
        GridItemData(@r(app.media.icon_sport),
            "运动户外"),
        GridItemData(@r(app.media.icon_beauty),
            "美妆饰品"),
        GridItemData(@r(app.media.icon_pet),
            "宠物用品"),
        GridItemData(@r(app.media.icon_campus),
            "校园生活")
    ])
    @State
    var RecommendList: Array<ProductItem> = Array([
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_lamp),
            "护眼台灯", 45, 12, "生活用品"),
        ProductItem(@r(app.media.pdt_bike),
            "捷安特山地车", 320, 1, "运动户外")
    ])

    @State
    var productList: Array<ProductItem> = Array([
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码")
    ])

    var onSearch: (String) -> Unit = {query => ()}
    var onShowDetail: (ProductItem) -> Unit = {
        item => () }
    var onShowLostDetail: (LostItem) -> Unit = {
        item => () }
    var onCategoryClick: (String) -> Unit = {
        cat => () }

    func refreshRecommend() {}

    @State
    var lostItemList: Array<LostItem> = Array([
        LostItem(@r(app.media.lost_bag),
            "黑色双肩包", "书包", "黑色",
            "北区图书馆2楼", "2小时"),
        LostItem(@r(app.media.lost_card),
            "学生证", "证件", "蓝色",
            "南区食堂一楼", "3小时"),
        LostItem(@r(app.media.lost_airpods),
            "AirPodsPro", "电子产品", "白色",
            "体育馆羽毛球场", "5小时"),
        LostItem(@r(app.media.lost_book),
            "《数据结构》", "书籍",
            "蓝色", "东区教学楼305", "6小时"),
        LostItem(@r(app.media.lost_classes),
            "黑框眼镜", "眼镜", "黑色",
            "校园超市门口", "8小时"),
        LostItem(@r(app.media.lost_classes),
            "黑框眼镜", "眼镜", "黑色",
            "校园超市门口", "8小时"),
        LostItem(@r(app.media.lost_classes),
            "黑框眼镜", "眼镜", "黑色",
            "校园超市门口", "8小时"),
        LostItem(@r(app.media.lost_classes),
            "黑框眼镜", "眼镜", "黑色",
            "校园超市门口", "8小时")
    ])

    @Builder
    func renderSchoolBar() {
        Row() {
            Image(@r(app.media.locallg))
                .size(width: 15, height: 15)
            Text(schoolName).fontSize(10).margin(4.vp)
                .fontWeight(FontWeight.Bold)
            Image(@r(app.media.jiantou))
                .size(width: 15, height: 15)
        }.position(x: 15.vp, y: 18.vp)
    }

    @Builder
    func renderSearchRow() {
        Row() {
            TextInput(text: searchText,
                placeholder: "搜索商品、失物、用户")
                .fontSize(12.fp)
                .placeholderFont(size: 12)
            Button() {
                Row() {
                    Text("搜索").fontSize(14.fp)
                        .fontColor(Color.WHITE)
                        .fontWeight(FontWeight.Bold)
                        .margin(left: 4.vp)
                }
            }
            .backgroundColor(Color.GREEN)
            .borderRadius(topLeft: 0.vp,
                bottomLeft: 0.vp,
                topRight: 16.vp,
                bottomRight: 16.vp)
            .width(60.vp).height(30.vp)
            .backgroundColor(0x00AA88)
            .onClick { evt => onSearch(searchText) }
        }
        .layoutWeight(1)
        .backgroundColor(Color.WHITE)
        .borderRadius(16.vp)
        .padding(top: 6.vp, bottom: 6.vp)
        .margin(right: 5.vp)
        .position(x: 15.vp, y: 40.vp)
        .width(290)
    }

    @Builder
    func renderCategoryGrid() {
        Grid() {
            ForEach(
                this.dataList,
                itemGeneratorFunc: {
                    item: GridItemData, index: Int64 =>
                    GridItem {
                        Column() {
                            Image(item.image)
                                .width(48.vp).height(48.vp)
                                .margin(bottom: 8.vp)
                            Text(item.text).fontSize(12.fp)
                                .fontColor(Color.BLACK)
                        }
                        .width(100.percent).height(80.vp)
                        .justifyContent(FlexAlign.Center)
                        .onClick { evt =>
                            onCategoryClick(item.text) }
                    }
                },
                keyGeneratorFunc: {
                    item: GridItemData, index: Int64 =>
                    index.toString()
                }
            )
        }
        .columnsTemplate("1fr 1fr 1fr 1fr")
        .rowsTemplate("1fr 1fr")
        .width(100.percent).height(180.vp)
        .padding(top: 4.vp, bottom: 4.vp)
    }

    @Builder
    func renderRecommendHeader() {
        Row() {
            Text("为你推荐").fontSize(13)
                .fontWeight(FontWeight.Bold)
                .backgroundColor(0xB2EBF2)
            Blank()
            Row() {
                Image(@r(app.media.changelg))
                    .height(100.percent)
                Text("换一批").fontSize(12)
            }.onClick { evt => refreshRecommend() }
        }.margin(bottom: 6, top: 3)
        .width(100.percent)
        .padding(left: 16, right: 16).height(20.vp)
    }

    @Builder
    func renderRecommendGrid() {
        Grid {
            ForEach(
                this.RecommendList,
                itemGeneratorFunc: {
                    item: ProductItem, index: Int64 =>
                    GridItem {
                        Column {
                            Image(item.image)
                                .width(100.percent)
                                .aspectRatio(1)
                                .objectFit(ImageFit.Cover)
                            Text(item.title).fontSize(12)
                                .fontColor(0x333333)
                                .maxLines(2)
                                .textOverflow(
                                    TextOverflow.Ellipsis)
                                .margin(
                                    top: 8, left: 4,
                                    right: 4)
                            Row {
                                Text("￥${item.price}")
                                    .fontSize(14)
                                    .fontWeight(
                                        FontWeight.Bold)
                                    .fontColor(0xFF4444)
                                Blank()
                                Text("喜欢${item.loves}")
                                    .fontSize(10)
                                    .fontColor(0x999999)
                            }
                            .width(100.percent)
                            .margin(
                                top: 4, left: 4,
                                right: 4, bottom: 8)
                            .padding(left: 3, right: 6)
                        }
                        .width(100.percent)
                        .backgroundColor(Color.WHITE)
                        .borderRadius(8)
                        .onClick { evt =>
                            onShowDetail(item) }
                    }
                }
            )
        }
        .columnsTemplate("1fr 1fr 1fr")
        .rowsTemplate("1fr")
        .width(100.percent).height(165)
        .columnsGap(8).rowsGap(8)
        .padding(left: 16, right: 16)
    }

    @Builder
    func renderProductList() {
        Column {
            ForEach(
                this.productList,
                itemGeneratorFunc: {
                    item: ProductItem, index: Int64 =>
                    ProductCard(
                        item: item,
                        onShowDetail: {
                            p => onShowDetail(p) }
                    )
                }
            )
        }.width(100.percent)
        .padding(left: 16, right: 16)
    }

    @Builder func renderProductContent() {
        Stack() {
            renderSchoolBar()
            renderSearchRow()
            Scroll {
                Column() {
                    renderCategoryGrid()
                    renderRecommendHeader()
                    renderRecommendGrid()
                    renderProductList()
                }
            }.width(100.percent).height(100.percent)
            .backgroundColor(0xFFF8F8F8)
            .margin(top: 80)
        }.width(100.percent)
    }

    @Builder
    func renderLostItemCard(item: LostItem) {
        Column {
            Row {
                Image(item.image).width(100).height(100)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                Stack() {
                    Column {
                        Text(item.title).fontSize(16)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0x333333).maxLines(1)
                            .textOverflow(
                                TextOverflow.Ellipsis)
                            .margin(bottom: 8)
                            .width(100.percent)
                        Row {
                            Text(item.category).fontSize(11)
                                .fontColor(0x666666)
                                .backgroundColor(0xFFF0F0F0)
                                .borderRadius(4)
                                .margin(right: 6)
                            Text(item.color).fontSize(11)
                                .fontColor(0x666666)
                                .backgroundColor(0xFFF0F0F0)
                                .borderRadius(4)
                        }.margin(bottom: 8)
                        .width(100.percent)
                        Text(item.location).fontSize(13)
                            .fontColor(0x999999).maxLines(1)
                            .textOverflow(
                                TextOverflow.Ellipsis)
                            .margin(bottom: 8)
                            .width(100.percent)
                        Text(item.time + "前发布")
                            .fontSize(12)
                            .fontColor(0x999999)
                            .width(100.percent)
                    }
                    .padding(left: 12)
                    .justifyContent(FlexAlign.Center)
                    Button("查看详情").fontSize(9)
                        .fontColor(0xFF4CAF50)
                        .backgroundColor(Color.WHITE)
                        .borderWidth(1)
                        .borderColor(0xFF4CAF50)
                        .borderRadius(15)
                        .width(70).height(25)
                        .position(x: 175, y: 55)
                        .onClick { evt =>
                            onShowLostDetail(item) }
                }
            }
            .width(100.percent).padding(12)
            .alignItems(VerticalAlign.Top)
        }.width(100.percent)
        .backgroundColor(Color.WHITE)
    }

    @Builder func renderLostContent() {
        Stack() {
            renderSchoolBar()
            renderSearchRow()
            Scroll {
                Column {
                    ForEach(
                        this.lostItemList,
                        itemGeneratorFunc: {
                            item: LostItem, index: Int64 =>
                            renderLostItemCard(item)
                        }
                    )
                }
            }.width(100.percent).height(100.percent)
            .backgroundColor(0xFFF8F8F8)
            .margin(top: 80)
        }.width(100.percent)
    }

    func build() {
        Stack() {
            Tabs(BarPosition.End) {
                TabContent() {
                    renderProductContent()
                }.tabBar("商品")

                TabContent() {
                    renderLostContent()
                }.tabBar("失物")

                TabContent() {
                    Column() {
                    }.width(100.percent).height(100.percent)
                }.tabBar("")

                TabContent() {
                    Column() {
                        Text("消息").fontSize(14.fp)
                            .fontColor(Color.GRAY)
                    }.width(100.percent).height(100.percent)
                    .justifyContent(FlexAlign.Center)
                }.tabBar("消息")

                TabContent() {
                    Column() {
                        Text("我的").fontSize(14.fp)
                            .fontColor(Color.GRAY)
                    }.width(100.percent).height(100.percent)
                    .justifyContent(FlexAlign.Center)
                }.tabBar("我的")
            }.width(100.percent)
            .backgroundColor(Color.WHITE).barHeight(60)

            Button() {
                Column() {
                    Text("+").fontSize(30.fp)
                        .fontColor(Color.WHITE)
                        .fontWeight(FontWeight.Bold)
                        .margin(top: 2).lineHeight(34)
                    Text("发布").fontSize(12.fp)
                        .fontColor(Color.WHITE)
                        .margin(bottom: 2)
                }
                .width(100.percent).height(100.percent)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
            .width(68.vp).height(68.vp)
            .backgroundColor(0xFF4CAF50)
            .borderRadius(34.vp).onClick {}
            .shadow(radius: 8,
                color: Color(0x664CAF50),
                offsetX: 0, offsetY: 4)
            .position(x: 158, y: 700)
        }
    }
}
