package ohos_app_cangjie_entry
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class PublishPanel {
    @State var businessType: String = BIZ_TYPE_SECONDHAND
    @State var title: String = ""
    @State var description: String = ""
    @State var price: String = ""
    @State var location: String = ""
    @State var imageName: String = "pdt_camera"
    @State var categoryId: Int64 = 0
    @State var errorText: String = ""
    var onCancel: () -> Unit = { => () }
    var onPublished: () -> Unit = { => () }

    func chooseType(t: String) {
        businessType = t
        if (businessType != BIZ_TYPE_SECONDHAND) {
            price = ""
        }
        if (businessType == BIZ_TYPE_LOST) {
            imageName = "lost_card"
            categoryId = 9
        } else if (businessType == BIZ_TYPE_FOUND) {
            imageName = "lost_bag"
            categoryId = 9
        } else {
            imageName = "pdt_camera"
            categoryId = 0
        }
    }

    func chooseImage(name: String) {
        imageName = name
    }

    func submit() {
        if (title == "" || description == "") {
            errorText = "请填写标题和描述"
            return
        }
        if (businessType == BIZ_TYPE_SECONDHAND && price == "") {
            errorText = "请填写价格"
            return
        }
        match (publishPost(businessType, title, description, price, location, categoryId: categoryId, imageName: imageName)) {
            case Some(_) =>
                errorText = ""
                onPublished()
            case None =>
                errorText = "发布失败"
        }
    }

    func activeBg(t: String): UInt32 {
        if (businessType == t) { return 0xFF4CAF50 }
        return 0xFFECEFF5
    }

    func activeFg(t: String): Color {
        if (businessType == t) { return Color.WHITE }
        return Color.BLACK
    }

    @Builder func typeButton(label: String, value: String) {
        Button(label).height(34).fontSize(13)
            .fontColor(activeFg(value))
            .backgroundColor(activeBg(value))
            .margin(right: 8)
            .onClick { evt => chooseType(value) }
    }

    func tagBg(id: Int64): UInt32 {
        if (categoryId == id) { return 0xFF4CAF50 }
        return 0xFFECEFF5
    }

    @Builder func tagButton(label: String, id: Int64) {
        Button(label).height(30).fontSize(12)
            .fontColor(Color.BLACK)
            .backgroundColor(tagBg(id))
            .borderRadius(15)
            .margin(right: 6, bottom: 6)
            .onClick { evt => categoryId = id }
    }

    @Builder func tagChooser() {
        if (businessType != BIZ_TYPE_SECONDHAND) {
            Row() {
                if (businessType == BIZ_TYPE_LOST) {
                    tagButton("证件", 9)
                    tagButton("书包", 10)
                    tagButton("电子", 11)
                    tagButton("书籍", 12)
                } else {
                    tagButton("证件", 9)
                    tagButton("电子", 11)
                    tagButton("其他", 14)
                }
            }.width(100.percent).margin(bottom: 6)
            if (businessType == BIZ_TYPE_LOST) {
                Row() {
                    tagButton("眼镜", 13)
                    tagButton("其他", 14)
                }.width(100.percent).margin(bottom: 6)
            }
        }
    }

    func imageBorder(name: String): UInt32 {
        if (imageName == name) { return 0xFF4CAF50 }
        return 0xFFE0E0E0
    }

    @Builder func imageOption(name: String) {
        Image(getImageResource(name))
            .width(58)
            .height(58)
            .borderRadius(8)
            .borderWidth(2)
            .borderColor(imageBorder(name))
            .objectFit(ImageFit.Cover)
            .margin(right: 8)
            .onClick { evt => chooseImage(name) }
    }

    @Builder func imageChooser() {
        Text("选择图片").fontSize(14)
            .fontColor(0xFF333333)
            .width(100.percent)
            .margin(bottom: 8)
        Row() {
            if (businessType == BIZ_TYPE_SECONDHAND) {
                imageOption("pdt_camera")
                imageOption("pdt_lamp")
                imageOption("pdt_bike")
            } else {
                imageOption("lost_card")
                imageOption("lost_bag")
                imageOption("lost_airpods")
                imageOption("lost_book")
            }
        }.width(100.percent).margin(bottom: 10)
    }

    public func build() {
        Stack() {
            Column() {}
                .width(100.percent)
                .height(100.percent)
                .backgroundColor(0x99000000)
                .onClick { evt => onCancel() }
            Column() {
                Row() {
                    Text("发布信息").fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .layoutWeight(1)
                    Button("关闭").width(54).height(32)
                        .backgroundColor(0xFFECEFF5)
                        .fontColor(Color.BLACK)
                        .onClick { evt => onCancel() }
                }.width(100.percent).margin(bottom: 16)
                Row() {
                    typeButton("二手闲置", BIZ_TYPE_SECONDHAND)
                    typeButton("寻物", BIZ_TYPE_LOST)
                    typeButton("招领", BIZ_TYPE_FOUND)
                }.width(100.percent).margin(bottom: 12)
                TextInput(text: title, placeholder: "标题")
                    .onChange { val => title = val }
                    .margin(bottom: 10)
                TextInput(text: description, placeholder: "详细描述")
                    .onChange { val => description = val }
                    .margin(bottom: 10)
                if (businessType == BIZ_TYPE_SECONDHAND) {
                    TextInput(text: price, placeholder: "价格")
                        .onChange { val => price = val }
                        .margin(bottom: 10)
                }
                TextInput(text: location, placeholder: "地点")
                    .onChange { val => location = val }
                    .margin(bottom: 10)
                tagChooser()
                imageChooser()
                if (errorText != "") {
                    Text(errorText).fontSize(12)
                        .fontColor(Color.RED)
                        .width(100.percent)
                        .margin(bottom: 8)
                }
                Button("提交发布").width(100.percent)
                    .height(42)
                    .fontColor(Color.WHITE)
                    .backgroundColor(0xFF4CAF50)
                    .onClick { evt => submit() }
            }.width(88.percent)
            .padding(18)
            .backgroundColor(Color.WHITE)
            .borderRadius(12)
            .position(x: 24, y: 120)
        }.width(100.percent).height(100.percent)
    }
}

