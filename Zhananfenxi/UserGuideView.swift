//
//  UserGuideView.swift
//  恋爱军师
//
//  使用说明页面
//

import SwiftUI

struct UserGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // 欢迎
                    VStack(alignment: .leading, spacing: 10) {
                        Text("👋 欢迎使用恋爱军师")
                            .font(.title)
                            .bold()
                        
                        Text("AI 驱动的情感洞察工具，帮你识别聊天潜台词，提升情商")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.softPink)
                    .cornerRadius(15)
                    
                    // 功能介绍
                    VStack(alignment: .leading, spacing: 20) {
                        Text("🎯 核心功能")
                            .font(.title2)
                            .bold()
                        
                        FeatureGuideCard(
                            icon: "waveform.path.ecg",
                            iconColor: AppTheme.accentPink,
                            title: "AI 鉴渣雷达",
                            description: "上传聊天截图，AI 从 7 个维度分析对方的真实意图",
                            steps: [
                                "1. 点击底部「鉴渣雷达」进入",
                                "2. 上传微信/其他聊天截图",
                                "3. 点击「开始深度分析」",
                                "4. 查看雷达图和军师点评"
                            ]
                        )
                        
                        FeatureGuideCard(
                            icon: "message.badge.filled.fill",
                            iconColor: AppTheme.accentPink,
                            title: "高情商回复助手",
                            description: "输入对方的话，AI 生成三种风格的高情商回复",
                            steps: [
                                "1. 点击底部「拿捏助手」进入",
                                "2. 输入对方发来的消息",
                                "3. 点击「生成回复话术」",
                                "4. 选择喜欢的风格，点击复制"
                            ]
                        )
                        
                        FeatureGuideCard(
                            icon: "sparkles",
                            iconColor: AppTheme.accentPink,
                            title: "心理投射测试",
                            description: "通过《易经》卦象进行心理投射分析",
                            steps: [
                                "1. 点击底部「心理投射」进入",
                                "2. 上传聊天截图",
                                "3. 可选填你想了解的问题",
                                "4. 点击「开始心理投射测试」"
                            ]
                        )
                    }
                    
                    // 使用技巧
                    VStack(alignment: .leading, spacing: 15) {
                        Text("💡 使用技巧")
                            .font(.title2)
                            .bold()
                        
                        TipCard(
                            icon: "photo",
                            tip: "上传清晰的聊天截图，避免模糊或过小的图片"
                        )
                        
                        TipCard(
                            icon: "text.bubble",
                            tip: "截图尽量包含完整的对话上下文，分析会更准确"
                        )
                        
                        TipCard(
                            icon: "clock",
                            tip: "免费用户每天有 3 次分析机会，请合理使用"
                        )
                        
                        TipCard(
                            icon: "eye.slash",
                            tip: "所有数据本地存储，不会上传到服务器"
                        )
                    }
                    
                    // 常见问题
                    VStack(alignment: .leading, spacing: 15) {
                        Text("❓ 常见问题")
                            .font(.title2)
                            .bold()
                        
                        FAQCard(
                            question: "分析结果准确吗？",
                            answer: "AI 分析基于大量数据训练，具有一定参考价值，但仅供娱乐参考，不能作为决策的唯一依据。"
                        )
                        
                        FAQCard(
                            question: "我的聊天记录安全吗？",
                            answer: "您的隐私是我们的首要任务。聊天截图仅在分析时临时发送到 AI 服务，分析完成后立即删除，不会永久保存。"
                        )
                        
                        FAQCard(
                            question: "如何增加使用次数？",
                            answer: "目前免费用户每天有 3 次分析机会，每天 0:00 自动重置。敬请期待会员功能上线。"
                        )
                        
                        FAQCard(
                            question: "支持哪些聊天工具？",
                            answer: "支持微信、QQ、钉钉等所有聊天工具的截图，只要是清晰的对话截图都可以分析。"
                        )
                    }
                    
                    // 免责声明
                    VStack(alignment: .leading, spacing: 10) {
                        Text("⚠️ 重要提示")
                            .font(.headline)
                        
                        Text("本应用提供的所有分析结果均由 AI 自动生成，仅供娱乐和参考使用，不构成任何专业的心理咨询、法律建议或医疗建议。请理性看待分析结果，涉及重要个人事务时请咨询专业人士。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("使用说明")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 功能指南卡片

struct FeatureGuideCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(steps, id: \.self) { step in
                    Text(step)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - 提示卡片

struct TipCard: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.accentPink)
                .frame(width: 30)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(AppTheme.softPink)
        .cornerRadius(10)
    }
}

// MARK: - FAQ 卡片

struct FAQCard: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - 预览

#Preview {
    UserGuideView()
}

