package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry @Component
public class AppRouter {
    @State var routeIndex: Int64 = 0
    @State var loginUsername: String = ""
    @State var loginPassword: String = ""
    @State var loginError: String = ""
    @State var registerUsername: String = ""
    @State var registerPassword: String = ""
    @State var registerNickname: String = ""
    @State var registerPhone: String = ""
    @State var registerError: String = ""
    @State var showRegisterPanel: Bool = false
    @State var showSearchResult: Bool = false
    @State var searchQuery: String = ""
    @State var showProductDetail: Bool = false
    @State var detailPostId: Int64 = 0
    @State var showLostDetail: Bool = false
    @State var detailLostId: Int64 = 0
    @State var showCategory: Bool = false
    @State var selectedCategoryId: Int64 = 0
    @State var selectedCategoryName: String = ""
    @State var categorySceneType: String
        = SCENE_SECONDHAND
    @State var showHistory: Bool = false
    @State var refreshKey: Int64 = 0

    func onLogin() {
        if (loginUsername == ""
            || loginPassword == "") {
            loginError = "请输入用户名和密码"
            return
        }
        match (login(loginUsername,
            loginPassword)) {
            case Some(_) =>
                loginError = ""
                routeIndex = 1
            case None =>
                loginError = "用户名或密码错误"
        }
    }

    func onRegister() {
        if (registerUsername == ""
            || registerPassword == ""
            || registerNickname == "") {
            registerError = "请填写完整信息"
            return
        }
        match (register(registerUsername,
            registerPassword,
            registerNickname,
            registerPhone)) {
            case Some(_) =>
                registerError = ""
                loginUsername = registerUsername
                loginPassword = ""
                showRegisterPanel = false
                routeIndex = 1
            case None =>
                registerError = "用户名已存在"
        }
    }

    func onSearch(query: String) {
        searchQuery = query
        showSearchResult = true
    }

    func onBackFromSearch() {
        showSearchResult = false
        searchQuery = ""
    }

    func onShowDetail(postId: Int64) {
        detailPostId = postId
        showProductDetail = true
    }

    func onBackFromDetail() {
        showProductDetail = false
        refreshKey++
    }

    func onShowLostDetail(postId: Int64) {
        detailLostId = postId
        showLostDetail = true
    }

    func onBackFromLostDetail() {
        showLostDetail = false
        refreshKey++
    }

    func onCategoryClick(
        catId: Int64, catName: String) {
        selectedCategoryId = catId
        selectedCategoryName = catName
        categorySceneType = SCENE_SECONDHAND
        showCategory = true
    }

    func onLostCategoryClick(
        catId: Int64, catName: String) {
        selectedCategoryId = catId
        selectedCategoryName = catName
        categorySceneType = SCENE_LOST
        showCategory = true
    }

    func onBackFromCategory() {
        showCategory = false
        selectedCategoryId = 0
        selectedCategoryName = ""
        categorySceneType = SCENE_SECONDHAND
    }

    func onShowHistory() { showHistory = true }

    func onBackFromHistory() {
        showHistory = false
    }

