package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry @Component
public class AppRouter {
    @State
    var routeIndex: Int = 0
    @State
    var loginUsername: String = ""
    @State var loginPassword: String = ""

    @State var registerUsername: String = ""
    @State var registerPassword: String = ""
    @State var showRegisterPanel: Bool = false
    @State var showSearchResult: Bool = false
    @State var searchQuery: String = ""
    @State var showProductDetail: Bool = false
    @State var detailProduct: ProductItem = ProductItem(
        @r(app.media.pdt_camera), "", 0, 0, "")
    @State var showLostDetail: Bool = false
    @State var detailLostItem: LostItem = LostItem(
        @r(app.media.lost_bag), "", "", "", "", "")
    @State var showCategory: Bool = false
    @State var selectedCategory: String = ""

    @State
    var sampleProducts: Array<ProductItem> = Array([
        ProductItem(@r(app.media.pdt_camera),
            "佳能EOSM50", 1680, 23, "电子数码"),
        ProductItem(@r(app.media.pdt_lamp),
            "护眼台灯可调光", 45, 12, "生活用品"),
        ProductItem(@r(app.media.pdt_bike),
            "捷安特山地车", 320, 1, "运动户外"),
        ProductItem(@r(app.media.pdt_camera),
            "索尼A6000微单", 2200, 56, "电子数码"),
        ProductItem(@r(app.media.pdt_bike),
            "美利达公爵600", 800, 15, "运动户外"),
        ProductItem(@r(app.media.pdt_lamp),
            "小米台灯Pro", 189, 32, "生活用品"),
        ProductItem(@r(app.media.pdt_camera),
            "富士拍立得", 499, 78, "电子数码"),
        ProductItem(@r(app.media.pdt_bike),
            "折叠滑板车", 650, 42, "运动户外"),
        ProductItem(@r(app.media.pdt_lamp),
            "USB充电小夜灯", 25, 156, "生活用品"),
        ProductItem(@r(app.media.pdt_camera),
            "GoPro运动相机", 1500, 9, "电子数码"),
        ProductItem(@r(app.media.pdt_bike),
            "瑜伽垫加厚", 68, 88, "运动户外"),
        ProductItem(@r(app.media.pdt_lamp),
            "酷毙灯磁吸款", 39, 203, "生活用品"),
        ProductItem(@r(app.media.pdt_camera),
            "AirPodsPro", 1299, 334, "电子数码"),
        ProductItem(@r(app.media.pdt_bike),
            "哑铃套装20kg", 168, 55, "运动户外"),
        ProductItem(@r(app.media.pdt_lamp),
            "LED护眼台灯", 128, 67, "生活用品")
    ])

    func onSearch(query: String) {
        searchQuery = query; showSearchResult = true
    }

    func onBackFromSearch() {
        showSearchResult = false; searchQuery = ""
    }

    func onShowDetail(item: ProductItem) {
        detailProduct = item; showProductDetail = true
    }

    func onBackFromDetail() {
        showProductDetail = false
    }

    func onShowLostDetail(item: LostItem) {
        detailLostItem = item; showLostDetail = true
    }

    func onBackFromLostDetail() {
        showLostDetail = false
    }

    func onCategoryClick(category: String) {
        selectedCategory = category; showCategory = true
    }

    func onBackFromCategory() {
        showCategory = false; selectedCategory = ""
    }

    func getSearchResults(): Array<ProductItem> {
        if (searchQuery == "") { return sampleProducts }
        var count = 0
        for (item in sampleProducts) {
            if (item.title.contains(searchQuery)) {
                count++ } }
        var result = Array<ProductItem>(
            count, {i => sampleProducts[0]})
        var idx = 0
        for (item in sampleProducts) {
            if (item.title.contains(searchQuery)) {
                result[idx] = item; idx++ } }
        return result
    }

    func onRegisterClick() {
        AppLog.info("Register clicked")
    }

    func onLoginSuccess() { routeIndex = 1 }

    func onRegisterSuccess() {
        AppLog.info(
            "Registration successful:${registerUsername}")
        loginUsername = registerUsername
        loginPassword = ""
        showRegisterPanel = false
    }

