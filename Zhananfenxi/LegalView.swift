//
//  LegalView.swift
//  恋爱军师
//
//  用户协议和隐私政策展示页面
//

import SwiftUI

// MARK: - 用户协议页面
struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(LegalDocuments.userAgreement)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .padding()
            }
            .navigationTitle("用户协议")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 隐私政策页面
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(LegalDocuments.privacyPolicy)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .padding()
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 首次使用欢迎页
struct WelcomeView: View {
    @Binding var hasAgreed: Bool
    @State private var showUserAgreement = false
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Logo
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.iconGradient)
            
            // 标题
            VStack(spacing: 10) {
                Text("欢迎使用恋爱军师")
                    .font(.system(size: 28, weight: .bold))
                
                Text("AI 驱动的情感洞察工具")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 说明
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "brain.head.profile",
                    text: "AI 分析结果仅供娱乐参考"
                )
                
                FeatureRow(
                    icon: "lock.shield.fill",
                    text: "您的隐私和数据安全是我们的首要任务"
                )
                
                FeatureRow(
                    icon: "iphone",
                    text: "聊天截图仅在您的设备本地存储"
                )
                
                FeatureRow(
                    icon: "person.fill.questionmark",
                    text: "我们不会收集您的个人身份信息"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 协议链接
            HStack(spacing: 5) {
                Text("点击下方按钮即表示您已阅读并同意")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 15) {
                Button {
                    showUserAgreement = true
                } label: {
                    Text("《用户协议》")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Text("和")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Button {
                    showPrivacyPolicy = true
                } label: {
                    Text("《隐私政策》")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            // 同意按钮
            Button {
                withAnimation(.spring(response: 0.3)) {
                    hasAgreed = true
                    UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
                }
            } label: {
                Text("同意并继续")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showUserAgreement) {
            UserAgreementView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}

// MARK: - 功能行
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.accentPink)
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - 预览
#Preview("欢迎页") {
    WelcomeView(hasAgreed: .constant(false))
}

#Preview("用户协议") {
    UserAgreementView()
}

#Preview("隐私政策") {
    PrivacyPolicyView()
}

