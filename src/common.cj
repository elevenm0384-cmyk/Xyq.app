package cangjie

// ===== ErrorCode =====
public enum ErrorCode {
    | Success
    | BadRequest
    | Unauthorized
    | Forbidden
    | NotFound
    | InternalError
    | UserAlreadyExists
    | UserNotFound
    | WrongPassword
    | PostNotFound
    | PostAlreadyClosed
    | PostNotAvailable
    | AlreadyReserved
    | AlreadyClaimed
    | CannotBuyOwn
    | CannotClaimOwn
    | RequestNotFound
    | InvalidTransition
    | CategoryNotFound
    | MessageNotFound
    | ReviewNotFound

    public func code(): Int64 {
        match (this) {
            case Success          => 0
            case BadRequest       => 400
            case Unauthorized     => 401
            case Forbidden        => 403
            case NotFound         => 404
            case InternalError    => 500
            case UserAlreadyExists => 1001
            case UserNotFound     => 1002
            case WrongPassword    => 1003
            case PostNotFound     => 2001
            case PostAlreadyClosed => 2002
            case PostNotAvailable => 2003
            case AlreadyReserved  => 2004
            case AlreadyClaimed   => 2005
            case CannotBuyOwn     => 2006
            case CannotClaimOwn   => 2007
            case RequestNotFound  => 2008
            case InvalidTransition => 4001
            case CategoryNotFound => 3002
            case MessageNotFound  => 3003
            case ReviewNotFound   => 3004
        }
    }

    public func message(): String {
        match (this) {
            case Success =>
                "ok"
            case BadRequest =>
                "请求参数错误"
            case Unauthorized =>
                "未登录或Token已过期"
            case Forbidden =>
                "权限不足"
            case NotFound =>
                "资源不存在"
            case InternalError =>
                "服务器内部错误"
            case UserAlreadyExists =>
                "用户已存在"
            case UserNotFound =>
                "用户不存在"
            case WrongPassword =>
                "密码错误"
            case PostNotFound =>
                "内容不存在"
            case PostAlreadyClosed =>
                "内容已关闭"
            case PostNotAvailable =>
                "当前状态不可操作"
            case AlreadyReserved =>
                "已被他人锁定"
            case AlreadyClaimed =>
                "已被他人认领"
            case CannotBuyOwn =>
                "不能购买自己的商品"
            case CannotClaimOwn =>
                "不能认领自己发布的失物"
            case RequestNotFound =>
                "申请不存在"
            case InvalidTransition =>
                "当前状态不允许此操作"
            case CategoryNotFound =>
                "分类不存在"
            case MessageNotFound =>
                "留言不存在"
            case ReviewNotFound =>
                "审核记录不存在"
        }
    }
}

// ===== ApiResponse<T> =====
public class ApiResponse<T> {
    public let code: Int64
    public let message: String
    public let data: Option<T>

    private init(
        c: Int64,
        m: String,
        d: Option<T>
    ) {
        code = c
        message = m
        data = d
    }

    public static func ok(d: T): ApiResponse<T> {
        let ec = ErrorCode.Success
        return ApiResponse<T>(
            ec.code(), ec.message(), Some(d)
        )
    }

    public static func okEmpty()
        : ApiResponse<Unit>
    {
        let ec = ErrorCode.Success
        return ApiResponse<Unit>(
            ec.code(), ec.message(), None
        )
    }

    public static func fail(
        ec: ErrorCode
    ): ApiResponse<T> {
        return ApiResponse<T>(
            ec.code(), ec.message(), None
        )
    }

    public func toString(): String {
        let d = match (data) {
            case Some(_) => "(有数据)"
            case None    => "null"
        }
        return "ApiResponse{" +
            "code=${code}" +
            ", message=${message}" +
            ", data=${d}}"
    }
}

// ===== PageResult<T> =====
public class PageResult<T> {
    public let total: Int64
    public let page: Int64
    public let pageSize: Int64
    public let list: Array<T>

    public init(
        total: Int64,
        page: Int64,
        pageSize: Int64,
        list: Array<T>
    ) {
        this.total    = total
        this.page     = page
        this.pageSize = pageSize
        this.list     = list
    }

    public func totalPages(): Int64 {
        if (pageSize <= 0) { return 0 }
        return (total + pageSize - 1) / pageSize
    }

    public func toString(): String {
        return "PageResult{" +
            "total=${total}" +
            ", page=${page}" +
            "/${totalPages()}" +
            ", size=${list.size}}"
    }
}
