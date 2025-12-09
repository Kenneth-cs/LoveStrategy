//
//  ReplyAssistantView.swift
//  Zhananfenxi
//
//  高情商回复助手 - 拿捏工具
//

import SwiftUI

struct ReplyAssistantView: View {
    @StateObject private var service = VolcengineService()
    @StateObject private var coinManager = PeachBlossomManager.shared
    @State private var inputMessage: String = ""
    @State private var replyOptions: ReplyOptions?
    @State private var showResult = false
    @State private var selectedStyle: ReplyStyle?
    @FocusState private var isInputFocused: Bool
    @State private var showError = false
    @State private var showRechargeAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "message.badge.filled.fill")
                                .font(.title2)
                                .foregroundStyle(AppTheme.iconGradient)
                            
                            Text("高情商回复助手")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppTheme.accentPink, AppTheme.darkPink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        Text("输入对方的话，军师帮你生成三种风格的回复")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // 输入框
                    VStack(alignment: .leading, spacing: 10) {
                        Text("对方说了什么？")
                            .font(.headline)
                        
                        TextEditor(text: $inputMessage)
                            .frame(height: 100)
                            .padding(10)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .focused($isInputFocused)
                        
                        if inputMessage.isEmpty {
                            Text("例如：在干嘛？")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 生成按钮
                    Button(action: generateReplies) {
                        HStack {
                            if service.isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("军师正在生成...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("生成回复话术")
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: inputMessage.isEmpty || service.isAnalyzing))
                    .disabled(inputMessage.isEmpty || service.isAnalyzing)
                    .padding(.horizontal)
                    
                    // 消耗提示（不明显）
                    if !service.isAnalyzing {
                        Text("消耗 3 签")
                            .font(.system(size: 10))
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                            .padding(.top, 4)
                    }
                    
                    // 加载提示
                    if service.isAnalyzing {
                        Text("预计需要 10-15 秒")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .transition(.opacity)
                    }
                    
                    // 错误提示
                    if showError {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .foregroundColor(AppTheme.accentPink)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("军师正在忙碌，请点击重试~")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Text("网络波动或军师响应异常")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.softPink.opacity(0.3))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // 回复选项
                    if let options = replyOptions {
                        VStack(spacing: 20) {
                            // 高冷御姐风
                            ReplyStyleCard(
                                style: .cold,
                                title: "高冷御姐风",
                                description: "拉开距离，建立框架",
                                replies: options.coldReplies,
                                icon: "❄️"
                            )
                            
                            // 绿茶撒娇风
                            ReplyStyleCard(
                                style: .sweet,
                                title: "绿茶撒娇风",
                                description: "提供情绪价值，诱导投资",
                                replies: options.sweetReplies,
                                icon: "🍵"
                            )
                            
                            // Drama发疯风
                            ReplyStyleCard(
                                style: .drama,
                                title: "Drama发疯风",
                                description: "测试对方底线（慎用）",
                                replies: options.dramaReplies,
                                icon: "💥"
                            )
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showRechargeAlert) {
            RechargeAlertView(
                coinManager: coinManager,
                requiredAmount: 3,
                featureName: "高情商回复助手"
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func generateReplies() {
        // 检查桃花签余额（需要3签）
        guard coinManager.checkBalance(required: 3) else {
            showRechargeAlert = true
            return
        }
        
        // 收起键盘
        isInputFocused = false
        
        // 清除之前的错误状态
        showError = false
        
        Task {
            do {
                print("🔄 开始生成回复，输入内容: \(inputMessage)")
                // 调用军师生成回复
                let options = try await service.generateReplies(for: inputMessage)
                print("✅ 生成回复成功")
                print("高冷: \(options.coldReplies)")
                print("绿茶: \(options.sweetReplies)")
                print("Drama: \(options.dramaReplies)")
                
                await MainActor.run {
                    withAnimation {
                        self.replyOptions = options
                        self.showError = false
                        
                        // 生成成功后才扣费
                        try? coinManager.deductCoins(3, reason: "高情商回复生成")
                    }
                }
            } catch {
                print("❌ 生成回复失败: \(error)")
                print("错误详情: \(error.localizedDescription)")
                
                await MainActor.run {
                    withAnimation {
                        self.showError = true
                    }
                }
            }
        }
    }
}

// MARK: - 回复风格卡片

struct ReplyStyleCard: View {
    let style: ReplyStyle
    let title: String
    let description: String
    let replies: [String]
    let icon: String
    
    @State private var copiedIndex: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 标题
            HStack {
                Text(icon)
                    .font(.title)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            // 回复选项
            ForEach(Array(replies.enumerated()), id: \.offset) { index, reply in
                HStack {
                    Text(reply)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button(action: {
                        // 复制到剪贴板
                        UIPasteboard.general.string = reply
                        
                        // 触觉反馈
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        // 显示复制成功状态
                        withAnimation {
                            copiedIndex = index
                        }
                        
                        // 2秒后恢复
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                copiedIndex = nil
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: copiedIndex == index ? "checkmark" : "doc.on.doc")
                                .foregroundColor(copiedIndex == index ? .green : AppTheme.accentPink)
                            
                            if copiedIndex == index {
                                Text("已复制")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(styleColor.opacity(0.1))
        .cornerRadius(15)
    }
    
    var styleColor: Color {
        switch style {
        case .cold: return .blue
        case .sweet: return .pink
        case .drama: return .orange
        }
    }
}

// MARK: - 数据模型

enum ReplyStyle {
    case cold   // 高冷
    case sweet  // 绿茶
    case drama  // 发疯
}

struct ReplyOptions {
    let coldReplies: [String]
    let sweetReplies: [String]
    let dramaReplies: [String]
}

// MARK: - 预览

#Preview {
    ReplyAssistantView()
}

