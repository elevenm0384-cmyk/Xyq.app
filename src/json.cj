package cangjie
import std.collection.*

public class JsonVal {
    public var kind: Int64 = 0
    public var boolVal: Bool = false
    public var intVal: Int64 = 0
    public var floatVal: Float64 = 0.0
    public var strVal: String = ""
    public var arrVal:
        ArrayList<JsonVal> = ArrayList<JsonVal>()
    public var objVal:
        HashMap<String, JsonVal> =
        HashMap<String, JsonVal>()
}

public func jsonNull(): JsonVal {
    let j = JsonVal()
    j.kind = 0
    return j
}
public func jsonBool(b: Bool): JsonVal {
    let j = JsonVal()
    j.kind = 1
    j.boolVal = b
    return j
}
public func jsonInt(i: Int64): JsonVal {
    let j = JsonVal()
    j.kind = 2
    j.intVal = i
    return j
}
public func jsonFloat(f: Float64): JsonVal {
    let j = JsonVal()
    j.kind = 3
    j.floatVal = f
    return j
}
public func jsonStr(s: String): JsonVal {
    let j = JsonVal()
    j.kind = 4
    j.strVal = s
    return j
}
public func jsonArr(): JsonVal {
    let j = JsonVal()
    j.kind = 5
    return j
}
public func jsonObj(): JsonVal {
    let j = JsonVal()
    j.kind = 6
    return j
}

public func jsonPut(
    obj: JsonVal, key: String, val: JsonVal
) {
    obj.objVal.add(key, val)
}

public func jsonPush(
    arr: JsonVal, val: JsonVal
) {
    arr.arrVal.add(val)
}

public func jsonGet(
    obj: JsonVal, key: String
): JsonVal {
    let opt = obj.objVal.get(key)
    if (let Some(v) <- opt) { return v }
    return jsonNull()
}

// Serialize JsonVal to JSON string
public func writeJson(j: JsonVal): String {
    if (j.kind == 0) { return "null" }
    if (j.kind == 1) {
        if (j.boolVal) {
            return "true"
        }
        return "false"
    }
    if (j.kind == 2) { return j.intVal.toString() }
    if (j.kind == 3) {
        return j.floatVal.toString()
    }
    if (j.kind == 4) {
        return writeJsonStr(j.strVal)
    }
    if (j.kind == 5) { return writeJsonArr(j) }
    if (j.kind == 6) { return writeJsonObj(j) }
    return "null"
}

func writeJsonStr(s: String): String {
    var result = "\""
    let size = s.size
    var i: Int64 = 0
    while (i < size) {
        let ch = s[i..i + 1]
        if (ch == "\"") {
            result = result + "\\\""
        } else if (ch == "\\") {
            result = result + "\\\\"
        } else if (ch == "\n") {
            result = result + "\\n"
        } else if (ch == "\r") {
            result = result + "\\r"
        } else if (ch == "\t") {
            result = result + "\\t"
        } else {
            result = result + ch
        }
        i = i + 1
    }
    return result + "\""
}

func writeJsonArr(j: JsonVal): String {
    var result = "["
    let size = j.arrVal.size
    for (i in 0..size) {
        if (i > 0) { result = result + "," }
        result = result +
            writeJson(j.arrVal[i])
    }
    return result + "]"
}

func writeJsonObj(j: JsonVal): String {
    var result = "{"
    var first = true
    for ((k, v) in j.objVal) {
        if (!first) { result = result + "," }
        first = false
        result = result + writeJsonStr(k) +
            ":" + writeJson(v)
    }
    return result + "}"
}

// JSON Parser — byte-position cursor
class JsonParser {
    let raw: String
    var pos: Int64 = 0
    let len: Int64

    init(raw: String) {
        this.raw = raw
        this.len = raw.size
    }

    func parse(): JsonVal {
        return parseValue()
    }

    func parseValue(): JsonVal {
        skipSpace()
        if (pos >= len) { return jsonNull() }
        let b = rawByte()
        if (b == 0x7b_u8) {
            pos = pos + 1
            return parseObj()
        }
        if (b == 0x5b_u8) {
            pos = pos + 1
            return parseArr()
        }
        if (b == 0x22_u8) { return parseStr() }
        if (b == 0x74_u8) { return parseTrue() }
        if (b == 0x66_u8) { return parseFalse() }
        if (b == 0x6e_u8) { return parseNull() }
        return parseNum()
    }

    func rawByte(): UInt8 {
        return raw[pos]
    }

    func parseObj(): JsonVal {
        let obj = jsonObj()
        skipSpace()
        if (pos < len &&
            raw[pos] == 0x7d_u8
        ) {
            pos = pos + 1
            return obj
        }
        while (true) {
            skipSpace()
            let key = parseStr()
            skipSpace()
            if (pos < len &&
                raw[pos] == 0x3a_u8
            ) {
                pos = pos + 1
            }
            skipSpace()
            let val = parseValue()
            jsonPut(obj, key.strVal, val)
            skipSpace()
            if (pos < len &&
                raw[pos] == 0x7d_u8
            ) {
                pos = pos + 1
                return obj
            }
            if (pos < len &&
                raw[pos] == 0x2c_u8
            ) {
                pos = pos + 1
            }
        }
        return jsonNull()
    }

