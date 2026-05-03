package cangjie
import std.net.*
import std.collection.*

public class HttpRequest {
    public var method: String = "GET"
    public var path: String = "/"
    public var query: String = ""
    public var headers:
        HashMap<String, String> =
        HashMap<String, String>()
    public var body: String = ""
    public var rawBody:
        Array<UInt8> = Array<UInt8>(
        0, { _ => 0_u8 })
    public var params:
        HashMap<String, String> =
        HashMap<String, String>()
}

public class HttpResponse {
    public var statusCode: Int64 = 200
    var hdrs:
        HashMap<String, String> =
        HashMap<String, String>()
    public var bodyStr: String = ""

    public init() {}

    public func setStatus(
        code: Int64
    ): HttpResponse {
        this.statusCode = code
        return this
    }

    public func setHeader(
        key: String, val: String
    ): HttpResponse {
        this.hdrs.add(key, val)
        return this
    }

    public func setBody(
        body: String
    ): HttpResponse {
        this.bodyStr = body
        return this
    }

    func buildResp(): String {
        var resp = "HTTP/1.1 " +
            this.statusCode.toString() +
            " " + respStatus(this.statusCode) +
            "\r\n"
        this.hdrs.add(
            "Content-Length",
            this.bodyStr.size.toString())
        this.hdrs.add(
            "Content-Type",
            "application/json; charset=utf-8")
        this.hdrs.add(
            "Access-Control-Allow-Origin", "*")
        this.hdrs.add(
            "Access-Control-Allow-Methods",
            "GET, POST, PUT, DELETE, OPTIONS")
        this.hdrs.add(
            "Access-Control-Allow-Headers",
            "Content-Type, Authorization")
        for ((k, v) in this.hdrs) {
            resp = resp + k + ": " + v + "\r\n"
        }
        resp = resp + "\r\n" + this.bodyStr
        return resp
    }

    func respStatus(code: Int64): String {
        if (code == 200) { return "OK" }
        if (code == 201) { return "Created" }
        if (code == 204) { return "No Content" }
        if (code == 400) { return "Bad Request" }
        if (code == 401) {
            return "Unauthorized"
        }
        if (code == 403) { return "Forbidden" }
        if (code == 404) { return "Not Found" }
        if (code == 405) {
            return "Method Not Allowed"
        }
        if (code == 500) {
            return "Internal Server Error"
        }
        return "OK"
    }
}

public type Handler =
    (HttpRequest) -> HttpResponse

public class HttpServer {
    var routes:
        HashMap<String, Handler> =
        HashMap<String, Handler>()
    var paramRoutes:
        ArrayList<(String, String, Handler)> =
        ArrayList<(String, String, Handler)>()

    public init() {}

    public func get(
        path: String, handler: Handler
    ) {
        routes.add("GET:" + path, handler)
    }
    public func post(
        path: String, handler: Handler
    ) {
        routes.add("POST:" + path, handler)
    }
    public func put(
        path: String, handler: Handler
    ) {
        routes.add("PUT:" + path, handler)
    }
    public func delete(
        path: String, handler: Handler
    ) {
        routes.add("DELETE:" + path, handler)
    }

    public func addParam(
        method: String,
        pattern: String,
        handler: Handler
    ) {
        paramRoutes.add(
            (method, pattern, handler))
    }

    public func start(port: UInt16) {
        let server = TcpServerSocket(
            bindAt: port)
        server.bind()
        while (true) {
            let conn = server.accept()
            spawn { processConn(conn) }
        }
    }

    func processConn(conn: TcpSocket) {
        let buf = Array<UInt8>(
            4096, { _ => 0_u8 })
        let n = conn.read(buf)
        if (n > 0) {
            let raw = String.fromUtf8(
                buf[0..n])
            let req = parseHttp(raw)
            extractRawBody(req, buf, n)
            if (req.method == "OPTIONS") {
                let resp = HttpResponse()
                    .setStatus(200)
                    .setBody("")
                conn.write(
                    resp.buildResp().toArray())
            } else {
                let resp = dispatch(req)
                conn.write(
                    resp.buildResp().toArray())
            }
        }
        conn.close()
    }

    func extractRawBody(
        req: HttpRequest,
        buf: Array<UInt8>,
        n: Int64
    ) {
        var i: Int64 = 0
        var bodyStart: Int64 = -1
        while (i < n - 3) {
            if (buf[i] == 0x0d_u8 &&
                buf[i + 1] == 0x0a_u8 &&
                buf[i + 2] == 0x0d_u8 &&
                buf[i + 3] == 0x0a_u8
            ) {
                bodyStart = i + 4
                break
            }
            i = i + 1
        }
        let start = bodyStart
        if (start > 0 && start < n) {
            let bodyLen = n - start
            req.rawBody = Array<UInt8>(
                bodyLen,
                { idx => buf[start + idx] })
        }
    }

