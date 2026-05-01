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

    public func findByPost(
        postId: Int64,
        page: Int64,
        size: Int64
    ): ArrayList<Message> {
        let all = ArrayList<Message>()
        for ((_, m) in store) {
            match (m.postId) {
                case Some(pid) =>
                    if (pid == postId &&
                        m.messageType ==
                        MessageType.PUBLIC_COMMENT) {
                        all.add(m)
                    }
                case None => ()
            }
        }
        let from = (page - 1) * size
        let result = ArrayList<Message>()
        var i = from
        while (i < from + size &&
            i < Int64(all.size)) {
            result.add(all[i])
            i++
        }
        return result
    }

    public func countByPost(
        postId: Int64
    ): Int64 {
        var c: Int64 = 0
        for ((_, m) in store) {
            match (m.postId) {
                case Some(pid) =>
                    if (pid == postId &&
                        m.messageType ==
                        MessageType.PUBLIC_COMMENT) {
                        c++
                    }
                case None => ()
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
        let all = ArrayList<Message>()
        for ((_, m) in store) {
            if (m.messageType !=
                MessageType.PRIVATE_MESSAGE) {
                continue
            }
            let toB = match (m.toUserId) {
                case Some(uid) => uid == userB
                case None      => false
            }
            let toA = match (m.toUserId) {
                case Some(uid) => uid == userA
                case None      => false
            }
            if ((m.fromUserId == userA && toB) ||
                (m.fromUserId == userB && toA)) {
                all.add(m)
            }
        }
        let from = (page - 1) * size
        let result = ArrayList<Message>()
        var i = from
        while (i < from + size &&
            i < Int64(all.size)) {
            result.add(all[i])
            i++
        }
        return result
    }

    public func findByUser(
        userId: Int64,
        msgType: Option<MessageType>,
        isRead: Option<Bool>,
        page: Int64,
        size: Int64
    ): ArrayList<Message> {
        let all = ArrayList<Message>()
        for ((_, m) in store) {
            var found = false
            match (m.toUserId) {
                case Some(uid) =>
                    if (uid == userId) {
                        found = true
                    }
                case None => ()
            }
            if (m.fromUserId == userId) {
                found = true
            }
            if (!found) { continue }

            match (msgType) {
                case Some(mt) =>
                    if (m.messageType != mt) {
                        continue
                    }
                case None => ()
            }
            match (isRead) {
                case Some(rd) =>
                    if (m.isRead != rd) {
                        continue
                    }
                case None => ()
            }
            all.add(m)
        }
        let from = (page - 1) * size
        let result = ArrayList<Message>()
        var i = from
        while (i < from + size &&
            i < Int64(all.size)) {
            result.add(all[i])
            i++
        }
        return result
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

// ===== AuditRepository =====
public class AuditRepository {
    private var store:
        HashMap<Int64, AuditRecord> =
        HashMap<Int64, AuditRecord>()
    private var nextId: Int64 = 1

    private static var inst:
        Option<AuditRepository> = None

    private init() {}

    public static func getInstance()
        : AuditRepository
    {
        match (inst) {
            case Some(r) => return r
            case None =>
                let r = AuditRepository()
                inst = Some(r)
                return r
        }
    }

    public func save(
        record: AuditRecord
    ): AuditRecord {
        if (record.id == 0) {
            record.id = nextId
            nextId++
        }
        store.add(record.id, record)
        return record
    }

    public func findByPost(
        postId: Int64
    ): ArrayList<AuditRecord> {
        let result = ArrayList<AuditRecord>()
        for ((_, r) in store) {
            if (r.postId == postId) {
                result.add(r)
            }
        }
        return result
    }
}
