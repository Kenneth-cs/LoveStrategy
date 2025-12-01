//
//  ReplyAssistantView.swift
//  Zhananfenxi
//
//  高情商回复助手 - 拿捏工具
//

import SwiftUI

struct ReplyAssistantView: View {
    @StateObject private var service = VolcengineService()
    @State private var inputMessage: String = ""
    @State private var replyOptions: ReplyOptions?
    @State private var showResult = false
    @State private var selectedStyle: ReplyStyle?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("高情商回复助手")
                            .font(.title2)
                            .bold()
                        Text("输入对方的话，AI 帮你生成三种风格的回复")
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
                                Text("AI 正在生成...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("生成回复话术")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputMessage.isEmpty ? Color.gray : Color(red: 0.8, green: 0.2, blue: 0.4))
                        .cornerRadius(30)
                        .shadow(radius: 5)
                    }
                    .disabled(inputMessage.isEmpty || service.isAnalyzing)
                    .padding(.horizontal)
                    
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
    }
    
    private func generateReplies() {
        Task {
            do {
                // 调用 AI 生成回复
                let options = try await service.generateReplies(for: inputMessage)
                await MainActor.run {
                    withAnimation {
                        self.replyOptions = options
                    }
                }
            } catch {
                print("生成回复失败: \(error)")
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
                        UIPasteboard.general.string = reply
                        // TODO: 显示复制成功提示
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.4))
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

