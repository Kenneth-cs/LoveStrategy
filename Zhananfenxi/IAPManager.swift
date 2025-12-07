//
//  IAPManager.swift
//  恋爱军师
//
//  StoreKit 2 内购管理器
//

import Foundation
import StoreKit

/// 内购管理器错误类型
enum IAPError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case cancelled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "找不到该商品"
        case .purchaseFailed:
            return "购买失败，请重试"
        case .verificationFailed:
            return "购买验证失败"
        case .cancelled:
            return "购买已取消"
        case .unknown:
            return "未知错误"
        }
    }
}

/// StoreKit 2 内购管理器
@MainActor
class IAPManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 可购买的商品列表
    @Published var products: [Product] = []
    
    /// 是否正在加载商品
    @Published var isLoading = false
    
    /// 是否正在购买
    @Published var isPurchasing = false
    
    // MARK: - Constants
    
    /// 内购产品 ID（需要在 App Store Connect 中配置）
    private let productIDs: Set<String> = [
        "com.lovestrategy.coins.tier1",  // 尝鲜包 ¥6 / 60签
        "com.lovestrategy.coins.tier2",  // 超值包 ¥18 / 200签
        "com.lovestrategy.coins.tier3"   // 尊享包 ¥68 / 800签
    ]
    
    /// 内购商品对应的桃花签数量
    private let coinAmounts: [String: Int] = [
        "com.lovestrategy.coins.tier1": 60,
        "com.lovestrategy.coins.tier2": 200,
        "com.lovestrategy.coins.tier3": 800
    ]
    
    // MARK: - Transaction Listener
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Singleton
    
    static let shared = IAPManager()
    
    private init() {
        // 启动时监听交易更新
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// 加载商品列表
    func loadProducts() async {
        isLoading = true
        
        do {
            // 从 App Store 获取商品信息
            products = try await Product.products(for: productIDs)
            print("✅ 成功加载 \(products.count) 个商品")
            
            for product in products {
                print("📦 商品: \(product.displayName) - \(product.displayPrice)")
            }
        } catch {
            print("❌ 加载商品失败: \(error)")
            products = []
        }
        
        isLoading = false
    }
    
    /// 购买商品
    /// - Parameters:
    ///   - product: 要购买的商品
    ///   - coinManager: 桃花签管理器（用于加币）
    /// - Returns: 购买是否成功
    func purchase(_ product: Product, coinManager: PeachBlossomManager) async throws -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            // 发起购买请求
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // 验证交易
                let transaction = try checkVerified(verification)
                
                // 发放桃花签
                await deliverCoins(for: transaction, coinManager: coinManager)
                
                // 完成交易
                await transaction.finish()
                
                print("✅ 购买成功: \(product.displayName)")
                return true
                
            case .userCancelled:
                print("⚠️ 用户取消购买")
                throw IAPError.cancelled
                
            case .pending:
                print("⏳ 购买待处理（需要家长批准）")
                return false
                
            @unknown default:
                print("❌ 未知购买结果")
                throw IAPError.unknown
            }
            
        } catch {
            print("❌ 购买失败: \(error)")
            isPurchasing = false
            throw error
        }
    }
    
    /// 恢复购买（消耗型商品不需要恢复）
    func restorePurchases() async {
        print("ℹ️ 消耗型商品无需恢复购买")
    }
    
    /// 根据产品ID获取桃花签数量
    func getCoinsAmount(for productID: String) -> Int {
        return coinAmounts[productID] ?? 0
    }
    
    /// 根据产品ID查找商品
    func getProduct(by productID: String) -> Product? {
        return products.first { $0.id == productID }
    }
    
    // MARK: - Private Methods
    
    /// 验证交易
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("❌ 交易验证失败")
            throw IAPError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    /// 发放桃花签
    private func deliverCoins(for transaction: Transaction, coinManager: PeachBlossomManager) async {
        guard let coinsAmount = coinAmounts[transaction.productID] else {
            print("❌ 未知的商品ID: \(transaction.productID)")
            return
        }
        
        // 检查是否已经发放过（防止重复发放）
        let transactionID = String(transaction.id)
        let hasDelivered = UserDefaults.standard.bool(forKey: "delivered_\(transactionID)")
        
        if hasDelivered {
            print("⚠️ 交易已处理过，跳过: \(transactionID)")
            return
        }
        
        // 发放桃花签
        await MainActor.run {
            coinManager.addCoins(coinsAmount, source: "充值")
            print("✅ 发放 \(coinsAmount) 签，交易ID: \(transactionID)")
        }
        
        // 标记已发放
        UserDefaults.standard.set(true, forKey: "delivered_\(transactionID)")
    }
    
    /// 监听交易更新
    nonisolated private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // 监听所有交易更新
            for await result in Transaction.updates {
                do {
                    // 验证交易
                    let transaction = try Self.checkVerifiedStatic(result)
                    
                    // 发放桃花签（如果还没发放）
                    await Self.deliverCoinsStatic(
                        for: transaction,
                        coinManager: PeachBlossomManager.shared
                    )
                    
                    // 完成交易
                    await transaction.finish()
                    
                } catch {
                    print("❌ 处理交易更新失败: \(error)")
                }
            }
        }
    }
    
    /// 验证交易（静态方法）
    nonisolated private static func checkVerifiedStatic<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("❌ 交易验证失败")
            throw IAPError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    /// 发放桃花签（静态方法）
    nonisolated private static func deliverCoinsStatic(for transaction: Transaction, coinManager: PeachBlossomManager) async {
        let coinAmounts: [String: Int] = [
            "com.lovestrategy.coins.tier1": 60,
            "com.lovestrategy.coins.tier2": 200,
            "com.lovestrategy.coins.tier3": 800
        ]
        
        guard let coinsAmount = coinAmounts[transaction.productID] else {
            print("❌ 未知的商品ID: \(transaction.productID)")
            return
        }
        
        // 检查是否已经发放过（防止重复发放）
        let transactionID = String(transaction.id)
        let hasDelivered = UserDefaults.standard.bool(forKey: "delivered_\(transactionID)")
        
        if hasDelivered {
            print("⚠️ 交易已处理过，跳过: \(transactionID)")
            return
        }
        
        // 发放桃花签
        await MainActor.run {
            coinManager.addCoins(coinsAmount, source: "充值")
            print("✅ 发放 \(coinsAmount) 签，交易ID: \(transactionID)")
        }
        
        // 标记已发放
        UserDefaults.standard.set(true, forKey: "delivered_\(transactionID)")
    }
}

// MARK: - 便捷扩展

extension IAPManager {
    
    /// 获取商品的本地化价格
    func getLocalizedPrice(for productID: String) -> String? {
        guard let product = getProduct(by: productID) else {
            return nil
        }
        return product.displayPrice
    }
    
    /// 检查商品是否可购买
    func isProductAvailable(_ productID: String) -> Bool {
        return products.contains { $0.id == productID }
    }
}

// MARK: - Product 扩展

extension Product {
    /// 商品对应的充值档位
    var rechargeTier: RechargeTier? {
        switch id {
        case "com.lovestrategy.coins.tier1":
            return .starter
        case "com.lovestrategy.coins.tier2":
            return .value
        case "com.lovestrategy.coins.tier3":
            return .premium
        default:
            return nil
        }
    }
}

