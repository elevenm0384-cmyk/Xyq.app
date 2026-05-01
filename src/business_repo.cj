package cangjie

import std.collection.*

// ===== MessageRepository =====
public class MessageRepository {
    private var store:
        HashMap<Int64, Message> =
        HashMap<Int64, Message>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<MessageRepository> = None

    private init() {}

    public static func getInstance()
        : MessageRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = MessageRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(msg: Message): Message {
        if (msg.id == 0) {
            msg.id = nextId
            nextId++
        }
        store.add(msg.id, msg)
        return msg
    }

    public func findById(
        id: Int64
    ): Option<Message> {
        return store.get(id)
    }

    public func findByTarget(
        targetType: String,
        targetId: Int64,
        page: Int64,
        size: Int64
    ): ArrayList<Message> {
        let result = ArrayList<Message>()
        for ((_, m) in store) {
            if (m.targetType == targetType &&
                m.targetId == targetId &&
                m.msgType == MessageType.Comment) {
                result.add(m)
            }
        }
        // 分页截取
        let from = (page - 1) * size
        let paged = ArrayList<Message>()
        var i = from
        while (i < from + size &&
            i < Int64(result.size)) {
            paged.add(result[i])
            i++
        }
        return paged
    }

    public func countByTarget(
        targetType: String,
        targetId: Int64
    ): Int64 {
        var c: Int64 = 0
        for ((_, m) in store) {
            if (m.targetType == targetType &&
                m.targetId == targetId &&
                m.msgType == MessageType.Comment) {
                c++
            }
        }
        return c
    }

    public func findPrivateMsgs(
        userA: Int64,
        userB: Int64,
        page: Int64,
        size: Int64
    ): ArrayList<Message> {
        let result = ArrayList<Message>()
        for ((_, m) in store) {
            if (m.msgType != MessageType.PrivateMsg) {
                continue
            }
            let matchAB = (m.fromUserId == userA)
            let matchBA = (m.fromUserId == userB)
            let toA = match (m.toUserId) {
                case Some(uid) => uid == userA
                case None      => false
            }
            let toB = match (m.toUserId) {
                case Some(uid) => uid == userB
                case None      => false
            }
            if ((matchAB && toB) ||
                (matchBA && toA)) {
                result.add(m)
            }
        }
        let from = (page - 1) * size
        let paged = ArrayList<Message>()
        var i = from
        while (i < from + size &&
            i < Int64(result.size)) {
            paged.add(result[i])
            i++
        }
        return paged
    }

    public func countUnread(
        userId: Int64
    ): Int64 {
        var c: Int64 = 0
        for ((_, m) in store) {
            match (m.toUserId) {
                case Some(uid) =>
                    if (uid == userId && !m.isRead) {
                        c++
                    }
                case None => ()
            }
        }
        return c
    }

    public func markRead(
        msgId: Int64
    ): Bool {
        match (store.get(msgId)) {
            case Some(m) =>
                m.isRead = true
                return true
            case None => return false
        }
    }
}

// ===== ReviewRepository =====
public class ReviewRepository {
    private var store:
        HashMap<Int64, ReviewRecord> =
        HashMap<Int64, ReviewRecord>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<ReviewRepository> = None

    private init() {}

    public static func getInstance()
        : ReviewRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = ReviewRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(
        record: ReviewRecord
    ): ReviewRecord {
        if (record.id == 0) {
            record.id = nextId
            nextId++
        }
        store.add(record.id, record)
        return record
    }

    public func findByTarget(
        targetType: String,
        targetId: Int64
    ): ArrayList<ReviewRecord> {
        let result = ArrayList<ReviewRecord>()
        for ((_, r) in store) {
            if (r.targetType == targetType &&
                r.targetId == targetId) {
                result.add(r)
            }
        }
        return result
    }

    public func countByTarget(
        targetType: String,
        targetId: Int64
    ): Int64 {
        var c: Int64 = 0
        for ((_, r) in store) {
            if (r.targetType == targetType &&
                r.targetId == targetId) {
                c++
            }
        }
        return c
    }
}
