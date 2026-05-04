package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class MessageCenter {
    @State var messages: Array<MessageVO> = Array(0, { i => MessageVO() })
    var onShowDetail: (Int64) -> Unit = { id => () }

    public func aboutToAppear() {
        messages = getMessageCenter(getSessionUserId())
    }

    func messageTypeLabel(t: String): String {
        if (t == MSG_PRIVATE_MESSAGE) { return "私信" }
        return "留言"
    }

    @Builder func renderMessage(item: MessageVO) {
        Column() {
            Row() {
                Text(messageTypeLabel(item.message_type))
                    .fontSize(11)
                    .fontColor(Color.WHITE)
                    .backgroundColor(0xFF4CAF50)
                    .borderRadius(4)
                    .padding(left: 6, right: 6,
                        top: 2, bottom: 2)
                    .margin(right: 8)
                Text(item.from_user.nickname)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF333333)
                    .layoutWeight(1)
                Text(item.created_at)
                    .fontSize(11)
                    .fontColor(0xFF999999)
            }.width(100.percent).margin(bottom: 8)
            Text(item.content).fontSize(14)
                .fontColor(0xFF666666)
                .width(100.percent)
                .margin(bottom: 10)
            Button("查看帖子").height(30).width(76)
                .fontSize(12)
                .fontColor(Color.WHITE)
                .backgroundColor(0xFF4CAF50)
                .onClick { evt => onShowDetail(item.post_id) }
        }.padding(14)
        .backgroundColor(Color.WHITE)
        .borderRadius(8)
        .margin(left: 16, right: 16, bottom: 10)
        .width(100.percent)
    }

    public func build() {
        Column() {
            Text("消息中心").fontSize(20)
                .fontWeight(FontWeight.Bold)
                .width(100.percent)
                .margin(left: 16, top: 18, bottom: 14)
            if (messages.size == 0) {
                Column() {
                    Text("暂无留言或站内信").fontSize(16)
                        .fontColor(0xFF999999)
                }.width(100.percent)
                .height(100.percent)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            } else {
                Scroll() {
                    Column() {
                        ForEach(messages,
                            itemGeneratorFunc: {
                                item: MessageVO,
                                index: Int64 => renderMessage(item)
                            },
                            keyGeneratorFunc: {
                                item: MessageVO,
                                index: Int64 => item.id.toString()
                            })
                    }.width(100.percent)
                    .padding(bottom: 80)
                }.layoutWeight(1)
            }
        }.width(100.percent).height(100.percent)
        .backgroundColor(0xFFF5F7FA)
    }
}

