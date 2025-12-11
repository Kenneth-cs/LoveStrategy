//
//  PeachBlossomManager.swift
//  恋爱军师
//
//  桃花签虚拟货币管理器
//  - 负责用户虚拟货币的增删改查
//  - 通过 iCloud Key-Value Store 实现数据持久化和多设备同步
//  - 防止卸载App后数据丢失
//

import Foundation
import Combine

/// 桃花签管理器错误类型
enum PeachBlossomError: LocalizedError {
    case insufficientBalance(required: Int, current: Int)
    case invalidAmount
    case cloudSyncFailed
    
    var errorDescription: String? {
        switch self {
        case .insufficientBalance(let required, let current):
            return "桃花签不足！需要 \(required) 签，当前仅有 \(current) 签"
        case .invalidAmount:
            return "无效的金额"
        case .cloudSyncFailed:
            return "iCloud 同步失败"
        }
    }
}

/// 消费记录模型
struct CoinTransaction: Codable, Identifiable {
    let id: UUID
    let amount: Int           // 正数=充值，负数=消费
    let balance: Int          // 交易后的余额
    let reason: String        // 交易原因
    let timestamp: Date
    
    init(amount: Int, balance: Int, reason: String) {
        self.id = UUID()
        self.amount = amount
        self.balance = balance
        self.reason = reason
        self.timestamp = Date()
    }
}

