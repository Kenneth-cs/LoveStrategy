//
//  UsageLimitManager.swift
//  恋爱军师
//
//  每日免费额度管理
//

import Foundation

class UsageLimitManager {
    
    // MARK: - Constants
    
    /// 每日免费额度
    static let dailyFreeLimit = 3
    
    /// 新用户额外赠送次数
    static let newUserBonus = 2
    
    // MARK: - UserDefaults Keys
    
    private static let dailyUsageCountKey = "dailyUsageCount"
    private static let lastUsageDateKey = "lastUsageDate"
    private static let totalUsageCountKey = "totalUsageCount"
    private static let isNewUserKey = "isNewUser"
    private static let hasReceivedBonusKey = "hasReceivedBonus"
    
    // MARK: - Public Methods
    
    /// 检查是否还有剩余次数
    static func canUseFeature() -> Bool {
        checkAndResetIfNewDay()
        let currentCount = getDailyUsageCount()
        let limit = getCurrentLimit()
        return currentCount < limit
    }
    
    /// 获取剩余次数
    static func getRemainingCount() -> Int {
        checkAndResetIfNewDay()
        let currentCount = getDailyUsageCount()
        let limit = getCurrentLimit()
        return max(0, limit - currentCount)
    }
    
    /// 增加使用次数
    static func incrementUsage() {
        checkAndResetIfNewDay()
        
        let currentCount = getDailyUsageCount()
        UserDefaults.standard.set(currentCount + 1, forKey: dailyUsageCountKey)
        
        let totalCount = getTotalUsageCount()
        UserDefaults.standard.set(totalCount + 1, forKey: totalUsageCountKey)
        
        // 更新最后使用日期
        UserDefaults.standard.set(Date(), forKey: lastUsageDateKey)
    }
    
    /// 获取今日使用次数
    static func getDailyUsageCount() -> Int {
        return UserDefaults.standard.integer(forKey: dailyUsageCountKey)
    }
    
    /// 获取总使用次数
    static func getTotalUsageCount() -> Int {
        return UserDefaults.standard.integer(forKey: totalUsageCountKey)
    }
    
    /// 获取当前限制（考虑新手福利）
    static func getCurrentLimit() -> Int {
        if isNewUser() && !hasReceivedBonus() {
            return dailyFreeLimit + newUserBonus
        }
        return dailyFreeLimit
    }
    
    /// 是否是新用户
    static func isNewUser() -> Bool {
        let totalCount = getTotalUsageCount()
        return totalCount == 0
    }
    
    /// 是否已领取新手福利
    static func hasReceivedBonus() -> Bool {
        return UserDefaults.standard.bool(forKey: hasReceivedBonusKey)
    }
    
    /// 标记已领取新手福利
    static func markBonusReceived() {
        UserDefaults.standard.set(true, forKey: hasReceivedBonusKey)
    }
    
    /// 重置每日计数（用于测试）
    static func resetDailyCount() {
        UserDefaults.standard.set(0, forKey: dailyUsageCountKey)
        UserDefaults.standard.set(Date(), forKey: lastUsageDateKey)
    }
    
    // MARK: - Private Methods
    
    /// 检查是否是新的一天，如果是则重置计数
    private static func checkAndResetIfNewDay() {
        guard let lastDate = UserDefaults.standard.object(forKey: lastUsageDateKey) as? Date else {
            // 第一次使用
            UserDefaults.standard.set(Date(), forKey: lastUsageDateKey)
            UserDefaults.standard.set(0, forKey: dailyUsageCountKey)
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        
        if today > lastDay {
            // 新的一天，重置计数
            UserDefaults.standard.set(0, forKey: dailyUsageCountKey)
            UserDefaults.standard.set(Date(), forKey: lastUsageDateKey)
        }
    }
    
    /// 获取超额提示消息
    static func getLimitReachedMessage() -> String {
        let limit = getCurrentLimit()
        return """
        今日免费额度已用完 (\(limit)/\(limit))
        
        明天 0:00 自动恢复 \(dailyFreeLimit) 次免费使用
        
        敬请期待会员功能，享受无限次分析 ✨
        """
    }
    
    /// 获取新手福利提示
    static func getNewUserWelcomeMessage() -> String {
        return """
        恭喜你！作为新用户，你额外获得了 \(newUserBonus) 次免费分析机会！
        
        今日可用次数：\(getCurrentLimit()) 次
        """
    }
}

// MARK: - 使用限制视图修饰器

import SwiftUI

struct UsageLimitCheck: ViewModifier {
    @Binding var showLimitAlert: Bool
    @Binding var limitMessage: String
    
    func body(content: Content) -> some View {
        content
            .alert("使用次数限制", isPresented: $showLimitAlert) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(limitMessage)
            }
    }
}

extension View {
    func usageLimitCheck(showAlert: Binding<Bool>, message: Binding<String>) -> some View {
        modifier(UsageLimitCheck(showLimitAlert: showAlert, limitMessage: message))
    }
}

