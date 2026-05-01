package cangjie

import std.collection.*

// ================================================
//  StatisticsService — 平台数据统计
// ================================================
public class StatisticsService {
    private let postRepo: PostRepository
    private let userRepo: UserRepository

    private static var inst:
        Option<StatisticsService> = None

    private init() {
        postRepo =
            PostRepository.getInstance()
        userRepo =
            UserRepository.getInstance()
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

    // 总览统计
    public func getOverview()
        : ApiResponse<OverviewStats> {
        let all = postRepo.findAll()
        let stats = OverviewStats()
        stats.totalUsers = userRepo.count()
        stats.totalPosts = Int64(all.size)

        var catMap: HashMap<Int64, Int64> =
            HashMap<Int64, Int64>()
        let catRepo =
            CategoryRepository.getInstance()

        for (post in all) {
            if (post.businessType ==
                BusinessType.SecondHand) {
                stats.secondhandCount++
            }
            match (BusinessType.LOST ==
                post.businessType) {
                case true => stats.lostCount++
                case false => ()
            }
            match (BusinessType.FOUND ==
                post.businessType) {
                case true => stats.foundCount++
                case false => ()
            }
            if (post.auditStatus ==
                AuditStatus.PENDING) {
                stats.pendingAuditCount++
            }
            // 分类统计
            match (catMap.get(post.categoryId)) {
                case Some(cnt) =>
                    catMap.add(post.categoryId, cnt + 1)
                case None =>
                    catMap.add(post.categoryId, 1)
            }
        }

        // 热门分类 TOP N
        let hotList = ArrayList<CategoryStats>()
        for ((catId, cnt) in catMap) {
            let name = match (catRepo.findById(catId)) {
                case Some(c) => c.name
                case None    => "未知"
            }
            hotList.add(CategoryStats(catId, name, cnt))
        }
        let arr = hotList.toArray()
        let n = arr.size
        if (n > 1) {
            for (i in 0..n - 1) {
                for (j in 0..n - 2 - i) {
                    if (arr[j].count < arr[j + 1].count) {
                        let tmp = arr[j]
                        arr[j] = arr[j + 1]
                        arr[j + 1] = tmp
                    }
                }
            }
        }
        for (item in arr) {
            stats.hotCategories.add(item)
        }

        return ApiResponse<OverviewStats>.ok(stats)
    }

    // 状态分布
    public func getStatusDistribution()
        : ApiResponse<ArrayList<StatusDist>> {
        let all = postRepo.findAll()
        var statusMap: HashMap<String, Int64> =
            HashMap<String, Int64>()

        for (post in all) {
            let key = post.bizStatus.toString()
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
