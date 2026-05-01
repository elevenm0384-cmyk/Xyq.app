package cangjie

import std.collection.*

// ================================================
//  SearchService — 搜索 / 筛选 / 排序
//  支持：关键词、分类、类型、排序、分页
// ================================================
public class SearchService {
    private let itemRepo: ItemRepository

    private static var inst:
        Option<SearchService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
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
    ): ApiResponse<PageResult<BaseItem>> {
        let all = itemRepo.findAll()
        var filtered = ArrayList<BaseItem>()

        for (item in all) {
            if (!matchKeyword(item, params.keyword)) {
                continue
            }
            if (!matchCategory(item, params.categoryId)) {
                continue
            }
            if (!matchType(item, params.itemType)) {
                continue
            }
            if (!matchStatus(item, params.status)) {
                continue
            }
            if (item.status != ItemStatus.Approved) {
                continue
            }
            filtered.add(item)
        }

        sortItems(filtered, params.sortBy)

        let total = Int64(filtered.size)
        let from = (params.page - 1) * params.pageSize
        let paged = ArrayList<BaseItem>()
        var i = from
        while (i < from + params.pageSize &&
            i < Int64(filtered.size)) {
            paged.add(filtered[i])
            i++
        }

        let pr = PageResult<BaseItem>(
            total, params.page,
            params.pageSize, paged.toArray()
        )
        return ApiResponse<PageResult<BaseItem>>
            .ok(pr)
    }

    private func matchKeyword(
        item: BaseItem,
        keyword: String
    ): Bool {
        if (keyword.isEmpty()) { return true }
        return containsStr(
            item.title, keyword
        ) || containsStr(
            item.description, keyword
        )
    }

    private func containsStr(
        s: String,
        sub: String
    ): Bool {
        // contains 方法已内置
        return s.contains(sub)
    }

    private func matchCategory(
        item: BaseItem,
        catOpt: Option<Int64>
    ): Bool {
        match (catOpt) {
            case None => return true
            case Some(cid) =>
                return item.categoryId == cid
        }
    }

    private func matchType(
        item: BaseItem,
        typeOpt: Option<ItemType>
    ): Bool {
        match (typeOpt) {
            case None => return true
            case Some(t) =>
                match (item.itemType == t) {
                    case true => return true
                    case false => return false
                }
        }
    }

    private func matchStatus(
        item: BaseItem,
        statusOpt: Option<ItemStatus>
    ): Bool {
        match (statusOpt) {
            case None => return true
            case Some(s) =>
                match (item.status == s) {
                    case true => return true
                    case false => return false
                }
        }
    }

    private func sortItems(
        list: ArrayList<BaseItem>,
        sortBy: String
    ): Unit {
        let arr = list.toArray()
        match (sortBy) {
            case "time_asc" =>
                bubbleSort(arr, compareTimeAsc)
            case _ =>
                bubbleSort(arr, compareTimeDesc)
        }
        list.clear()
        for (item in arr) {
            list.add(item)
        }
    }

    private func compareTimeDesc(
        a: BaseItem, b: BaseItem
    ): Bool {
        return a.id > b.id
    }

    private func compareTimeAsc(
        a: BaseItem, b: BaseItem
    ): Bool {
        return a.id < b.id
    }

    private func bubbleSort(
        arr: Array<BaseItem>,
        cmp: (BaseItem, BaseItem) -> Bool
    ): Unit {
        let n = arr.size
        if (n <= 1) { return }
        for (i in 0..n - 1) {
            for (j in 0..n - 2 - i) {
                if (!cmp(arr[j], arr[j + 1])) {
                    let tmp = arr[j]
                    arr[j] = arr[j + 1]
                    arr[j + 1] = tmp
                }
            }
        }
    }
}
