package cangjie

import std.collection.*

// ================================================
//  SearchService — 搜索 / 筛选 / 排序
//  支持：关键词、分类、类型、状态、排序、分页
// ================================================
public class SearchService {
    private let postRepo: PostRepository

    private static var inst:
        Option<SearchService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
    }

    public static func getInstance()
        : SearchService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = SearchService()
                inst = Some(s)
                return s
        }
    }

    public func search(
        params: SearchParams
    ): ApiResponse<PageResult<Post>> {
        let all = postRepo.findAll()
        var filtered = ArrayList<Post>()

        for (post in all) {
            if (!matchKeyword(post, params.keyword)) {
                continue
            }
            if (!matchCategory(post, params.categoryId)) {
                continue
            }
            if (!matchBizType(post, params.businessType)) {
                continue
            }
            if (!matchAuditSt(post, params.auditStatus)) {
                continue
            }
            if (!matchBizSt(post, params.bizStatus)) {
                continue
            }
            // 只展示审核通过的
            if (post.auditStatus != AuditStatus.APPROVED) {
                continue
            }
            filtered.add(post)
        }

        sortPosts(filtered, params.sortBy)

        let total = Int64(filtered.size)
        let from = (params.page - 1) * params.pageSize
        let paged = ArrayList<Post>()
        var i = from
        while (i < from + params.pageSize &&
            i < Int64(filtered.size)) {
            paged.add(filtered[i])
            i++
        }

        let pr = PageResult<Post>(
            total, params.page,
            params.pageSize, paged.toArray()
        )
        return ApiResponse<PageResult<Post>>.ok(pr)
    }

    private func matchKeyword(
        post: Post,
        keyword: String
    ): Bool {
        if (keyword.isEmpty()) { return true }
        return post.title.contains(keyword) ||
            post.description.contains(keyword)
    }

    private func matchCategory(
        post: Post,
        catOpt: Option<Int64>
    ): Bool {
        match (catOpt) {
            case None => return true
            case Some(cid) =>
                return post.categoryId == cid
        }
    }

    private func matchBizType(
        post: Post,
        btOpt: Option<BusinessType>
    ): Bool {
        match (btOpt) {
            case None => return true
            case Some(bt) =>
                match (post.businessType == bt) {
                    case true => return true
                    case false => return false
                }
        }
    }

    private func matchAuditSt(
        post: Post,
        asOpt: Option<AuditStatus>
    ): Bool {
        match (asOpt) {
            case None => return true
            case Some(s) =>
                match (post.auditStatus == s) {
                    case true => return true
                    case false => return false
                }
        }
    }

    private func matchBizSt(
        post: Post,
        bsOpt: Option<BizStatus>
    ): Bool {
        match (bsOpt) {
            case None => return true
            case Some(s) =>
                match (post.bizStatus == s) {
                    case true => return true
                    case false => return false
                }
        }
    }

    private func sortPosts(
        list: ArrayList<Post>,
        sortBy: String
    ): Unit {
        let arr = list.toArray()
        let n = arr.size
        if (n <= 1) { return }
        for (i in 0..n - 1) {
            for (j in 0..n - 2 - i) {
                let swap = match (sortBy) {
                    case "latest" =>
                        arr[j].id < arr[j + 1].id
                    case "hottest" =>
                        arr[j].viewCount <
                            arr[j + 1].viewCount
                    case _ =>
                        arr[j].id < arr[j + 1].id
                }
                if (swap) {
                    let tmp = arr[j]
                    arr[j] = arr[j + 1]
                    arr[j + 1] = tmp
                }
            }
        }
        list.clear()
        for (post in arr) {
            list.add(post)
        }
    }
}