    @Builder
    func renderAuthPanel() {
        Stack() {
            if (!showRegisterPanel) {
                Column() {
                    Text("欢迎回来").fontSize(40.fp)
                        .fontWeight(FontWeight.Bold)
                        .margin(bottom: 16)
                    Text("登录你的账号").fontSize(18.fp)
                        .fontColor(0x999999)
                        .margin(bottom: 48)
                    TextInput(text: loginUsername,
                        placeholder: "请输入账号")
                        .fontSize(18.fp).width(100.percent)
                        .height(56).margin(bottom: 20)
                    TextInput(text: loginPassword,
                        placeholder: "请输入密码")
                        .fontSize(18.fp).width(100.percent)
                        .height(56).margin(bottom: 32)
                    Text("忘记密码?").fontSize(16.fp)
                        .fontColor(0x999999)
                        .margin(bottom: 40)
                    Button() {
                        Row() {
                            Text("登录").fontSize(20.fp)
                                .fontColor(Color.WHITE) } }
                    .width(100.percent).height(56)
                    .borderRadius(28)
                    .backgroundColor(0xFF13A56F)
                    .onClick{evt => onLoginSuccess()}
                    .margin(bottom: 32)
                    Row() {
                        Text("还没有账号？").fontSize(16.fp)
                            .fontColor(0x999999)
                        Text("去注册").fontSize(16.fp)
                            .fontColor(0x41AE3C) }
                    .onClick{
                        evt => showRegisterPanel = true }
                }.width(100.percent).height(100.percent)
                .backgroundColor(Color.WHITE).padding(32)
            } else {
                Column() {
                    Text("创建账户").fontSize(40.fp)
                        .fontWeight(FontWeight.Bold)
                        .margin(bottom: 16)
                    Text("注册新账号").fontSize(18.fp)
                        .fontColor(0x999999)
                        .margin(bottom: 40)
                    TextInput(text: registerUsername,
                        placeholder: "请输入账号")
                        .fontSize(18.fp).width(100.percent)
                        .height(56).margin(bottom: 20)
                    TextInput(text: registerPassword,
                        placeholder: "请输入密码")
                        .fontSize(18.fp).width(100.percent)
                        .height(56).margin(bottom: 32)
                    Button() {
                        Row() {
                            Text("注册").fontSize(20.fp)
                                .fontColor(Color.WHITE) } }
                    .width(100.percent).height(56)
                    .borderRadius(28)
                    .backgroundColor(0xFF13A56F)
                    .onClick{
                        evt => onRegisterSuccess() }
                    .margin(bottom: 32)
                    Row() {
                        Text("已有账号？").fontSize(16.fp)
                            .fontColor(0x999999)
                        Text("去登录").fontSize(16.fp)
                            .fontColor(0x41AE3C) }
                    .onClick{
                        evt => showRegisterPanel = false }
                }.width(100.percent).height(100.percent)
                .backgroundColor(Color.WHITE).padding(32)
            }
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xF5F5F5).align(Alignment.Center)
    }

    @Builder
    func renderHomePanel() {
        Stack() {
            Homeview(
                onSearch: { query => onSearch(query) },
                onShowDetail: {
                    item => onShowDetail(item) },
                onShowLostDetail: {
                    item => onShowLostDetail(item) },
                onCategoryClick: {
                    cat => onCategoryClick(cat) }
            )
        }
    }

    func build() {
        Stack() {
            if (routeIndex == 0) {
                renderAuthPanel()
            } else if (showProductDetail) {
                ProductDetail(
                    item: detailProduct,
                    description: "卖家自用九成新,功能完好，配件齐全，支持自提或邮寄。",
                    onBack: { => onBackFromDetail() }
                )
            } else if (showLostDetail) {
                LostDetail(
                    item: detailLostItem,
                    onBack: { => onBackFromLostDetail() }
                )
            } else if (showCategory) {
                CategoryPage(
                    selectedCategory: selectedCategory,
                    allProducts: sampleProducts,
                    onBack: { => onBackFromCategory() },
                    onShowDetail: {
                        item => onShowDetail(item) }
                )
            } else if (showSearchResult) {
                SearchResultView(
                    searchQuery: searchQuery,
                    results: getSearchResults(),
                    onBack: { => onBackFromSearch() },
                    onSearch: {
                        query => onSearch(query) },
                    onShowDetail: {
                        item => onShowDetail(item) }
                )
            } else {
                renderHomePanel()
            }
        }
    }
}
