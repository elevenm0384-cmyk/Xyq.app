/**
 * Created on 2026/5/3
 */
package models

public class PostSummaryVO {
    public var id: Int64
    public var author_nickname: String
    public var business_type: String // SECONDHAND / LOST / FOUND
    public var title: String
    public var price: Float64
    public var location: String
    public var audit_status: String // PENDING / APPROVED / REJECTED
    public var biz_status: String   // ON_SALE / OPEN / SOLD 等
    public var created_at: String

    public init(id: Int64, author_nickname: String, business_type: String, title: String, price: Float64, location: String, audit_status: String, biz_status: String, created_at: String) {
        this.id = id
        this.author_nickname = author_nickname
        this.business_type = business_type
        this.title = title
        this.price = price
        this.location = location
        this.audit_status = audit_status
        this.biz_status = biz_status
        this.created_at = created_at
    }
}

public class MessageVO {
    public var id: Int64
    public var from_nickname: String
    public var message_type: String // PUBLIC_COMMENT / PRIVATE_MESSAGE
    public var content: String
    public var created_at: String

    public init(id: Int64, from_nickname: String, message_type: String, content: String, created_at: String) {
        this.id = id
        this.from_nickname = from_nickname
        this.message_type = message_type
        this.content = content
        this.created_at = created_at
    }
}