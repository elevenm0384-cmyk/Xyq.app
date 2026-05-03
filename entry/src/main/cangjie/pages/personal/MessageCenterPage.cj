/**
 * Created on 2026/5/3
 */
package pages.personal
import models.*
import services.*

@Entry
@Component
public class MessageCenterPage {
    @State var publicMessages: Array<MessageVO> = []
    @State var privateMessages: Array<MessageVO> = []

    protected override func onPageShow() {
        publicMessages = MockApi.getMessages("PUBLIC_COMMENT")
        privateMessages = MockApi.getMessages("PRIVATE_MESSAGE")
    }

    public func build() {
        Column() {
            Text("消息中心").fontSize(22).fontWeight(FontWeight.Bold).margin(16)

            Tabs({ barPosition: BarPosition.Start }) {
                TabContent() {
                    MessageList(publicMessages)
                }.tabBar("帖子留言")

                TabContent() {
                    MessageList(privateMessages)
                }.tabBar("站内私信")
            }.layoutWeight(1)

        }.width("100%").height("100%").backgroundColor("#F5F7FA")
    }

    @Builder func MessageList(list: Array<MessageVO>) {
        List({ space: 10 }) {
            ForEach(list, { item: MessageVO =>
                ListItem() {
                    Column() {
                        Row() {
                            Text(item.from_nickname).fontWeight(FontWeight.Bold).fontSize(16).layoutWeight(1)
                            Text(item.created_at).fontSize(12).fontColor(Color.Gray)
                        }.width("100%").margin({ bottom: 10 })
                        Text(item.content).fontSize(14).width("100%")
                    }.padding(16).backgroundColor(Color.White).borderRadius(8)
                }
            })
        }.padding(16).width("100%").height("100%")
    }
}