/// 桃花签管理器
@MainActor
class PeachBlossomManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 当前余额（响应式更新UI）
    @Published private(set) var balance: Int = 0
    
    /// 消费记录（可选功能）
    @Published private(set) var transactions: [CoinTransaction] = []
    
    /// 是否为新用户（首次使用）
    @Published private(set) var isNewUser: Bool = true
    
    // MARK: - Constants
    
    /// 初始赠送金额
    private let initialGiftAmount = 36
    
    /// iCloud 存储键名
    private let iCloudBalanceKey = "peachBlossomBalance"
    private let iCloudTransactionsKey = "peachBlossomTransactions"
    private let iCloudInitializedKey = "peachBlossomInitialized"
    
    /// 本地备份键名（防止 iCloud 故障）
    private let localBalanceKey = "local_peachBlossomBalance"
    private let localTransactionsKey = "local_peachBlossomTransactions"
    private let localInitializedKey = "local_peachBlossomInitialized"
    
    // MARK: - Storage
    
    /// iCloud Key-Value Store
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    
    /// 本地存储（备份）
    private let localStorage = UserDefaults.standard
    
    // MARK: - Initialization
    
    static let shared = PeachBlossomManager()
    
    private init() {
        setupCloudSync()
        loadBalance()
        checkAndGiveInitialGift()
    }
    
    // MARK: - Public Methods
    
    /// 检查余额是否足够
    /// - Parameter required: 需要的金额
    /// - Returns: 是否足够
    func checkBalance(required: Int) -> Bool {
        return balance >= required
    }
    
    /// 扣除桃花签（消费）
    /// - Parameters:
    ///   - amount: 扣除数量（正数）
    ///   - reason: 消费原因
    /// - Throws: PeachBlossomError
    func deductCoins(_ amount: Int, reason: String) throws {
        guard amount > 0 else {
            throw PeachBlossomError.invalidAmount
        }
        
        guard balance >= amount else {
            throw PeachBlossomError.insufficientBalance(required: amount, current: balance)
        }
        
        balance -= amount
        saveBalance()
        
        // 记录交易
        let transaction = CoinTransaction(
            amount: -amount,
            balance: balance,
            reason: reason
        )
        addTransaction(transaction)
        
        print("✅ 扣费成功：-\(amount) 签，原因：\(reason)，剩余：\(balance) 签")
    }
    
    /// 增加桃花签（充值或赠送）
    /// - Parameters:
    ///   - amount: 增加数量（正数）
    ///   - source: 来源（如："充值"、"系统赠送"、"活动奖励"）
    func addCoins(_ amount: Int, source: String) {
        guard amount > 0 else { return }
        
        balance += amount
        saveBalance()
        
        // 记录交易
        let transaction = CoinTransaction(
            amount: amount,
            balance: balance,
            reason: source
        )
        addTransaction(transaction)
        
        print("✅ 充值成功：+\(amount) 签，来源：\(source)，当前：\(balance) 签")
    }
    
    /// 获取当前余额
    /// - Returns: 余额
    func getBalance() -> Int {
        return balance
    }
    
    /// 获取消费记录（最近的在前）
    /// - Parameter limit: 限制数量，nil表示全部
    /// - Returns: 交易记录数组
    func getTransactions(limit: Int? = nil) -> [CoinTransaction] {
        let sorted = transactions.sorted { $0.timestamp > $1.timestamp }
        if let limit = limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }
    
    /// 手动触发 iCloud 同步
    func syncNow() {
        saveBalance()
        iCloudStore.synchronize()
    }
    
    /// 重置所有数据（调试用，生产环境慎用）
    func resetAll() {
        balance = 0
        transactions = []
        isNewUser = true
        
        // 清除 iCloud
        iCloudStore.removeObject(forKey: iCloudBalanceKey)
        iCloudStore.removeObject(forKey: iCloudTransactionsKey)
        iCloudStore.removeObject(forKey: iCloudInitializedKey)
        iCloudStore.synchronize()
        
        // 清除本地
        localStorage.removeObject(forKey: localBalanceKey)
        localStorage.removeObject(forKey: localTransactionsKey)
        localStorage.removeObject(forKey: localInitializedKey)
        
        print("⚠️ 所有数据已重置")
    }
    
    // MARK: - Private Methods
    
    /// 设置 iCloud 同步监听
    private func setupCloudSync() {
        // 监听 iCloud 数据变化（多设备同步）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cloudDataDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore
        )
    }
    
    /// iCloud 数据变化回调
    @objc private func cloudDataDidChange(notification: Notification) {
        print("📱 检测到 iCloud 数据变化，正在同步...")
        loadBalance()
    }
    
    /// 从存储加载余额
    private func loadBalance() {
        // 优先从 iCloud 读取
        let cloudBalance = iCloudStore.longLong(forKey: iCloudBalanceKey)
        
        // 从本地读取（备份）
        let localBalance = localStorage.integer(forKey: localBalanceKey)
        
        // 选择较大的值（防止数据丢失）
        if cloudBalance > 0 || localBalance > 0 {
            balance = Int(max(cloudBalance, Int64(localBalance)))
            print("📖 加载余额：\(balance) 签（iCloud: \(cloudBalance), 本地: \(localBalance)）")
        } else {
            balance = 0
            print("📖 首次启动，余额为 0")
        }
        
        // 加载交易记录
        loadTransactions()
    }
    
    /// 保存余额到存储
    private func saveBalance() {
        // 保存到 iCloud
        iCloudStore.set(Int64(balance), forKey: iCloudBalanceKey)
        iCloudStore.synchronize()
        
        // 保存到本地（备份）
        localStorage.set(balance, forKey: localBalanceKey)
        
        print("💾 保存余额：\(balance) 签")
    }
    
    /// 检查并赠送初始桃花签
    private func checkAndGiveInitialGift() {
        // 检查是否已初始化
        let cloudInitialized = iCloudStore.bool(forKey: iCloudInitializedKey)
        let localInitialized = localStorage.bool(forKey: localInitializedKey)
        
        if !cloudInitialized && !localInitialized {
            // 新用户，赠送初始桃花签
            isNewUser = true
            balance = initialGiftAmount
            saveBalance()
            
            // 记录交易
            let transaction = CoinTransaction(
                amount: initialGiftAmount,
                balance: balance,
                reason: "新用户礼包"
            )
            addTransaction(transaction)
            
            // 标记已初始化
            iCloudStore.set(true, forKey: iCloudInitializedKey)
            iCloudStore.synchronize()
            localStorage.set(true, forKey: localInitializedKey)
            
            print("🎉 新用户！赠送 \(initialGiftAmount) 签桃花签")
        } else {
            isNewUser = false
            print("👤 老用户，当前余额：\(balance) 签")
        }
    }
    
    /// 添加交易记录
    private func addTransaction(_ transaction: CoinTransaction) {
        transactions.append(transaction)
        
        // 只保留最近100条记录（防止数据过大）
        if transactions.count > 100 {
            transactions = Array(transactions.suffix(100))
        }
        
        saveTransactions()
    }
    
    /// 加载交易记录
    private func loadTransactions() {
        // 优先从 iCloud 读取
        if let cloudData = iCloudStore.data(forKey: iCloudTransactionsKey),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: cloudData) {
            transactions = decoded
            print("📖 从 iCloud 加载 \(transactions.count) 条交易记录")
            return
        }
        
        // 从本地读取（备份）
        if let localData = localStorage.data(forKey: localTransactionsKey),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: localData) {
            transactions = decoded
            print("📖 从本地加载 \(transactions.count) 条交易记录")
            return
        }
        
        transactions = []
        print("📖 无交易记录")
    }
    
    /// 保存交易记录
    private func saveTransactions() {
        guard let encoded = try? JSONEncoder().encode(transactions) else { return }
        
        // 保存到 iCloud
        iCloudStore.set(encoded, forKey: iCloudTransactionsKey)
        iCloudStore.synchronize()
        
        // 保存到本地（备份）
        localStorage.set(encoded, forKey: localTransactionsKey)
        
        print("💾 保存 \(transactions.count) 条交易记录")
    }
}

// MARK: - 便捷扩展

extension PeachBlossomManager {
    
    /// 格式化余额显示（带图标）
    var balanceText: String {
        return "🌸 \(balance)"
    }
    
    /// 今日消费总额
    var todaySpending: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return transactions
            .filter { $0.timestamp >= today && $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    /// 今日充值总额
    var todayRecharge: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return transactions
            .filter { $0.timestamp >= today && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }
}

