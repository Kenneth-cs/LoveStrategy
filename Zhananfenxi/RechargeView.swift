//
//  RechargeView.swift
//  恋爱军师
//
//  桃花签充值中心
//

import SwiftUI

struct RechargeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var coinManager: PeachBlossomManager
    @State private var selectedTier: RechargeTier?
    @State private var isPurchasing = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header - 当前余额
                    VStack(spacing: 15) {
                        CoinBalanceView(
                            coinManager: coinManager,
                            style: .large
                        )
                        
                        Text("💡 桃花签已通过 iCloud 自动备份")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // 充值套餐
                    VStack(spacing: 20) {
                        Text("选择充值套餐")
                            .font(.headline)
                        
                        // 尝鲜包
                        RechargeTierCard(
                            tier: .starter,
                            isSelected: selectedTier == .starter,
                            isPurchasing: isPurchasing
                        ) {
                            selectedTier = .starter
                        } onPurchase: {
                            purchase(.starter)
                        }
                        
                        // 超值包（推荐）
                        RechargeTierCard(
                            tier: .value,
                            isSelected: selectedTier == .value,
                            isPurchasing: isPurchasing,
                            isRecommended: true
                        ) {
                            selectedTier = .value
                        } onPurchase: {
                            purchase(.value)
                        }
                        
                        // 尊享包
                        RechargeTierCard(
                            tier: .premium,
                            isSelected: selectedTier == .premium,
                            isPurchasing: isPurchasing
                        ) {
                            selectedTier = .premium
                        } onPurchase: {
                            purchase(.premium)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 使用说明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💰 桃花签消费说明")
                            .font(.headline)
                        
                        UsageInfoRow(icon: "message.fill", text: "高情商回复助手", cost: "3签/次")
                        UsageInfoRow(icon: "waveform.path.ecg", text: "鉴渣雷达（单图）", cost: "8签/次")
                        UsageInfoRow(icon: "star.circle.fill", text: "截图起卦", cost: "8签/次")
                        UsageInfoRow(icon: "photo.stack.fill", text: "多图深度分析", cost: "18签/次", badge: "即将上线")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("充值桃花签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
        }
        .alert("充值成功！", isPresented: $showSuccessAlert) {
            Button("继续使用", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("桃花签已到账，快去使用吧！")
        }
    }
    
    // MARK: - Purchase Action
    
    private func purchase(_ tier: RechargeTier) {
        isPurchasing = true
        
        // 模拟购买流程（暂时）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // 添加对应的桃花签
            coinManager.addCoins(tier.coins, source: tier.name)
            
            isPurchasing = false
            showSuccessAlert = true
        }
        
        // TODO: 接入真实的 StoreKit 2 购买流程
    }
}

// MARK: - 充值档位

enum RechargeTier: String, CaseIterable, Identifiable {
    case starter = "com.lovestrategy.coins.tier1"
    case value = "com.lovestrategy.coins.tier2"
    case premium = "com.lovestrategy.coins.tier3"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .starter: return "尝鲜包"
        case .value: return "超值包"
        case .premium: return "尊享包"
        }
    }
    
    var price: String {
        switch self {
        case .starter: return "¥6"
        case .value: return "¥18"
        case .premium: return "¥68"
        }
    }
    
    var coins: Int {
        switch self {
        case .starter: return 60
        case .value: return 200
        case .premium: return 800
        }
    }
    
    var bonus: Int {
        switch self {
        case .starter: return 0
        case .value: return 20
        case .premium: return 120
        }
    }
    
    var description: String {
        switch self {
        case .starter: return "只要一瓶可乐钱"
        case .value: return "最划算的选择"
        case .premium: return "超值大礼包"
        }
    }
    
    var icon: String {
        switch self {
        case .starter: return "🌸"
        case .value: return "💝"
        case .premium: return "👑"
        }
    }
}

// MARK: - 充值套餐卡片

struct RechargeTierCard: View {
    let tier: RechargeTier
    let isSelected: Bool
    let isPurchasing: Bool
    var isRecommended: Bool = false
    let onSelect: () -> Void
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 推荐标签
            if isRecommended {
                HStack {
                    Spacer()
                    Text("🔥 最划算")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    Spacer()
                }
                .offset(y: 12)
                .zIndex(1)
            }
            
            // 主卡片
            HStack(spacing: 15) {
                // 图标
                Text(tier.icon)
                    .font(.system(size: 50))
                
                // 信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(tier.name)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if tier.bonus > 0 {
                            Text("+\(tier.bonus)签")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.2))
                                )
                        }
                    }
                    
                    Text(tier.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(tier.coins)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.accentPink)
                        Text("签")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 价格和购买按钮
                VStack(spacing: 10) {
                    Text(tier.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.darkPink)
                    
                    Button(action: onPurchase) {
                        if isPurchasing && isSelected {
                            ProgressView()
                                .tint(AppTheme.accentPink)
                        } else {
                            Text("购买")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.accentPink, AppTheme.darkPink],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                    .disabled(isPurchasing)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? AppTheme.accentPink.opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 12 : 8,
                        y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? AppTheme.accentPink : Color.clear,
                        lineWidth: 2
                    )
            )
            .onTapGesture(perform: onSelect)
        }
    }
}

// MARK: - 使用说明行

struct UsageInfoRow: View {
    let icon: String
    let text: String
    let cost: String
    var badge: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(AppTheme.accentPink)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            if let badge = badge {
                Text(badge)
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
            }
            
            Spacer()
            
            Text(cost)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    RechargeView(coinManager: PeachBlossomManager.shared)
}

