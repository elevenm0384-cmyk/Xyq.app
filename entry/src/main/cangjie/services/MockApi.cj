/**
 * Created on 2026/5/3
 */
package services
import models.*

public class MockApi {
    // 模拟获取待审核列表 (管理员)
    public static func getPendingPosts(): Array<PostSummaryVO> {
        return [
            PostSummaryVO(101, "李四", "SECONDHAND", "九成新 AirPods", 500.0, "图书馆", "PENDING", "ON_SALE", "2026-05-01"),
            PostSummaryVO(102, "王五", "LOST", "丢失校园卡", 0.0, "二食堂", "PENDING", "OPEN", "2026-05-02")
        ]
    }

    // 模拟获取平台统计数据 (管理员)
    public static func getStatsOverview(): Map<String, String> {
        var stats = HashMap<String, String>()
        stats.put("total_users", "1,204")
        stats.put("total_posts", "3,450")
        stats.put("pending_audit", "12")
        stats.put("secondhand_count", "2,100")
        stats.put("lost_found_count", "1,350")
        return stats
    }

    // 模拟获取我的发布
    public static func getMyPosts(): Array<PostSummaryVO> {
        return [
            PostSummaryVO(201, "我", "SECONDHAND", "离散数学教材", 15.0, "教学楼", "APPROVED", "SOLD", "2026-04-20"),
            PostSummaryVO(202, "我", "FOUND", "捡到一把雨伞", 0.0, "主楼", "PENDING", "OPEN", "2026-04-25")
        ]
    }

    // 模拟获取我的收藏
    public static func getMyFavorites(): Array<PostSummaryVO> {
        return [
            PostSummaryVO(301, "王学长", "SECONDHAND", "九成新机械键盘", 150.0, "沙河校区", "APPROVED", "ON_SALE", "2026-05-03"),
            PostSummaryVO(302, "李同学", "LOST", "丢失一串钥匙", 0.0, "图书馆二楼", "APPROVED", "OPEN", "2026-05-04")
        ]
    }

    // 模拟获取消息列表
    public static func getMessages(type: String): Array<MessageVO> {
        if (type == "PUBLIC_COMMENT") {
            return [MessageVO(1, "张三", type, "请问书还有划痕吗？", "2026-05-01 10:00")]
        } else {
            return [MessageVO(2, "学长", type, "今晚8点校门口面交可以吗？", "2026-05-01 11:00")]
        }
    }
}