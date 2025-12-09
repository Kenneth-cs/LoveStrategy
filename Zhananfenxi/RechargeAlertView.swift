//
//  RechargeAlertView.swift
//  恋爱军师
//
//  余额不足提示弹窗
//

import SwiftUI

struct RechargeAlertView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var coinManager: PeachBlossomManager
    
    let requiredAmount: Int
    let featureName: String
    
    @State private var showRechargeView = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 关闭按钮
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding()
            }
            
            // 主内容
            VStack(spacing: 20) {
                // 图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.softPink, AppTheme.accentPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image("peach_blossom_coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding(.top, 10)
                
                // 标题
                Text("桃花签不足啦！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textDark)
                
                // 描述
                VStack(spacing: 8) {
                    Text("军师正在为你深度解析对方的微表情和潜台词...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 4) {
                        Text("使用")
                        Text(featureName)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.accentPink)
                        Text("需要")
                        Text("\(requiredAmount)签")
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.accentPink)
                    }
                    .font(.body)
                    
                    HStack(spacing: 4) {
                        Text("当前余额：")
                        Text("\(coinManager.balance)签")
                            .fontWeight(.bold)
                            .foregroundColor(coinManager.balance >= requiredAmount ? .green : .red)
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // 按钮组
                VStack(spacing: 12) {
                    // 充值按钮
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showRechargeView = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("立即充值")
                            Text("(仅需 ¥5.8)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.accentPink, AppTheme.darkPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                    
                    // 取消按钮
                    Button {
                        dismiss()
                    } label: {
                        Text("暂时不用")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // 底部提示
                Text("💡 仅需 ¥5.8 即可获得60签，相当于一杯奶茶钱")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: 400)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20)
        .sheet(isPresented: $showRechargeView) {
            RechargeView(coinManager: coinManager)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        RechargeAlertView(
            coinManager: PeachBlossomManager.shared,
            requiredAmount: 8,
            featureName: "鉴渣雷达"
        )
        .padding()
    }
}