    func dispatch(
        req: HttpRequest
    ): HttpResponse {
        let key = req.method +
            ":" + req.path
        if (routes.contains(key)) {
            let handler = routes[key]
            return handler(req)
        }
        return matchParam(req)
    }

    func matchParam(
        req: HttpRequest
    ): HttpResponse {
        let pp = splitPath(req.path)
        for ((method, pattern, handler)
            in paramRoutes) {
            if (method != req.method) {
                continue
            }
            let patParts = splitPath(pattern)
            if (pp.size != patParts.size) {
                continue
            }
            var ok = true
            req.params.clear()
            for (i in 0..pp.size) {
                let patSeg = patParts[i]
                let reqSeg = pp[i]
                if (patSeg.size > 0 &&
                    patSeg[0] == 0x3a_u8
                ) {
                    req.params.add(
                        patSeg[1..patSeg.size],
                        reqSeg)
                } else if (patSeg != reqSeg) {
                    ok = false
                    break
                }
            }
            if (ok) { return handler(req) }
        }
        return HttpResponse()
            .setStatus(404)
            .setBody(
                "{\"code\":1006," +
                "\"message\":\"not found\"," +
                "\"data\":null}")
    }
}

func splitPath(
    p: String
): ArrayList<String> {
    let parts = ArrayList<String>()
    if (p == "/" || p.size == 0) {
        parts.add("")
        return parts
    }
    var s = p
    if (s[0] == 0x2f_u8) {
        s = s[1..s.size]
    }
    let segs = s.split("/")
    for (seg in segs) { parts.add(seg) }
    return parts
}

func parseHttp(raw: String): HttpRequest {
    let req = HttpRequest()
    let idxOpt = raw.indexOf("\r\n\r\n")
    var headerStr = raw
    if (let Some(idx) <- idxOpt) {
        headerStr = raw[0..idx]
        let bodyStart = idx + 4
        if (bodyStart < raw.size) {
            req.body = raw[bodyStart..raw.size]
        }
    }
    let lines = splitLines(headerStr)
    if (lines.size == 0) { return req }
    parseReqLine(lines[0], req)
    for (i in 1..lines.size) {
        let l = lines[i]
        let ciOpt = l.indexOf(":")
        if (let Some(ci) <- ciOpt) {
            let k = l[0..ci].trimAscii()
            let v = l[ci + 1..l.size]
                .trimAscii()
            req.headers.add(k, v)
        }
    }
    return req
}

func parseReqLine(
    line: String, req: HttpRequest
) {
    let parts = line.split(" ")
    if (parts.size >= 1) {
        req.method = parts[0]
    }
    if (parts.size >= 2) {
        let fullPath = parts[1]
        if (fullPath.contains("?")) {
            let qmOpt = fullPath.indexOf("?")
            if (let Some(qm) <- qmOpt) {
                req.path = fullPath[0..qm]
                req.query = fullPath[
                    qm + 1..fullPath.size]
            }
        } else {
            req.path = fullPath
        }
    }
}

func splitLines(
    s: String
): ArrayList<String> {
    let result = ArrayList<String>()
    let raw = s.replace("\r\n", "\n")
    let parts = raw.split("\n")
    for (p in parts) {
        let trimmed = p.trimAscii()
        if (trimmed.size > 0) {
            result.add(trimmed)
        }
    }
    if (parts.size == 0 && s.size > 0) {
        result.add(s)
    }
    return result
}

// Helper: parse query params
public func getQueryParam(
    query: String, key: String
): String {
    if (query.size == 0) { return "" }
    let pairs = query.split("&")
    for (pair in pairs) {
        let eqOpt = pair.indexOf("=")
        if (let Some(eq) <- eqOpt) {
            let k = pair[0..eq]
            if (k == key) {
                return pair[eq + 1..pair.size]
            }
        }
    }
    return ""
}

// Helper: get query page params
public func parseQueryPage(
    query: String
): (Int64, Int64) {
    var page: Int64 = 1
    var pageSize: Int64 = 10
    let pStr = getQueryParam(query, "page")
    if (pStr.size > 0) {
        page = strToInt64(pStr)
    }
    let psStr =
        getQueryParam(query, "pageSize")
    if (psStr.size > 0) {
        pageSize = strToInt64(psStr)
    }
    if (page < 1) { page = 1 }
    if (pageSize < 1) { pageSize = 10 }
    if (pageSize > 100) { pageSize = 100 }
    return (page, pageSize)
}

func strToInt64(s: String): Int64 {
    var result: Int64 = 0
    for (ch in s) {
        if (ch >= b'0' && ch <= b'9') {
            result = result * 10 +
                Int64(ch - b'0')
        }
    }
    return result
}

// extract token from Authorization header
public func extractToken(
    req: HttpRequest
): String {
    let authOpt =
        req.headers.get("Authorization")
    if (let Some(auth) <- authOpt) {
        if (auth.startsWith("Bearer ")) {
            return auth[7..auth.size]
        }
    }
    return ""
}