    func parseArr(): JsonVal {
        let arr = jsonArr()
        skipSpace()
        if (pos < len &&
            raw[pos] == 0x5d_u8
        ) {
            pos = pos + 1
            return arr
        }
        while (true) {
            skipSpace()
            let val = parseValue()
            jsonPush(arr, val)
            skipSpace()
            if (pos < len &&
                raw[pos] == 0x5d_u8
            ) {
                pos = pos + 1
                return arr
            }
            if (pos < len &&
                raw[pos] == 0x2c_u8
            ) {
                pos = pos + 1
            }
        }
        return jsonNull()
    }

    func parseStr(): JsonVal {
        pos = pos + 1
        var start = pos
        var s = ""
        while (pos < len) {
            let b = raw[pos]
            if (b == 0x22_u8) {
                s = s + raw[start..pos]
                pos = pos + 1
                return jsonStr(s)
            }
            if (b == 0x5c_u8) {
                s = s + raw[start..pos]
                pos = pos + 1
                if (pos >= len) {
                    return jsonStr(s)
                }
                let esc = raw[pos]
                if (esc == 0x6e_u8) {
                    s = s + "\n"
                } else if (esc == 0x72_u8) {
                    s = s + "\r"
                } else if (esc == 0x74_u8) {
                    s = s + "\t"
                } else if (esc == 0x22_u8) {
                    s = s + "\""
                } else if (esc == 0x5c_u8) {
                    s = s + "\\"
                } else if (esc == 0x2f_u8) {
                    s = s + "/"
                } else {
                    s = s + raw[pos..pos + 1]
                }
                pos = pos + 1
                start = pos
            } else {
                pos = pos + utf8Len(b)
            }
        }
        s = s + raw[start..pos]
        return jsonStr(s)
    }

    func parseTrue(): JsonVal {
        pos = pos + 4
        return jsonBool(true)
    }

    func parseFalse(): JsonVal {
        pos = pos + 5
        return jsonBool(false)
    }

    func parseNull(): JsonVal {
        pos = pos + 4
        return jsonNull()
    }

    func parseNum(): JsonVal {
        let start = pos
        if (pos < len &&
            raw[pos] == 0x2d_u8
        ) {
            pos = pos + 1
        }
        while (pos < len) {
            let b = raw[pos]
            if (b >= 0x30_u8 &&
                b <= 0x39_u8
            ) {
                pos = pos + 1
            } else {
                break
            }
        }
        var hasDot = false
        if (pos < len &&
            raw[pos] == 0x2e_u8
        ) {
            hasDot = true
            pos = pos + 1
            while (pos < len) {
                let b = raw[pos]
                if (b >= 0x30_u8 &&
                    b <= 0x39_u8
                ) {
                    pos = pos + 1
                } else {
                    break
                }
            }
        }
        let numStr = raw[start..pos]
        if (hasDot) {
            return jsonFloat(parseFloat(numStr))
        }
        return jsonInt(parseInt(numStr))
    }

    func skipSpace() {
        while (pos < len) {
            let b = raw[pos]
            if (b == 0x20_u8 ||
                b == 0x0a_u8 ||
                b == 0x0d_u8 ||
                b == 0x09_u8
            ) {
                pos = pos + 1
            } else {
                return
            }
        }
    }

    func parseInt(s: String): Int64 {
        var result: Int64 = 0
        var sign: Int64 = 1
        var start: Int64 = 0
        if (s.size > 0 &&
            s[0] == 0x2d_u8
        ) {
            sign = -1
            start = 1
        }
        for (i in start..s.size) {
            let b = s[i]
            result = result * 10 +
                (Int64(b) - 48)
        }
        return result * sign
    }

    func parseFloat(s: String): Float64 {
        var sign: Float64 = 1.0
        var start: Int64 = 0
        if (s.size > 0 &&
            s[0] == 0x2d_u8
        ) {
            sign = -1.0
            start = 1
        }
        var intPart: Float64 = 0.0
        var i = start
        while (i < s.size) {
            let b = s[i]
            if (b == 0x2e_u8) {
                i = i + 1
                break
            }
            intPart = intPart * 10.0 +
                toFloat(Int64(b) - 48)
            i = i + 1
        }
        var fracPart: Float64 = 0.0
        var divisor: Float64 = 10.0
        while (i < s.size) {
            let b = s[i]
            fracPart = fracPart +
                toFloat(Int64(b) - 48) /
                divisor
            divisor = divisor * 10.0
            i = i + 1
        }
        return (intPart + fracPart) * sign
    }
}

func utf8Len(b: UInt8): Int64 {
    if (b < 0x80_u8) { return 1 }
    if (b < 0xE0_u8) { return 2 }
    if (b < 0xF0_u8) { return 3 }
    return 4
}

func toFloat(i: Int64): Float64 {
    if (i == 0) { return 0.0 }
    if (i == 1) { return 1.0 }
    if (i == 2) { return 2.0 }
    if (i == 3) { return 3.0 }
    if (i == 4) { return 4.0 }
    if (i == 5) { return 5.0 }
    if (i == 6) { return 6.0 }
    if (i == 7) { return 7.0 }
    if (i == 8) { return 8.0 }
    if (i == 9) { return 9.0 }
    return 0.0
}

public func jsonParse(
    raw: String
): JsonVal {
    if (raw.size == 0) { return jsonNull() }
    let p = JsonParser(raw)
    return p.parse()
}

// Helper: convert ApiResponse to JSON
public func respToJson(code: Int64,
    msg: String,
    data: JsonVal
): String {
    let obj = jsonObj()
    jsonPut(obj, "code", jsonInt(code))
    jsonPut(obj, "message", jsonStr(msg))
    jsonPut(obj, "data", data)
    return writeJson(obj)
}
