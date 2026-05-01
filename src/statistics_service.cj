package cangjie

import std.collection.*

// ================================================
//  StatisticsService — 数据统计
//  支持：平台总览、热门分类、状态分布
// ================================================
public class StatisticsService {
    private let itemRepo: ItemRepository

    private static var inst:
        Option<StatisticsService> = None

    private init() {
        itemRepo =
            ItemRepository.getInstance()
    }

    public static func getInstance()
        : StatisticsService
    {
        match (inst) {
            case Some(s) => return s
            case None =>
                let s = StatisticsService()
                inst = Some(s)
                return s
        }
    }

    public func getOverview()
        : ApiResponse<OverviewStats> {
        let all = itemRepo.findAll()
        let stats = OverviewStats()
        stats.totalItems = Int64(all.size)

        for (item in all) {
            match (ItemType.SecondHand == item.itemType) {
                case true => stats.totalSecondHand++
                case false => stats.totalLostFound++
            }

            match (ItemStatus.Pending == item.status) {
                case true => stats.pendingReviews++
                case false => ()
            }

            match (TradeStatus.Reserved ==
                item.tradeStatus) {
                case true => stats.activeTrades++
                case false => ()
            }
            match (TradeStatus.Sold ==
                item.tradeStatus) {
                case true => stats.soldItems++
                case false => ()
            }

            match (ClaimStatus.Claimed ==
                item.claimStatus) {
                case true => stats.activeClaims++
                case false => ()
            }
            match (ClaimStatus.Returned ==
                item.claimStatus) {
                case true => stats.returnedItems++
                case false => ()
            }
        }

        return ApiResponse<OverviewStats>
            .ok(stats)
    }

    // 热门分类（按物品数量降序）
    public func getHotCategories()
        : ApiResponse<ArrayList<CategoryStats>> {
        let all = itemRepo.findAll()
        let catRepo =
            CategoryRepository.getInstance()

        var catMap: HashMap<Int64, Int64> =
            HashMap<Int64, Int64>()
        for (item in all) {
            match (catMap.get(item.categoryId)) {
                case Some(cnt) =>
                    catMap.add(
                        item.categoryId, cnt + 1
                    )
                case None =>
                    catMap.add(item.categoryId, 1)
            }
        }

        let result = ArrayList<CategoryStats>()
        for ((catId, cnt) in catMap) {
            let name = match (catRepo.findById(catId)) {
                case Some(c) => c.name
                case None    => "未知分类"
            }
            result.add(
                CategoryStats(catId, name, cnt)
            )
        }

        let arr = result.toArray()
        let n = arr.size
        if (n > 1) {
            for (i in 0..n - 1) {
                for (j in 0..n - 2 - i) {
                    if (arr[j].count <
                        arr[j + 1].count) {
                        let tmp = arr[j]
                        arr[j] = arr[j + 1]
                        arr[j + 1] = tmp
                    }
                }
            }
        }
        result.clear()
        for (item in arr) {
            result.add(item)
        }

        return ApiResponse<
            ArrayList<CategoryStats>
        >.ok(result)
    }

    // 状态分布统计
    public func getStatusDistribution()
        : ApiResponse<ArrayList<StatusDist>> {
        let all = itemRepo.findAll()
        var statusMap: HashMap<String, Int64> =
            HashMap<String, Int64>()

        for (item in all) {
            let key = item.status.toString()
            match (statusMap.get(key)) {
                case Some(cnt) =>
                    statusMap.add(key, cnt + 1)
                case None =>
                    statusMap.add(key, 1)
            }
        }

        let result = ArrayList<StatusDist>()
        for ((name, cnt) in statusMap) {
            result.add(StatusDist(name, cnt))
        }
        return ApiResponse<
            ArrayList<StatusDist>
        >.ok(result)
    }
}
