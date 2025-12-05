//
//  CoinBalanceView.swift
//  恋爱军师
//
//  桃花签余额显示组件
//

import SwiftUI

/// 余额显示样式
enum BalanceDisplayStyle {
    case compact    // 紧凑型（图标+数字）
    case normal     // 标准型（带背景）
    case large      // 大号型（充值页面用）
}

struct CoinBalanceView: View {
    @ObservedObject var coinManager: PeachBlossomManager
    var style: BalanceDisplayStyle = .normal
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Group {
            switch style {
            case .compact:
                compactView
            case .normal:
                normalView
            case .large:
                largeView
            }
        }
    }
    
    // MARK: - 紧凑型
    
    private var compactView: some View {
        HStack(spacing: 4) {
            Image("peach_blossom_coin")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            Text("\(coinManager.balance)")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textDark)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppTheme.softPink.opacity(0.3))
        )
        .onTapGesture {
            onTap?()
        }
    }
    
    // MARK: - 标准型
    
    private var normalView: some View {
        HStack(spacing: 6) {
            Image("peach_blossom_coin")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("桃花签")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(coinManager.balance)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.accentPink)
            }
            
            if onTap != nil {
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.accentPink)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.softPink.opacity(0.3), AppTheme.softPink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.accentPink.opacity(0.3), lineWidth: 1)
        )
        .onTapGesture {
            onTap?()
        }
    }
    
    // MARK: - 大号型
    
    private var largeView: some View {
        VStack(spacing: 12) {
            Image("peach_blossom_coin")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                Text("当前余额")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(coinManager.balance)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.accentPink)
                    
                    Text("签")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 余额状态提示
            balanceStatusHint
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.softPink.opacity(0.2), AppTheme.softPink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.accentPink.opacity(0.3), lineWidth: 1.5)
        )
    }
    
    // MARK: - 余额状态提示
    
    @ViewBuilder
    private var balanceStatusHint: some View {
        let balance = coinManager.balance
        
        if balance >= 100 {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("余额充足，尽情使用吧！")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else if balance >= 50 {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                Text("余额适中，建议适时充值")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else if balance >= 18 {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("余额偏低，建议充值")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("余额不足，请尽快充值")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - 余额变化动画修饰器

struct BalanceChangeModifier: ViewModifier {
    let balance: Int
    @State private var scale: CGFloat = 1.0
    @State private var previousBalance: Int
    
    init(balance: Int) {
        self.balance = balance
        self._previousBalance = State(initialValue: balance)
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: balance) { oldValue, newValue in
                if oldValue != newValue {
                    // 触发动画
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1.2
                    }
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                        scale = 1.0
                    }
                }
            }
    }
}

extension View {
    func balanceChangeAnimation(balance: Int) -> some View {
        modifier(BalanceChangeModifier(balance: balance))
    }
}

// MARK: - Preview

#Preview("Compact") {
    VStack(spacing: 20) {
        CoinBalanceView(
            coinManager: PeachBlossomManager.shared,
            style: .compact
        )
    }
    .padding()
}

#Preview("Normal") {
    VStack(spacing: 20) {
        CoinBalanceView(
            coinManager: PeachBlossomManager.shared,
            style: .normal,
            onTap: {
                print("Tapped")
            }
        )
    }
    .padding()
}

#Preview("Large") {
    VStack(spacing: 20) {
        CoinBalanceView(
            coinManager: PeachBlossomManager.shared,
            style: .large
        )
    }
    .padding()
}