    @Builder
    func renderAuthPanel() {
        Stack() {
            if (!showRegisterPanel) {
                Column() {
                    Text("欢迎回来").fontSize(40.fp)
                        .fontWeight(FontWeight.Bold)
                        .margin(bottom: 16)
                    Text("登录你的账号")
                        .fontSize(18.fp)
                        .fontColor(0x999999)
                        .margin(bottom: 48)
                    TextInput(
                        text: loginUsername,
                        placeholder: "请输入账号")
                        .fontSize(18.fp)
                        .width(100.percent).height(56)
                        .margin(bottom: 20)
                        .onChange { val =>
                            loginUsername = val }
                    TextInput(
                        text: loginPassword,
                        placeholder: "请输入密码")
                        .fontSize(18.fp)
                        .width(100.percent).height(56)
                        .margin(bottom: 8)
                        .onChange { val =>
                            loginPassword = val }
                    if (loginError != "") {
                        Text(loginError)
                            .fontSize(14.fp)
                            .fontColor(Color.RED)
                            .margin(bottom: 8)
                    }
                    Button() {
                        Row() {
                            Text("登录")
                                .fontSize(20.fp)
                                .fontColor(Color.WHITE)
                        }
                    }.width(100.percent).height(56)
                    .borderRadius(28)
                    .backgroundColor(0xFF13A56F)
                    .onClick{evt => onLogin()}
                    .margin(bottom: 32)
                    Row() {
                        Text("还没有账号？")
                            .fontSize(16.fp)
                            .fontColor(0x999999)
                        Text("去注册")
                            .fontSize(16.fp)
                            .fontColor(0x41AE3C)
                    }.onClick{evt =>
                        showRegisterPanel = true}
                }.width(100.percent)
                .height(100.percent)
                .backgroundColor(Color.WHITE)
                .padding(32)
            } else {
                Column() {
                    Text("创建账户").fontSize(40.fp)
                        .fontWeight(FontWeight.Bold)
                        .margin(bottom: 16)
                    Text("注册新账号")
                        .fontSize(18.fp)
                        .fontColor(0x999999)
                        .margin(bottom: 40)
                    TextInput(
                        text: registerUsername,
                        placeholder: "请输入账号")
                        .fontSize(18.fp)
                        .width(100.percent).height(56)
                        .margin(bottom: 20)
                        .onChange { val =>
                            registerUsername = val }
                    TextInput(
                        text: registerPassword,
                        placeholder: "请输入密码")
                        .fontSize(18.fp)
                        .width(100.percent).height(56)
                        .margin(bottom: 20)
                        .onChange { val =>
                            registerPassword = val }
                    TextInput(
                        text: registerNickname,
                        placeholder: "请输入昵称")
                        .fontSize(18.fp)
                        .width(100.percent).height(56)
                        .margin(bottom: 20)
                        .onChange { val =>
                            registerNickname = val }
                    TextInput(
                        text: registerPhone,
                        placeholder: "请输入手机号(选填)")
                        .fontSize(18.fp)
                        .width(100.percent).height(56)
                        .margin(bottom: 8)
                        .onChange { val =>
                            registerPhone = val }
                    if (registerError != "") {
                        Text(registerError)
                            .fontSize(14.fp)
                            .fontColor(Color.RED)
                            .margin(bottom: 8)
                    }
                    Button() {
                        Row() {
                            Text("注册")
                                .fontSize(20.fp)
                                .fontColor(Color.WHITE)
                        }
                    }.width(100.percent).height(56)
                    .borderRadius(28)
                    .backgroundColor(0xFF13A56F)
                    .onClick{evt => onRegister()}
                    .margin(bottom: 32)
                    Row() {
                        Text("已有账号？")
                            .fontSize(16.fp)
                            .fontColor(0x999999)
                        Text("去登录")
                            .fontSize(16.fp)
                            .fontColor(0x41AE3C)
                    }.onClick{evt =>
                        showRegisterPanel = false}
                }.width(100.percent)
                .height(100.percent)
                .backgroundColor(Color.WHITE)
                .padding(32)
            }
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xF5F5F5)
        .align(Alignment.Center)
    }

    @Builder
    func renderHomePanel() {
        Homeview(
            refreshKey: refreshKey,
            onSearch: { query =>
                onSearch(query) },
            onShowDetail: { id =>
                onShowDetail(id) },
            onShowLostDetail: { id =>
                onShowLostDetail(id) },
            onCategoryClick: { catId, catName =>
                onCategoryClick(catId, catName) },
            onLostCategoryClick: {
                catId, catName =>
                onLostCategoryClick(
                    catId, catName) },
            onShowHistory: { =>
                onShowHistory() })
    }

    func build() {
        Stack() {
            if (routeIndex == 0) {
                renderAuthPanel()
            } else {
                renderHomePanel()

                if (showSearchResult) {
                    SearchResultView(
                        searchQuery: searchQuery,
                        onBack: { =>
                            onBackFromSearch() },
                        onSearch: { query =>
                            onSearch(query) },
                        onShowDetail: { id =>
                            onShowDetail(id) },
                        onShowLostDetail: { id =>
                            onShowLostDetail(id) })
                }

                if (showHistory) {
                    MyHistory(
                        onBack: { =>
                            onBackFromHistory() },
                        onShowDetail: { id =>
                            onShowDetail(id) },
                        onShowLostDetail: { id =>
                            onShowLostDetail(id) })
                }

                if (showCategory) {
                    CategoryPage(
                        sceneType: categorySceneType,
                        selectedCategoryId:
                            selectedCategoryId,
                        selectedCategoryName:
                            selectedCategoryName,
                        onBack: { =>
                            onBackFromCategory() },
                        onShowDetail: { id =>
                            onShowDetail(id) })
                }

                if (showProductDetail) {
                    ProductDetail(
                        postId: detailPostId,
                        onBack: { =>
                            onBackFromDetail() })
                }

                if (showLostDetail) {
                    LostDetail(
                        postId: detailLostId,
                        onBack: { =>
                            onBackFromLostDetail() })
                }
            }
        }
    }
}
